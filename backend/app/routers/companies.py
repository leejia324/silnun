from fastapi import APIRouter, Depends
from sqlmodel import Session, or_, select

from app.core.auth import get_current_uid
from app.core.errors import not_found
from app.db.session import get_session
from app.models import Company, LaborCondition, RecentSearch, Review, Violation
from app.schemas.schemas import (
    CompanyDetail,
    CompanySummary,
    RecentSearchCreate,
    RecentSearchRead,
    ReviewCreate,
    ReviewRead,
)

router = APIRouter(prefix="/companies", tags=["companies"])


@router.get("/search", response_model=list[CompanySummary])
def search_companies(
    q: str,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    statement = select(Company).where(
        or_(
            Company.name.contains(q),
            Company.category.contains(q),
            Company.region.contains(q),
        )
    )
    return session.exec(statement).all()


@router.get("/recent-searches", response_model=list[RecentSearchRead])
def list_recent_searches(
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    statement = (
        select(RecentSearch)
        .where(RecentSearch.user_id == uid)
        .order_by(RecentSearch.created_at.desc())
    )
    return session.exec(statement).all()


@router.post("/recent-searches", response_model=RecentSearchRead)
def add_recent_search(
    payload: RecentSearchCreate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    item = RecentSearch(user_id=uid, query=payload.query)
    session.add(item)
    session.commit()
    session.refresh(item)
    return item


@router.delete("/recent-searches/{search_id}")
def delete_recent_search(
    search_id: int,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    item = session.get(RecentSearch, search_id)
    if item is None or item.user_id != uid:
        raise not_found()
    session.delete(item)
    session.commit()
    return {"ok": True}


@router.get("/{company_id}", response_model=CompanyDetail)
def get_company(
    company_id: str,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    company = session.get(Company, company_id)
    if company is None:
        raise not_found("기업을 찾을 수 없습니다.")
    violations = session.exec(
        select(Violation).where(Violation.company_id == company_id)
    ).all()
    labor_conditions = session.exec(
        select(LaborCondition).where(LaborCondition.company_id == company_id)
    ).all()
    return CompanyDetail(
        id=company.id,
        name=company.name,
        category=company.category,
        region=company.region,
        employee_size_band=company.employee_size_band,
        risk_level=company.risk_level,
        report_year=company.report_year,
        injury_rate=company.injury_rate,
        avg_injury_rate=company.avg_injury_rate,
        worker_count=company.worker_count,
        casualty_count=company.casualty_count,
        serious_casualty_count=company.serious_casualty_count,
        violations=violations,
        labor_conditions=labor_conditions,
    )


@router.get("/{company_id}/reviews", response_model=list[ReviewRead])
def list_reviews(
    company_id: str,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    statement = (
        select(Review)
        .where(Review.company_id == company_id)
        .order_by(Review.created_at.desc())
    )
    return session.exec(statement).all()


@router.post("/{company_id}/reviews", response_model=ReviewRead)
def create_review(
    company_id: str,
    payload: ReviewCreate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    company = session.get(Company, company_id)
    if company is None:
        raise not_found("기업을 찾을 수 없습니다.")
    review = Review(company_id=company_id, user_id=uid, content=payload.content)
    session.add(review)
    session.commit()
    session.refresh(review)
    return review
