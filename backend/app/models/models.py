from datetime import date, datetime

from sqlmodel import Field, SQLModel


class User(SQLModel, table=True):
    uid: str = Field(primary_key=True)
    email: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


class Company(SQLModel, table=True):
    id: str = Field(primary_key=True)
    name: str = Field(index=True)
    category: str | None = None
    region: str | None = None
    employee_size_band: str | None = None
    risk_level: str = "no_data"
    report_year: int | None = None
    injury_rate: float | None = None
    avg_injury_rate: float | None = None
    worker_count: int | None = None
    casualty_count: int | None = None
    serious_casualty_count: int | None = None


class Violation(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    company_id: str = Field(foreign_key="company.id", index=True)
    year: int
    count: int = 0
    description: str | None = None


class LaborCondition(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    company_id: str = Field(foreign_key="company.id", index=True)
    type: str
    compliant: bool = True


class Review(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    company_id: str = Field(foreign_key="company.id", index=True)
    user_id: str = Field(foreign_key="user.uid", index=True)
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)


class Checklist(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    user_id: str = Field(foreign_key="user.uid", index=True)
    company_id: str = Field(foreign_key="company.id")
    status: str = "in_progress"
    progress: float = 0.0


class ChecklistItem(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    checklist_id: int = Field(foreign_key="checklist.id", index=True)
    label: str
    checked: bool = False


class Schedule(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    user_id: str = Field(foreign_key="user.uid", index=True)
    checklist_id: int | None = Field(default=None, foreign_key="checklist.id")
    title: str
    date: date


class RecentSearch(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    user_id: str = Field(foreign_key="user.uid", index=True)
    query: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
