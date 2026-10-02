import datetime as dt

from pydantic import BaseModel, ConfigDict


class UserRead(BaseModel):
    uid: str
    email: str
    created_at: dt.datetime


class UserUpdate(BaseModel):
    email: str | None = None


class CompanySummary(BaseModel):
    id: str
    name: str
    category: str | None = None
    region: str | None = None
    risk_level: str


class ViolationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    year: int
    count: int
    description: str | None = None


class LaborConditionRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    type: str
    compliant: bool


class CompanyDetail(BaseModel):
    id: str
    name: str
    category: str | None = None
    region: str | None = None
    employee_size_band: str | None = None
    risk_level: str
    report_year: int | None = None
    injury_rate: float | None = None
    avg_injury_rate: float | None = None
    worker_count: int | None = None
    casualty_count: int | None = None
    serious_casualty_count: int | None = None
    violations: list[ViolationRead] = []
    labor_conditions: list[LaborConditionRead] = []


class ReviewRead(BaseModel):
    id: int
    company_id: str
    user_id: str
    content: str
    created_at: dt.datetime


class ReviewCreate(BaseModel):
    content: str


class RecentSearchRead(BaseModel):
    id: int
    query: str
    created_at: dt.datetime


class RecentSearchCreate(BaseModel):
    query: str


class ChecklistItemRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    label: str
    checked: bool


class ChecklistRead(BaseModel):
    id: int
    company_id: str
    company_name: str | None = None
    status: str
    progress: float
    items: list[ChecklistItemRead] = []


class ChecklistCreate(BaseModel):
    company_id: str


class ChecklistItemUpdate(BaseModel):
    checked: bool


class ScheduleRead(BaseModel):
    id: int
    checklist_id: int | None = None
    title: str
    date: dt.date


class ScheduleCreate(BaseModel):
    title: str
    date: dt.date
    checklist_id: int | None = None


class ScheduleUpdate(BaseModel):
    title: str | None = None
    date: dt.date | None = None
