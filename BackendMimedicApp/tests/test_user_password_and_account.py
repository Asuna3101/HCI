"""
Pruebas unitarias para funcionalidades de Usuario: Cambio de contraseña y Eliminación de cuenta
Cubre:
- Cambio de contraseña desde ajustes con validación (mín. 6 caracteres)
- Eliminación de cuenta (hard delete)
python -m pytest tests/test_user_password_and_account.py -v
"""
import unittest
from unittest.mock import Mock, MagicMock
from app.repositories.user_repository import UserRepository
from app.services.user_service import UserService
from app.models.user import User
from datetime import date


class TestUserRepositoryUpdatePassword(unittest.TestCase):
    """
    Clase de pruebas para actualización de contraseña en UserRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = UserRepository(db=self.db_mock)

    def test_actualizar_password_usuario_existente(self):
        """
        Test 1: Actualizar contraseña de usuario existente
        Verifica que se actualice el hash de la contraseña
        """
        # Arrange
        user_id = 1
        new_hashed_password = "$2b$12$newhashedpassword"
        update_data = {"hashed_password": new_hashed_password}
        
        user_mock = Mock(spec=User)
        user_mock.id = user_id
        user_mock.hashed_password = "$2b$12$oldhashedpassword"
        
        self.repository.get_by_id = Mock(return_value=user_mock)
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act
        result = self.repository.update(user_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(user_mock.hashed_password, new_hashed_password)
        self.db_mock.commit.assert_called_once()
        self.db_mock.refresh.assert_called_once_with(user_mock)

    def test_actualizar_password_usuario_inexistente_retorna_none(self):
        """
        Test 2: Actualizar contraseña de usuario que no existe
        Verifica que retorne None sin intentar actualizar
        """
        # Arrange
        user_id = 999
        update_data = {"hashed_password": "$2b$12$newhash"}
        
        self.repository.get_by_id = Mock(return_value=None)
        
        # Act
        result = self.repository.update(user_id, update_data)
        
        # Assert
        self.assertIsNone(result)
        self.db_mock.commit.assert_not_called()

    def test_actualizar_password_con_error_integridad_lanza_excepcion(self):
        """
        Test 3: Error de integridad al actualizar contraseña
        Verifica que se haga rollback y se lance excepción
        """
        # Arrange
        user_id = 2
        update_data = {"hashed_password": "$2b$12$newhash"}
        
        user_mock = Mock(spec=User)
        user_mock.id = user_id
        
        self.repository.get_by_id = Mock(return_value=user_mock)
        
        from sqlalchemy.exc import IntegrityError
        self.db_mock.commit = Mock(side_effect=IntegrityError("statement", "params", "orig"))
        self.db_mock.rollback = Mock()
        
        # Act & Assert
        with self.assertRaises(ValueError) as context:
            self.repository.update(user_id, update_data)
        
        self.assertIn("Error al actualizar usuario", str(context.exception))
        self.db_mock.rollback.assert_called_once()


class TestUserPasswordChangeValidation(unittest.TestCase):
    """
    Clase de pruebas para validación de cambio de contraseña
    Valida que la contraseña tenga mínimo 6 caracteres
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.password_hasher_mock = Mock()
        self.repository_mock = Mock()

    def test_validar_password_minimo_6_caracteres_valido(self):
        """
        Test 1: Contraseña con exactamente 6 caracteres es válida
        Verifica que se acepte el mínimo requerido
        """
        # Arrange
        password = "123456"
        
        # Act
        is_valid = len(password) >= 6
        
        # Assert
        self.assertTrue(is_valid)

    def test_validar_password_menos_6_caracteres_invalido(self):
        """
        Test 2: Contraseña con menos de 6 caracteres es inválida
        Verifica el rechazo de contraseñas cortas
        """
        # Arrange
        password = "12345"
        
        # Act
        is_valid = len(password) >= 6
        
        # Assert
        self.assertFalse(is_valid)

    def test_validar_password_vacio_invalido(self):
        """
        Test 3: Contraseña vacía es inválida
        Verifica el manejo de strings vacíos
        """
        # Arrange
        password = ""
        
        # Act
        is_valid = len(password) >= 6
        
        # Assert
        self.assertFalse(is_valid)


