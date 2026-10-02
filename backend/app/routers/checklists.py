from datetime import date, timedelta

from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.core.auth import get_current_uid
from app.core.errors import not_found
from app.db.session import get_session
from app.models import Checklist, ChecklistItem, Company, Schedule
from app.schemas.schemas import (
    ChecklistCreate,
    ChecklistItemUpdate,
    ChecklistRead,
)

router = APIRouter(prefix="/checklists", tags=["checklists"])

DEFAULT_ITEMS = [
    "안전교육 수료 확인",
    "보호장비 지급 여부 확인",
    "근로계약서 작성 확인",
    "비상연락망 확보",
]


def build_checklist_read(session: Session, checklist: Checklist) -> ChecklistRead:
    items = session.exec(
        select(ChecklistItem).where(ChecklistItem.checklist_id == checklist.id)
    ).all()
    company = session.get(Company, checklist.company_id)
    return ChecklistRead(
        id=checklist.id,
        company_id=checklist.company_id,
        company_name=company.name if company else None,
        status=checklist.status,
        progress=checklist.progress,
        items=items,
    )


def recalc_progress(session: Session, checklist: Checklist) -> None:
    items = session.exec(
        select(ChecklistItem).where(ChecklistItem.checklist_id == checklist.id)
    ).all()
    if not items:
        checklist.progress = 0.0
    else:
        checked = sum(1 for i in items if i.checked)
        checklist.progress = round(checked / len(items), 2)


@router.get("", response_model=list[ChecklistRead])
def list_checklists(
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    checklists = session.exec(
        select(Checklist).where(Checklist.user_id == uid)
    ).all()
    return [build_checklist_read(session, c) for c in checklists]


@router.post("", response_model=ChecklistRead)
def create_checklist(
    payload: ChecklistCreate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    company = session.get(Company, payload.company_id)
    if company is None:
        raise not_found("기업을 찾을 수 없습니다.")

    existing = session.exec(
        select(Checklist).where(
            Checklist.user_id == uid,
            Checklist.company_id == payload.company_id,
        )
    ).first()
    if existing is not None:
        return build_checklist_read(session, existing)

    checklist = Checklist(user_id=uid, company_id=payload.company_id)
    session.add(checklist)
    session.commit()
    session.refresh(checklist)

    for label in DEFAULT_ITEMS:
        session.add(ChecklistItem(checklist_id=checklist.id, label=label))

    schedule = Schedule(
        user_id=uid,
        checklist_id=checklist.id,
        title=f"{company.name} 현장실습 준비",
        date=date.today() + timedelta(days=7),
    )
    session.add(schedule)
    session.commit()
    session.refresh(checklist)
    return build_checklist_read(session, checklist)


@router.get("/{checklist_id}", response_model=ChecklistRead)
def get_checklist(
    checklist_id: int,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    checklist = session.get(Checklist, checklist_id)
    if checklist is None or checklist.user_id != uid:
        raise not_found()
    return build_checklist_read(session, checklist)


@router.patch("/{checklist_id}/items/{item_id}", response_model=ChecklistRead)
def toggle_item(
    checklist_id: int,
    item_id: int,
    payload: ChecklistItemUpdate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    checklist = session.get(Checklist, checklist_id)
    if checklist is None or checklist.user_id != uid:
        raise not_found()
    item = session.get(ChecklistItem, item_id)
    if item is None or item.checklist_id != checklist_id:
        raise not_found()
    item.checked = payload.checked
    session.add(item)
    recalc_progress(session, checklist)
    session.add(checklist)
    session.commit()
    session.refresh(checklist)
    return build_checklist_read(session, checklist)


@router.post("/{checklist_id}/submit", response_model=ChecklistRead)
def submit_checklist(
    checklist_id: int,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    checklist = session.get(Checklist, checklist_id)
    if checklist is None or checklist.user_id != uid:
        raise not_found()
    checklist.status = "completed"
    checklist.progress = 1.0
    session.add(checklist)
    session.commit()
    session.refresh(checklist)
    return build_checklist_read(session, checklist)
