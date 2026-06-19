"""
Pruebas unitarias para AppointmentReminderRepository
Pruebas para las funciones: editar cita médica, eliminar cita médica, ver detalle de cita médica
python -m pytest tests/test_appointment_reminder_repository.py -v
"""
import unittest
from unittest.mock import Mock, MagicMock
from datetime import datetime
from app.repositories.appointment_reminder_repo import AppointmentReminderRepository
from app.models.appointment_reminder import AppointmentReminder


class TestAppointmentReminderRepositoryGet(unittest.TestCase):
    """
    Clase de pruebas para el método get (ver detalle) de AppointmentReminderRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = AppointmentReminderRepository(db=self.db_mock)

    def test_obtener_cita_existente_por_id(self):
        """
        Test 1: Obtener detalle de cita médica existente
        Verifica que se retorne correctamente el objeto completo
        """
        # Arrange
        reminder_id = 1
        
        # Mock de la cita médica
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = reminder_id
        reminder_mock.user_id = 10
        reminder_mock.clinic_id = 5
        reminder_mock.doctor_id = 3
        reminder_mock.starts_at = datetime(2025, 12, 1, 14, 30)
        reminder_mock.notes = "Consulta general"
        reminder_mock.status = "PENDIENTE"
        
        # Configurar db.get para retornar el mock
        self.db_mock.get = Mock(return_value=reminder_mock)
        
        # Act
        result = self.repository.get(reminder_id)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(result.id, reminder_id)
        self.assertEqual(result.status, "PENDIENTE")
        self.db_mock.get.assert_called_once_with(AppointmentReminder, reminder_id)

    def test_obtener_cita_inexistente_retorna_none(self):
        """
        Test 2: Obtener cita que no existe retorna None
        Verifica el manejo de IDs inexistentes
        """
        # Arrange
        reminder_id = 999
        
        # db.get retorna None cuando no encuentra
        self.db_mock.get = Mock(return_value=None)
        
        # Act
        result = self.repository.get(reminder_id)
        
        # Assert
        self.assertIsNone(result)
        self.db_mock.get.assert_called_once_with(AppointmentReminder, reminder_id)

    def test_obtener_cita_con_relaciones_cargadas(self):
        """
        Test 3: Obtener cita con relaciones (clinic, doctor, specialty)
        Verifica que se puedan acceder a las relaciones del objeto
        """
        # Arrange
        reminder_id = 2
        
        # Mock de objetos relacionados
        clinic_mock = Mock()
        clinic_mock.nombre = "Clínica Central"
        
        doctor_mock = Mock()
        doctor_mock.nombre = "Dr. Smith"
        
        specialty_mock = Mock()
        specialty_mock.nombre = "Cardiología"
        
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = reminder_id
        reminder_mock.clinic = clinic_mock
        reminder_mock.doctor = doctor_mock
        reminder_mock.specialty = specialty_mock
        
        self.db_mock.get = Mock(return_value=reminder_mock)
        
        # Act
        result = self.repository.get(reminder_id)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(result.clinic.nombre, "Clínica Central")
        self.assertEqual(result.doctor.nombre, "Dr. Smith")
        self.assertEqual(result.specialty.nombre, "Cardiología")


class TestAppointmentReminderRepositoryUpdate(unittest.TestCase):
    """
    Clase de pruebas para el método update de AppointmentReminderRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = AppointmentReminderRepository(db=self.db_mock)

    def test_actualizar_cita_existente_cambia_notas(self):
        """
        Test 1: Actualizar notas de una cita existente
        Verifica que se actualicen los campos proporcionados
        """
        # Arrange
        reminder_id = 1
        update_data = {"notes": "Traer exámenes previos"}
        
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = reminder_id
        reminder_mock.notes = "Consulta general"
        
        # Mock de repository.get
        self.repository.get = Mock(return_value=reminder_mock)
        
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act
        result = self.repository.update(reminder_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(reminder_mock.notes, "Traer exámenes previos")
        self.db_mock.commit.assert_called_once()
        self.db_mock.refresh.assert_called_once_with(reminder_mock)

    def test_actualizar_cita_inexistente_retorna_none(self):
        """
        Test 2: Actualizar cita que no existe retorna None
        Verifica que no se intente actualizar si no existe
        """
        # Arrange
        reminder_id = 999
        update_data = {"notes": "Nueva nota"}
        
        self.repository.get = Mock(return_value=None)
        
        # Act
        result = self.repository.update(reminder_id, update_data)
        
        # Assert
        self.assertIsNone(result)
        self.db_mock.commit.assert_not_called()

    def test_actualizar_multiples_campos_de_cita(self):
        """
        Test 3: Actualizar múltiples campos simultáneamente
        Verifica que se actualicen todos los campos del diccionario
        """
        # Arrange
        reminder_id = 3
        new_datetime = datetime(2025, 12, 15, 10, 0)
        update_data = {
            "starts_at": new_datetime,
            "notes": "Cita reprogramada",
            "doctor_id": 5
        }
        
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = reminder_id
        reminder_mock.starts_at = datetime(2025, 12, 1, 14, 0)
        reminder_mock.notes = "Nota original"
        reminder_mock.doctor_id = 3
        
        # Mock hasattr para simular que los campos existen
        def mock_hasattr(obj, field):
            return field in ['id', 'starts_at', 'notes', 'doctor_id', 'user_id', 'status']
        
        self.repository.get = Mock(return_value=reminder_mock)
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act
        with unittest.mock.patch('builtins.hasattr', side_effect=mock_hasattr):
            result = self.repository.update(reminder_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(reminder_mock.starts_at, new_datetime)
        self.assertEqual(reminder_mock.notes, "Cita reprogramada")
        self.assertEqual(reminder_mock.doctor_id, 5)


class TestAppointmentReminderRepositoryDelete(unittest.TestCase):
    """
    Clase de pruebas para el método delete de AppointmentReminderRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = AppointmentReminderRepository(db=self.db_mock)

    def test_eliminar_cita_existente_exitosamente(self):
        """
        Test 1: Eliminar cita médica existente
        Verifica que se elimine correctamente de la base de datos
        """
        # Arrange
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = 1
        reminder_mock.user_id = 10
        
        self.db_mock.delete = Mock()
        self.db_mock.commit = Mock()
        
        # Act
        self.repository.delete(reminder_mock)
        
        # Assert
        self.db_mock.delete.assert_called_once_with(reminder_mock)
        self.db_mock.commit.assert_called_once()

    def test_eliminar_cita_llama_commit_una_vez(self):
        """
        Test 2: Verificar que delete llama commit exactamente una vez
        Asegura la atomicidad de la operación
        """
        # Arrange
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = 2
        
        self.db_mock.delete = Mock()
        self.db_mock.commit = Mock()
        
        # Act
        self.repository.delete(reminder_mock)
        
        # Assert
        self.assertEqual(self.db_mock.delete.call_count, 1)
        self.assertEqual(self.db_mock.commit.call_count, 1)

    def test_eliminar_cita_con_error_db_propaga_excepcion(self):
        """
        Test 3: Error en base de datos durante delete propaga excepción
        Verifica el manejo de errores de la base de datos
        """
        # Arrange
        reminder_mock = Mock(spec=AppointmentReminder)
        reminder_mock.id = 3
        
        self.db_mock.delete = Mock(side_effect=Exception("Database connection error"))
        
        # Act & Assert
        with self.assertRaises(Exception) as context:
            self.repository.delete(reminder_mock)
        
        self.assertIn("Database connection error", str(context.exception))
        self.db_mock.delete.assert_called_once()
        self.db_mock.commit.assert_not_called()


if __name__ == '__main__':
    unittest.main()
