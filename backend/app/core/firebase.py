import os

import firebase_admin
from firebase_admin import credentials

from app.core.config import settings

_initialized = False


def init_firebase() -> None:
    global _initialized
    if _initialized:
        return
    if os.path.exists(settings.firebase_credentials_path):
        cred = credentials.Certificate(settings.firebase_credentials_path)
        firebase_admin.initialize_app(cred)
    else:
        firebase_admin.initialize_app()
    _initialized = True
