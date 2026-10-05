from datetime import date, timedelta

from fastapi import APIRouter, Depends
from sqlmodel import Session, select

from app.core.auth import get_current_uid
from app.core.errors import not_found
from app.db.session import get_session
from app.models import (
    Checklist,
    ChecklistItem,
    Company,
    LaborCondition,
    Schedule,
    Violation,
)
from app.schemas.schemas import (
    ChecklistCreate,
    ChecklistItemRead,
    ChecklistItemUpdate,
    ChecklistRead,
)

router = APIRouter(prefix="/checklists", tags=["checklists"])

DEFAULT_ITEMS = [
    ("실습 전 준비", "표준협약서 체결 확인", None),
    ("실습 전 준비", "실습기간·실습시간 명시 확인", None),
    ("실습 전 준비", "현장지도인 지정 확인", None),
    ("실습 전 준비", "산재보험 가입 확인", None),
    ("실습 전 준비", "실습수당 명시 확인", None),
    ("실습 전 준비", "직무 내용 일치 확인", None),
    ("안전·보호장비", "안전보건교육 이수", "safetyEducation"),
    ("안전·보호장비", "보호장비 지급", "protectiveGear"),
    ("안전·보호장비", "위험작업 미배치 확인", "dangerousWork"),
    ("안전·보호장비", "비상연락체계 안내", None),
    ("안전·보호장비", "소방·대피 안내", None),
    ("근로조건", "실습시간 상한 준수", "workHours"),
    ("근로조건", "휴게시간 보장", None),
    ("근로조건", "야간·휴일 실습 금지 확인", None),
    ("근로조건", "최저임금 준수", "minimumWage"),
    ("근로조건", "부당한 사적 업무 지시 없음", None),
    ("실습 중 지속 확인", "주간 실습 일지 작성", None),
    ("실습 중 지속 확인", "지도교사 방문·연락 확인", None),
    ("실습 중 지속 확인", "이상 징후 신고 경로 인지", None),
    ("실습 중 지속 확인", "협약 내용 변경 여부 확인", None),
]

LINK_KEYWORDS = {
    "safetyEducation": "안전교육",
    "protectiveGear": "보호장비",
    "dangerousWork": "위험",
}


def _has_violation(link_key: str | None, noncompliant: set[str], descs: str) -> bool:
    if link_key is None:
        return False
    if link_key in noncompliant:
        return True
    keyword = LINK_KEYWORDS.get(link_key)
    return bool(keyword and keyword in descs)


def build_checklist_read(session: Session, checklist: Checklist) -> ChecklistRead:
    items = session.exec(
        select(ChecklistItem).where(ChecklistItem.checklist_id == checklist.id)
    ).all()
    company = session.get(Company, checklist.company_id)

    labor = session.exec(
        select(LaborCondition).where(
            LaborCondition.company_id == checklist.company_id
        )
    ).all()
    violations = session.exec(
        select(Violation).where(Violation.company_id == checklist.company_id)
    ).all()
    noncompliant = {lc.type for lc in labor if not lc.compliant}
    descs = " ".join(v.description or "" for v in violations)

    item_reads = [
        ChecklistItemRead(
            id=it.id,
            category=it.category,
            label=it.label,
            checked=it.checked,
            warning=_has_violation(it.link_key, noncompliant, descs),
        )
        for it in items
    ]
    return ChecklistRead(
        id=checklist.id,
        company_id=checklist.company_id,
        company_name=company.name if company else None,
        status=checklist.status,
        progress=checklist.progress,
        items=item_reads,
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

    for category, label, link_key in DEFAULT_ITEMS:
        session.add(
            ChecklistItem(
                checklist_id=checklist.id,
                category=category,
                label=label,
                link_key=link_key,
            )
        )

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
    recalc_progress(session, checklist)
    session.add(checklist)
    session.commit()
    session.refresh(checklist)
    return build_checklist_read(session, checklist)
