import smtplib
import random
from datetime import datetime, timedelta, timezone
from email.mime.text import MIMEText
from fastapi import HTTPException
from app.interfaces.recovery_service_interface import IRecoveryService
from app.interfaces.user_repository_interface import IUserRepository
from app.interfaces.auth_interface import IPasswordHasher
from app.core.config import settings


GMAIL_USER = "mimedicapp.soporte@gmail.com"
GMAIL_PASSWORD = "fqzm nhjq jmwr mhuh"


class RecoveryService(IRecoveryService):
    def __init__(self, user_repo: IUserRepository, hasher: IPasswordHasher):
        self.user_repo = user_repo
        self.hasher = hasher

    def request_code(self, email: str) -> None:
        user = self.user_repo.get_by_email(email)
        if not user:
            # No revelamos que no existe; simplemente salimos
            return
        code = f"{random.randint(0, 9999):04d}"
        exp = datetime.now(timezone.utc) + timedelta(minutes=10)
        user.recovery_code = code
        user.recovery_expires = exp
        self.user_repo.db.commit()
        self._send_email(email, code)

    def confirm_code(self, email: str, code: str, new_password: str) -> None:
        user = self.user_repo.get_by_email(email)
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        if not user.recovery_code or not user.recovery_expires:
            raise HTTPException(status_code=400, detail="No hay código activo")
        if user.recovery_expires < datetime.now(timezone.utc):
            raise HTTPException(status_code=400, detail="Código expirado")
        if user.recovery_code != code:
            raise HTTPException(status_code=400, detail="Código inválido")

        user.hashed_password = self.hasher.hash_password(new_password)
        user.recovery_code = None
        user.recovery_expires = None
        self.user_repo.db.commit()
        # Limpia sesión: opcional, aquí solo confirmamos

    def _send_email(self, to_email: str, code: str):
        subject = "MiMedicApp · Código de recuperación"
        spaced = " ".join(list(code))
        html = f"""
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    :root {{
      --primary: #3A1855;
      --accent: #E91E63;
      --bg: #f7f1fb;
      --card: #ffffff;
      --text: #2c2738;
    }}
    body {{ font-family: 'Helvetica Neue', Arial, sans-serif; background:var(--bg); margin:0; padding:0; }}
    .card {{
      max-width: 520px; margin:24px auto; background:var(--card);
      border-radius:16px; padding:28px;
      box-shadow:0 12px 28px rgba(58, 24, 85, 0.12);
      border:1px solid #e8def4;
    }}
    .logo {{
      width:52px; height:52px; background:var(--primary);
      color:#fff; border-radius:14px; display:flex;
      align-items:center; justify-content:center;
      font-weight:800; font-size:22px; margin-bottom:14px;
    }}
    .title {{ color:var(--text); font-size:22px; font-weight:800; margin:0 0 12px 0; }}
    .text {{ color:#4b4256; font-size:15px; line-height:1.7; margin:0 0 18px 0; }}
    .code {{
      display:inline-block; background:rgba(58,24,85,0.08); color:var(--primary);
      padding:14px 20px; border-radius:14px; letter-spacing:8px;
      font-size:24px; font-weight:800; border:1px solid rgba(58,24,85,0.12);
      box-shadow:inset 0 1px 0 rgba(255,255,255,0.6);
    }}
    .footer {{ color:#7a6f86; font-size:12px; margin-top:20px; }}
  </style>
</head>
<body>
  <div class="card">
    <div class="title">MiMedicApp 💊</div>
    <p class="text">Recibimos una solicitud para restablecer tu contraseña. Usa el siguiente código de 4 dígitos:</p>
    <div class="code">{spaced}</div>
    <p class="text">Este código expira en 10 minutos.<br>
    Si no solicitaste este cambio, puedes ignorar este correo.</p>
    <div class="footer">Equipo MiMedicApp</div>
  </div>
</body>
</html>
"""
        msg = MIMEText(html, "html", "utf-8")
        msg["Subject"] = subject
        msg["From"] = GMAIL_USER
        msg["To"] = to_email

        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as server:
            server.login(GMAIL_USER, GMAIL_PASSWORD)
            server.send_message(msg)
