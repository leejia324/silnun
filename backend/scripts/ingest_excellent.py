import csv
import hashlib
import sys
from pathlib import Path

from sqlmodel import Session, select

from app.db.session import create_db_and_tables, engine
from app.models import Company

DEFAULT_PATH = Path(__file__).resolve().parent.parent / "data" / "excellent.csv"


def make_id(name: str, office: str) -> str:
    digest = hashlib.md5(f"{name}|{office}".encode("utf-8")).hexdigest()[:12]
    return f"exc_{digest}"


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


def year_of(value: str) -> int | None:
    value = (value or "").strip()
    if len(value) >= 4 and value[:4].isdigit():
        return int(value[:4])
    return None


def run(path: Path) -> None:
    if not path.exists():
        print(f"CSV 파일이 없습니다: {path}")
        sys.exit(1)

    create_db_and_tables()
    f = open_csv(path)
    reader = csv.DictReader(f)

    added = 0
    skipped = 0
    with Session(engine) as session:
        for row in reader:
            name = (row.get("사업장명") or "").strip()
            if not name:
                continue
            office = (row.get("노동지청명") or "").strip()

            existing = session.exec(
                select(Company).where(Company.name == name)
            ).first()
            if existing is not None and existing.risk_level in (
                "danger",
                "caution",
            ):
                skipped += 1
                continue

            company = Company(
                id=make_id(name, office),
                name=name,
                category=None,
                region=office or None,
                employee_size_band=None,
                risk_level="good",
                report_year=year_of(row.get("인정일", "")),
            )
            session.merge(company)
            added += 1
        session.commit()

    f.close()
    print(f"우수사업장 적재 완료: 추가 {added}건, 위험/주의 우선 건너뜀 {skipped}건")


if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PATH
    run(target)