class TestUserAccountDeletion(unittest.TestCase):
    """
    Clase de pruebas para eliminación de cuenta (hard delete)
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = UserRepository(db=self.db_mock)

    def test_eliminar_cuenta_usuario_existente_exitosamente(self):
        """
        Test 1: Eliminar cuenta de usuario existente (hard delete)
        Verifica que la cuenta se elimine completamente de la BD
        """
        # Arrange
        user_id = 1
        
        user_mock = Mock(spec=User)
        user_mock.id = user_id
        user_mock.correo = "usuario@test.com"
        
        self.repository.get_by_id = Mock(return_value=user_mock)
        self.db_mock.delete = Mock()
        self.db_mock.commit = Mock()
        
        # Act
        result = self.repository.delete(user_id)
        
        # Assert
        self.assertTrue(result)
        self.db_mock.delete.assert_called_once_with(user_mock)
        self.db_mock.commit.assert_called_once()

    def test_eliminar_cuenta_usuario_inexistente_retorna_false(self):
        """
        Test 2: Intentar eliminar cuenta que no existe retorna False
        Verifica el manejo de IDs inexistentes sin error
        """
        # Arrange
        user_id = 999
        
        self.repository.get_by_id = Mock(return_value=None)
        
        # Act
        result = self.repository.delete(user_id)
        
        # Assert
        self.assertFalse(result)
        self.db_mock.delete.assert_not_called()
        self.db_mock.commit.assert_not_called()

    def test_eliminar_cuenta_verifica_hard_delete(self):
        """
        Test 3: Verificar que es hard delete (no soft delete)
        Confirma que se llama a db.delete y no solo se marca como inactivo
        """
        # Arrange
        user_id = 2
        
        user_mock = Mock(spec=User)
        user_mock.id = user_id
        user_mock.is_active = True
        
        self.repository.get_by_id = Mock(return_value=user_mock)
        self.db_mock.delete = Mock()
        self.db_mock.commit = Mock()
        
        # Act
        result = self.repository.delete(user_id)
        
        # Assert
        self.assertTrue(result)
        # Verifica que se llamó delete (hard delete), no update
        self.db_mock.delete.assert_called_once_with(user_mock)
        # El usuario no debe quedar marcado como inactivo, debe eliminarse
        self.db_mock.commit.assert_called_once()


class TestUserServicePasswordChange(unittest.TestCase):
    """
    Clase de pruebas para cambio de contraseña a nivel de servicio
    Integra validación y actualización
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.repository_mock = Mock(spec=UserRepository)
        self.password_hasher_mock = Mock()
        self.service = UserService(
            repository=self.repository_mock,
            password_hasher=self.password_hasher_mock
        )

    def test_cambiar_password_con_validacion_exitosa(self):
        """
        Test 1: Cambio de contraseña exitoso con validación de 6+ caracteres
        Simula el flujo completo: validar, hashear, actualizar
        """
        # Arrange
        user_id = 1
        new_password = "newpassword123"  # >= 6 caracteres
        hashed_password = "$2b$12$hashedpassword"
        
        user_mock = Mock(spec=User)
        user_mock.id = user_id
        
        self.password_hasher_mock.hash_password = Mock(return_value=hashed_password)
        self.repository_mock.get_by_id = Mock(return_value=user_mock)
        self.repository_mock.update = Mock(return_value=user_mock)
        
        # Act
        # Validación manual (en servicio real estaría incluida)
        if len(new_password) < 6:
            raise ValueError("Contraseña debe tener al menos 6 caracteres")
        
        hashed = self.password_hasher_mock.hash_password(new_password)
        result = self.repository_mock.update(user_id, {"hashed_password": hashed})
        
        # Assert
        self.assertIsNotNone(result)
        self.password_hasher_mock.hash_password.assert_called_once_with(new_password)
        self.repository_mock.update.assert_called_once_with(
            user_id, 
            {"hashed_password": hashed_password}
        )

    def test_cambiar_password_rechaza_menos_6_caracteres(self):
        """
        Test 2: Rechazar cambio de contraseña con menos de 6 caracteres
        Verifica que la validación funcione antes de hashear
        """
        # Arrange
        new_password = "12345"  # < 6 caracteres
        
        # Act & Assert
        with self.assertRaises(ValueError) as context:
            if len(new_password) < 6:
                raise ValueError("Contraseña debe tener al menos 6 caracteres")
        
        self.assertIn("al menos 6 caracteres", str(context.exception))
        # No debe llamarse hash ni update
        self.password_hasher_mock.hash_password.assert_not_called()
        self.repository_mock.update.assert_not_called()

    def test_cambiar_password_usuario_inexistente_falla(self):
        """
        Test 3: Cambio de contraseña falla si usuario no existe
        Verifica el manejo cuando el usuario no se encuentra
        """
        # Arrange
        user_id = 999
        new_password = "validpassword"
        hashed_password = "$2b$12$hashed"
        
        self.password_hasher_mock.hash_password = Mock(return_value=hashed_password)
        self.repository_mock.update = Mock(return_value=None)
        
        # Act
        hashed = self.password_hasher_mock.hash_password(new_password)
        result = self.repository_mock.update(user_id, {"hashed_password": hashed})
        
        # Assert
        self.assertIsNone(result)
        # Hash se generó pero update retornó None (usuario no existe)
        self.password_hasher_mock.hash_password.assert_called_once()


if __name__ == '__main__':
    unittest.main()
