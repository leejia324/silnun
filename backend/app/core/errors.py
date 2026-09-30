from fastapi import HTTPException


class ApiError(HTTPException):
    def __init__(self, status_code: int, code: str, message: str):
        super().__init__(status_code=status_code, detail={"code": code, "message": message})


def unauthorized(message: str = "유효하지 않은 토큰입니다.") -> ApiError:
    return ApiError(401, "UNAUTHORIZED", message)


def forbidden(message: str = "권한이 없습니다.") -> ApiError:
    return ApiError(403, "FORBIDDEN", message)


def not_found(message: str = "대상을 찾을 수 없습니다.") -> ApiError:
    return ApiError(404, "NOT_FOUND", message)
