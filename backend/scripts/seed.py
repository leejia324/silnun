from sqlmodel import Session, delete

from app.db.session import create_db_and_tables, engine
from app.models import Company, LaborCondition, Violation


COMPANIES = [
    {
        "id": "c_001",
        "name": "대한중공업",
        "category": "제조업",
        "region": "울산광역시",
        "employee_size_band": "300인 이상",
        "risk_level": "danger",
        "report_year": 2024,
        "injury_rate": 1.85,
        "avg_injury_rate": 0.62,
        "worker_count": 540,
        "casualty_count": 10,
        "serious_casualty_count": 2,
        "violations": [
            {"year": 2024, "count": 2, "description": "중대재해 발생"},
            {"year": 2023, "count": 1, "description": "추락 사고"},
        ],
        "labor_conditions": [
            {"type": "minimumWage", "compliant": False},
            {"type": "workHours", "compliant": False},
        ],
    },
    {
        "id": "c_002",
        "name": "한빛전자",
        "category": "전자부품 제조업",
        "region": "경기도 수원시",
        "employee_size_band": "100~299인",
        "risk_level": "caution",
        "report_year": 2024,
        "injury_rate": 0.94,
        "avg_injury_rate": 0.71,
        "worker_count": 180,
        "casualty_count": 2,
        "serious_casualty_count": 0,
        "violations": [
            {"year": 2024, "count": 1, "description": "안전교육 미실시"},
        ],
        "labor_conditions": [
            {"type": "minimumWage", "compliant": True},
            {"type": "workHours", "compliant": False},
        ],
    },
    {
        "id": "c_003",
        "name": "미래정밀",
        "category": "기계 제조업",
        "region": "인천광역시",
        "employee_size_band": "50~99인",
        "risk_level": "good",
        "report_year": 2024,
        "injury_rate": 0.21,
        "avg_injury_rate": 0.68,
        "worker_count": 75,
        "casualty_count": 0,
        "serious_casualty_count": 0,
        "violations": [],
        "labor_conditions": [
            {"type": "minimumWage", "compliant": True},
            {"type": "workHours", "compliant": True},
        ],
    },
    {
        "id": "c_004",
        "name": "신성푸드",
        "category": "식품 제조업",
        "region": "충청북도 청주시",
        "employee_size_band": "10~49인",
        "risk_level": "no_data",
        "violations": [],
        "labor_conditions": [],
    },
]


def run() -> None:
    create_db_and_tables()
    with Session(engine) as session:
        ids = [d["id"] for d in COMPANIES]
        session.exec(delete(Violation).where(Violation.company_id.in_(ids)))
        session.exec(
            delete(LaborCondition).where(LaborCondition.company_id.in_(ids))
        )
        session.exec(delete(Company).where(Company.id.in_(ids)))
        session.commit()

        for data in COMPANIES:
            company = Company(
                id=data["id"],
                name=data["name"],
                category=data["category"],
                region=data["region"],
                employee_size_band=data["employee_size_band"],
                risk_level=data["risk_level"],
                report_year=data.get("report_year"),
                injury_rate=data.get("injury_rate"),
                avg_injury_rate=data.get("avg_injury_rate"),
                worker_count=data.get("worker_count"),
                casualty_count=data.get("casualty_count"),
                serious_casualty_count=data.get("serious_casualty_count"),
            )
            session.add(company)
            for v in data["violations"]:
                session.add(Violation(company_id=data["id"], **v))
            for lc in data["labor_conditions"]:
                session.add(LaborCondition(company_id=data["id"], **lc))
        session.commit()

    print(f"더미 데이터 {len(COMPANIES)}개 기업 삽입 완료")


if __name__ == "__main__":
    run()
