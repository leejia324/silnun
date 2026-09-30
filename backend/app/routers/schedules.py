from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.core.auth import get_current_uid
from app.core.errors import not_found
from app.db.session import get_session
from app.models import Schedule
from app.schemas.schemas import ScheduleCreate, ScheduleRead, ScheduleUpdate

router = APIRouter(prefix="/schedules", tags=["schedules"])


@router.get("", response_model=list[ScheduleRead])
def list_schedules(
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    statement = (
        select(Schedule).where(Schedule.user_id == uid).order_by(Schedule.date)
    )
    return session.exec(statement).all()


@router.post("", response_model=ScheduleRead)
def create_schedule(
    payload: ScheduleCreate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    schedule = Schedule(
        user_id=uid,
        checklist_id=payload.checklist_id,
        title=payload.title,
        date=payload.date,
    )
    session.add(schedule)
    session.commit()
    session.refresh(schedule)
    return schedule


@router.patch("/{schedule_id}", response_model=ScheduleRead)
def update_schedule(
    schedule_id: int,
    payload: ScheduleUpdate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    schedule = session.get(Schedule, schedule_id)
    if schedule is None or schedule.user_id != uid:
        raise not_found()
    if payload.title is not None:
        schedule.title = payload.title
    if payload.date is not None:
        schedule.date = payload.date
    session.add(schedule)
    session.commit()
    session.refresh(schedule)
    return schedule


@router.delete("/{schedule_id}")
def delete_schedule(
    schedule_id: int,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    schedule = session.get(Schedule, schedule_id)
    if schedule is None or schedule.user_id != uid:
        raise not_found()
    session.delete(schedule)
    session.commit()
    return {"ok": True}
