from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from app.core.errors import ApiError
from app.core.firebase import init_firebase
from app.db.session import create_db_and_tables
from app.routers import checklists, companies, schedules, users


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_firebase()
    create_db_and_tables()
    yield


app = FastAPI(title="Silnun API", version="1.0.0", lifespan=lifespan)


@app.exception_handler(ApiError)
async def api_error_handler(request: Request, exc: ApiError):
    return JSONResponse(status_code=exc.status_code, content={"error": exc.detail})


app.include_router(users.router, prefix="/v1")
app.include_router(companies.router, prefix="/v1")
app.include_router(checklists.router, prefix="/v1")
app.include_router(schedules.router, prefix="/v1")


@app.get("/health")
def health():
    return {"status": "ok"}
