"""
Pruebas unitarias para EjercicioUsuarioRepository.check_horario_conflict
Complejidad ciclomática: 5
python -m pytest tests/test_ejercicioUsuario_repository.py -v
"""
import unittest
from unittest.mock import Mock, MagicMock
from datetime import time
from app.repositories.ejercicioUsuario_repo import EjercicioUsuarioRepository


class TestCheckHorarioConflict(unittest.TestCase):
    """
    Clase de pruebas para el método check_horario_conflict
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = EjercicioUsuarioRepository(db=self.db_mock)

    def test_sin_conflicto_horarios_no_solapados(self):
        """
        Test 1: No hay conflicto - horarios no se solapan
        Camino: Itera sobre ejercicios existentes pero no encuentra solapamiento
        """
        # Arrange
        id_usuario = 1
        nuevo_horario = time(14, 0)  # 14:00
        duracion = 30  # 30 minutos (14:00 - 14:30)
        
        # Mock de ejercicio existente sin conflicto (10:00 - 11:00)
        ejercicio_existente = Mock()
        ejercicio_existente.horario = time(10, 0)
        ejercicio_existente.duracion_min = 60
        
        # Mock de la query
        query_mock = MagicMock()
        query_mock.all.return_value = [ejercicio_existente]
        
        filter_mock = MagicMock()
        filter_mock.all.return_value = [ejercicio_existente]
        
        query_mock.filter.return_value = filter_mock
        self.db_mock.query.return_value = query_mock
        
        # Act
        result = self.repository.check_horario_conflict(id_usuario, nuevo_horario, duracion)
        
        # Assert
        self.assertFalse(result)  # No hay conflicto
        self.db_mock.query.assert_called_once()

    def test_con_conflicto_horarios_solapados(self):
        """
        Test 2: Hay conflicto - horarios se solapan
        Camino: Encuentra solapamiento y retorna True en el if
        """
        # Arrange
        id_usuario = 2
        nuevo_horario = time(10, 30)  # 10:30
        duracion = 60  # 60 minutos (10:30 - 11:30)
        
        # Mock de ejercicio existente con conflicto (10:00 - 11:00)
        # Solapamiento: 10:30 - 11:00
        ejercicio_conflicto = Mock()
        ejercicio_conflicto.horario = time(10, 0)
        ejercicio_conflicto.duracion_min = 60
        
        # Mock de la query
        query_mock = MagicMock()
        filter_mock = MagicMock()
        filter_mock.all.return_value = [ejercicio_conflicto]
        query_mock.filter.return_value = filter_mock
        self.db_mock.query.return_value = query_mock
        
        # Act
        result = self.repository.check_horario_conflict(id_usuario, nuevo_horario, duracion)
        
        # Assert
        self.assertTrue(result)  # Hay conflicto
        self.db_mock.query.assert_called_once()

    def test_excluir_ejercicio_actual_sin_conflicto(self):
        """
        Test 3: Excluir ejercicio actual - sin conflicto con otros
        Camino: Entra en if exclude_id, excluye el ejercicio actual
        """
        # Arrange
        id_usuario = 3
        nuevo_horario = time(15, 0)
        duracion = 45
        exclude_id = 10  # ID del ejercicio a excluir
        
        # Mock de ejercicio que será excluido (mismo horario)
        ejercicio_actual = Mock()
        ejercicio_actual.id = exclude_id
        ejercicio_actual.horario = time(15, 0)
        ejercicio_actual.duracion_min = 45
        
        # Mock de la query con filtro de exclusión
        query_mock = MagicMock()
        filter1_mock = MagicMock()
        filter2_mock = MagicMock()
        
        # Primera llamada a filter (idUsuario)
        query_mock.filter.return_value = filter1_mock
        # Segunda llamada a filter (exclude_id)
        filter1_mock.filter.return_value = filter2_mock
        # No retorna el ejercicio excluido
        filter2_mock.all.return_value = []
        
        self.db_mock.query.return_value = query_mock
        
        # Act
        result = self.repository.check_horario_conflict(
            id_usuario, nuevo_horario, duracion, exclude_id=exclude_id
        )
        
        # Assert
        self.assertFalse(result)  # No hay conflicto (se excluyó el actual)
        # Verificar que se llamó filter dos veces (usuario y exclude_id)
        self.assertEqual(query_mock.filter.call_count, 1)
        self.assertEqual(filter1_mock.filter.call_count, 1)

    def test_ejercicio_sin_horario_o_duracion_no_causa_conflicto(self):
        """
        Test 4: Ejercicio existente sin horario o duración - no genera conflicto
        Camino: Entra en el for pero no en el if (ej.horario and ej.duracion_min)
        """
        # Arrange
        id_usuario = 4
        nuevo_horario = time(12, 0)
        duracion = 30
        
        # Mock de ejercicio sin horario definido
        ejercicio_sin_horario = Mock()
        ejercicio_sin_horario.horario = None
        ejercicio_sin_horario.duracion_min = 30
        
        # Mock de ejercicio sin duración definida
        ejercicio_sin_duracion = Mock()
        ejercicio_sin_duracion.horario = time(12, 0)
        ejercicio_sin_duracion.duracion_min = None
        
        # Mock de la query
        query_mock = MagicMock()
        filter_mock = MagicMock()
        filter_mock.all.return_value = [ejercicio_sin_horario, ejercicio_sin_duracion]
        query_mock.filter.return_value = filter_mock
        self.db_mock.query.return_value = query_mock
        
        # Act
        result = self.repository.check_horario_conflict(id_usuario, nuevo_horario, duracion)
        
        # Assert
        self.assertFalse(result)  # No hay conflicto (ejercicios sin horario/duración)

    def test_sin_ejercicios_existentes_no_hay_conflicto(self):
        """
        Test 5: No hay ejercicios existentes - no puede haber conflicto
        Camino: El for no se ejecuta porque la lista está vacía
        """
        # Arrange
        id_usuario = 5
        nuevo_horario = time(16, 30)
        duracion = 40
        
        # Mock de la query sin ejercicios
        query_mock = MagicMock()
        filter_mock = MagicMock()
        filter_mock.all.return_value = []  # Lista vacía
        query_mock.filter.return_value = filter_mock
        self.db_mock.query.return_value = query_mock
        
        # Act
        result = self.repository.check_horario_conflict(id_usuario, nuevo_horario, duracion)
        
        # Assert
        self.assertFalse(result)  # No hay conflicto (no hay ejercicios)
        self.db_mock.query.assert_called_once()


if __name__ == '__main__':
    unittest.main()