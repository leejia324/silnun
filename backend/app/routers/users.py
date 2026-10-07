from fastapi import APIRouter, Depends
from sqlmodel import Session

from app.core.auth import get_current_uid
from app.db.session import get_session
from app.models import User
from app.schemas.schemas import UserRead, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])


def get_or_create_user(session: Session, uid: str) -> User:
    user = session.get(User, uid)
    if user is None:
        user = User(uid=uid, email="")
        session.add(user)
        session.commit()
        session.refresh(user)
    return user


@router.get("/me", response_model=UserRead)
def read_me(uid: str = Depends(get_current_uid), session: Session = Depends(get_session)):
    return get_or_create_user(session, uid)


@router.patch("/me", response_model=UserRead)
def update_me(
    payload: UserUpdate,
    uid: str = Depends(get_current_uid),
    session: Session = Depends(get_session),
):
    user = get_or_create_user(session, uid)
    if payload.email is not None:
        user.email = payload.email
    if payload.name is not None:
        user.name = payload.name
    if payload.school is not None:
        user.school = payload.school
    if payload.grade is not None:
        user.grade = payload.grade
    session.add(user)
    session.commit()
    session.refresh(user)
    return user
