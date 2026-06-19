import unittest
from unittest.mock import Mock
from datetime import datetime, timedelta, timezone
from fastapi import HTTPException

from app.services.recovery_service import RecoveryService


class TestRecoveryService(unittest.TestCase):
    def setUp(self):
        self.user_repo = Mock()
        self.user_repo.db = Mock()
        self.hasher = Mock()
        self.service = RecoveryService(self.user_repo, self.hasher)

    def test_request_code_setea_codigo_y_envia_correo(self):
        user = Mock()
        self.user_repo.get_by_email.return_value = user
        self.service._send_email = Mock()

        self.service.request_code("user@test.com")

        self.user_repo.get_by_email.assert_called_once_with("user@test.com")
        self.assertIsNotNone(user.recovery_code)
        self.assertIsNotNone(user.recovery_expires)
        self.service._send_email.assert_called_once()
        self.user_repo.db.commit.assert_called_once()

    def test_request_code_usuario_inexistente_no_envia(self):
        self.user_repo.get_by_email.return_value = None
        self.service._send_email = Mock()

        self.service.request_code("no@existe.com")

        self.service._send_email.assert_not_called()
        self.user_repo.db.commit.assert_not_called()

    def test_confirm_code_ok_actualiza_password_y_limpia_codigo(self):
        user = Mock()
        user.recovery_code = "1234"
        user.recovery_expires = datetime.now(timezone.utc) + timedelta(minutes=5)
        self.user_repo.get_by_email.return_value = user
        self.hasher.hash_password.return_value = "hashed"

        self.service.confirm_code("user@test.com", "1234", "NuevaPass1")

        self.user_repo.get_by_email.assert_called_once_with("user@test.com")
        self.assertEqual(user.hashed_password, "hashed")
        self.assertIsNone(user.recovery_code)
        self.assertIsNone(user.recovery_expires)
        self.user_repo.db.commit.assert_called_once()

    def test_confirm_code_expirado_lanza_http_exception(self):
        user = Mock()
        user.recovery_code = "1234"
        user.recovery_expires = datetime.now(timezone.utc) - timedelta(minutes=1)
        self.user_repo.get_by_email.return_value = user

        with self.assertRaises(HTTPException):
            self.service.confirm_code("user@test.com", "1234", "NuevaPass1")

    def test_confirm_code_invalido_lanza_http_exception(self):
        user = Mock()
        user.recovery_code = "9999"
        user.recovery_expires = datetime.now(timezone.utc) + timedelta(minutes=5)
        self.user_repo.get_by_email.return_value = user

        with self.assertRaises(HTTPException):
            self.service.confirm_code("user@test.com", "1234", "NuevaPass1")


if __name__ == "__main__":
    unittest.main()
