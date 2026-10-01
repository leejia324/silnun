import csv
import hashlib
import sys
from pathlib import Path

from sqlmodel import Session, delete, select

from app.db.session import create_db_and_tables, engine
from app.models import Company, LaborCondition, Violation

DEFAULT_PATH = Path(__file__).resolve().parent.parent / "data" / "companies.csv"

COLUMN_CANDIDATES = {
    "year": ["재해발생연도", "발생연도", "연도"],
    "region": ["지역"],
    "category": ["업종명", "업종"],
    "size": ["규모"],
    "name": ["사업장명", "현장명", "사업장"],
    "address": ["소재지"],
    "serious": ["중대재해 재해자수", "중대재해재해자수", "중대재해"],
    "workers": ["근로자수"],
    "casualties": ["재해자수"],
    "injury_rate": ["재해율"],
    "avg_injury_rate": ["평균 재해율", "평균재해율", "동종업종 평균"],
}


def find_key(
    fieldnames: list[str], candidates: list[str], used: set[str]
) -> str | None:
    for cand in candidates:
        target = cand.replace(" ", "")
        for name in fieldnames:
            if name in used:
                continue
            if target in name.replace(" ", ""):
                used.add(name)
                return name
    return None


def to_float(value: str | None) -> float | None:
    if value is None:
        return None
    cleaned = value.replace("%", "").replace(",", "").strip()
    if cleaned == "":
        return None
    try:
        return float(cleaned)
    except ValueError:
        return None


def to_int(value: str | None) -> int | None:
    f = to_float(value)
    return int(f) if f is not None else None


def make_id(name: str, region: str, year: str) -> str:
    raw = f"{name}|{region}|{year}"
    digest = hashlib.md5(raw.encode("utf-8")).hexdigest()[:12]
    return f"pub_{digest}"


def compute_risk(serious: int | None) -> str:
    if serious and serious >= 1:
        return "danger"
    return "caution"


def open_csv(path: Path):
    for encoding in ("utf-8-sig", "cp949", "euc-kr"):
        try:
            f = path.open("r", encoding=encoding, newline="")
            f.readline()
            f.seek(0)
            return f
        except UnicodeDecodeError:
            continue
    return path.open("r", encoding="utf-8", errors="replace", newline="")


def run(path: Path) -> None:
    if not path.exists():
        print(f"CSV 파일이 없습니다: {path}")
        print("data.go.kr(15090150)에서 CSV를 내려받아 위 경로에 저장하세요.")
        sys.exit(1)

    create_db_and_tables()
    f = open_csv(path)
    reader = csv.DictReader(f)
    fieldnames = reader.fieldnames or []
    used: set[str] = set()
    keys = {k: find_key(fieldnames, c, used) for k, c in COLUMN_CANDIDATES.items()}

    inserted = 0
    with Session(engine) as session:
        existing_ids = session.exec(
            select(Company.id).where(Company.id.like("pub_%"))
        ).all()
        if existing_ids:
            session.exec(
                delete(Violation).where(Violation.company_id.in_(existing_ids))
            )
            session.exec(
                delete(LaborCondition).where(
                    LaborCondition.company_id.in_(existing_ids)
                )
            )
            session.exec(delete(Company).where(Company.id.in_(existing_ids)))
            session.commit()

        for row in reader:
            name = (row.get(keys["name"]) or "").strip() if keys["name"] else ""
            if not name:
                continue
            region = (row.get(keys["region"]) or "").strip() if keys["region"] else ""
            year_raw = (row.get(keys["year"]) or "").strip() if keys["year"] else ""
            serious = to_int(row.get(keys["serious"])) if keys["serious"] else None
            casualties = to_int(row.get(keys["casualties"])) if keys["casualties"] else None
            workers = to_int(row.get(keys["workers"])) if keys["workers"] else None

            company = Company(
                id=make_id(name, region, year_raw),
                name=name,
                category=(row.get(keys["category"]) or "").strip() if keys["category"] else None,
                region=region or None,
                employee_size_band=(row.get(keys["size"]) or "").strip() if keys["size"] else None,
                risk_level=compute_risk(serious),
                report_year=to_int(year_raw),
                injury_rate=to_float(row.get(keys["injury_rate"])) if keys["injury_rate"] else None,
                avg_injury_rate=to_float(row.get(keys["avg_injury_rate"])) if keys["avg_injury_rate"] else None,
                worker_count=workers,
                casualty_count=casualties,
                serious_casualty_count=serious,
            )
            session.merge(company)

            if casualties and to_int(year_raw):
                session.add(
                    Violation(
                        company_id=company.id,
                        year=to_int(year_raw),
                        count=casualties,
                        description=None,
                    )
                )
            inserted += 1
        session.commit()

    f.close()
    print(f"공공데이터 {inserted}건 적재 완료")
    print(f"매핑된 컬럼: {keys}")


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PATH
    run(target)
