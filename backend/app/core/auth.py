from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth as firebase_auth

from app.core.errors import unauthorized

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_uid(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> str:
    if credentials is None:
        raise unauthorized("인증 토큰이 필요합니다.")
    try:
        decoded = firebase_auth.verify_id_token(credentials.credentials)
    except Exception:
        raise unauthorized()
    return decoded["uid"]
