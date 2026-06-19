"""
Pruebas unitarias para EjercicioUsuarioService.actualizar_ejercicio_usuario
Complejidad ciclomática: 6
python -m pytest tests/test_ejercicioUsuario_service.py -v
"""
import unittest
from unittest.mock import Mock
from datetime import time
from app.services.ejercicioUsuario_service import EjercicioUsuarioService
from app.schemas.ejercicioUsuario import EjercicioUsuarioUpdate


class TestActualizarEjercicioUsuario(unittest.TestCase):
    """
    Clase de pruebas para el método actualizar_ejercicio_usuario
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.ejxuser_repo_mock = Mock()
        self.ejercicio_repo_mock = Mock()
        self.service = EjercicioUsuarioService(
            ejxuser_repo=self.ejxuser_repo_mock,
            ejercicio_repo=self.ejercicio_repo_mock
        )

    def test_actualizar_solo_notas_y_realizado_sin_conflictos(self):
        """
        Test 1: Actualizar campos simples (notas, realizado) sin cambiar horario
        Camino: No entra en validación de nombre ni horario
        """
        # Arrange
        ejxuser_id = 1
        update_data = EjercicioUsuarioUpdate(
            notas="Notas actualizadas",
            realizado=True
        )
        
        # Mock del ejercicio usuario existente
        ejxuser_mock = Mock()
        ejxuser_mock.id = ejxuser_id
        ejxuser_mock.idEjercicio = 10
        ejxuser_mock.notas = "Notas actualizadas"
        ejxuser_mock.horario = time(8, 0)
        ejxuser_mock.duracion_min = 30
        ejxuser_mock.realizado = True
        
        # Mock del ejercicio relacionado
        ejercicio_mock = Mock()
        ejercicio_mock.id = 10
        ejercicio_mock.nombre = "Correr"
        
        self.ejxuser_repo_mock.update.return_value = ejxuser_mock
        self.ejercicio_repo_mock.get_by_id.return_value = ejercicio_mock
        
        # Act
        result = self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(result["id"], ejxuser_id)
        self.assertEqual(result["nombre"], "Correr")
        self.assertEqual(result["notas"], "Notas actualizadas")
        self.assertEqual(result["realizado"], True)
        self.ejxuser_repo_mock.update.assert_called_once()
        # No debe llamar a check_horario_conflict
        self.ejxuser_repo_mock.check_horario_conflict.assert_not_called()

    def test_actualizar_nombre_ejercicio_exitoso(self):
        """
        Test 2: Actualizar el nombre del ejercicio
        Camino: Entra en la condición if "nombre" in update_data
        """
        # Arrange
        ejxuser_id = 2
        update_data = EjercicioUsuarioUpdate(
            nombre="Natación"
        )
        
        # Mock del ejercicio nuevo/existente
        nuevo_ejercicio_mock = Mock()
        nuevo_ejercicio_mock.id = 20
        nuevo_ejercicio_mock.nombre = "Natación"
        
        # Mock del ejercicio usuario actualizado
        ejxuser_mock = Mock()
        ejxuser_mock.id = ejxuser_id
        ejxuser_mock.idEjercicio = 20
        ejxuser_mock.notas = "Ejercicio de natación"
        ejxuser_mock.horario = time(10, 0)
        ejxuser_mock.duracion_min = 45
        ejxuser_mock.realizado = False
        
        self.ejercicio_repo_mock.get_or_create_ejercicio.return_value = nuevo_ejercicio_mock
        self.ejxuser_repo_mock.update.return_value = ejxuser_mock
        self.ejercicio_repo_mock.get_by_id.return_value = nuevo_ejercicio_mock
        
        # Act
        result = self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(result["nombre"], "Natación")
        self.ejercicio_repo_mock.get_or_create_ejercicio.assert_called_once_with("Natación")
        self.ejxuser_repo_mock.update.assert_called_once()

    def test_actualizar_horario_sin_conflicto(self):
        """
        Test 3: Actualizar horario sin conflicto con otros ejercicios
        Camino: Entra en validación de horario, no hay conflicto
        """
        # Arrange
        ejxuser_id = 3
        nuevo_horario = time(14, 30)
        update_data = EjercicioUsuarioUpdate(
            horario=nuevo_horario,
            duracion_min=60
        )
        
        # Mock del ejercicio usuario actual
        ejxuser_actual_mock = Mock()
        ejxuser_actual_mock.id = ejxuser_id
        ejxuser_actual_mock.idUsuario = 100
        ejxuser_actual_mock.idEjercicio = 5
        ejxuser_actual_mock.horario = time(10, 0)
        ejxuser_actual_mock.duracion_min = 30
        
        # Mock del ejercicio usuario actualizado
        ejxuser_actualizado_mock = Mock()
        ejxuser_actualizado_mock.id = ejxuser_id
        ejxuser_actualizado_mock.idEjercicio = 5
        ejxuser_actualizado_mock.horario = nuevo_horario
        ejxuser_actualizado_mock.duracion_min = 60
        ejxuser_actualizado_mock.notas = "Ejercicio intenso"
        ejxuser_actualizado_mock.realizado = False
        
        # Mock del ejercicio
        ejercicio_mock = Mock()
        ejercicio_mock.id = 5
        ejercicio_mock.nombre = "Pesas"
        
        self.ejxuser_repo_mock.get_by_id.return_value = ejxuser_actual_mock
        self.ejxuser_repo_mock.check_horario_conflict.return_value = False  # Sin conflicto
        self.ejxuser_repo_mock.update.return_value = ejxuser_actualizado_mock
        self.ejercicio_repo_mock.get_by_id.return_value = ejercicio_mock
        
        # Act
        result = self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(result["horario"], nuevo_horario)
        self.assertEqual(result["duracion_min"], 60)
        self.ejxuser_repo_mock.check_horario_conflict.assert_called_once_with(
            100, nuevo_horario, 60, exclude_id=ejxuser_id
        )

    def test_actualizar_horario_con_conflicto_lanza_excepcion(self):
        """
        Test 4: Actualizar horario con conflicto - debe lanzar ValueError
        Camino: Entra en validación de horario, detecta conflicto
        """
        # Arrange
        ejxuser_id = 4
        nuevo_horario = time(16, 0)
        update_data = EjercicioUsuarioUpdate(
            horario=nuevo_horario
        )
        
        # Mock del ejercicio usuario actual
        ejxuser_actual_mock = Mock()
        ejxuser_actual_mock.id = ejxuser_id
        ejxuser_actual_mock.idUsuario = 200
        ejxuser_actual_mock.horario = time(10, 0)
        ejxuser_actual_mock.duracion_min = 45
        
        self.ejxuser_repo_mock.get_by_id.return_value = ejxuser_actual_mock
        self.ejxuser_repo_mock.check_horario_conflict.return_value = True  # Hay conflicto
        
        # Act & Assert
        with self.assertRaises(ValueError) as context:
            self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        self.assertEqual(str(context.exception), "Ya tienes un ejercicio programado en ese horario")
        # No debe llegar a llamar update
        self.ejxuser_repo_mock.update.assert_not_called()

    def test_actualizar_ejercicio_no_encontrado_retorna_none(self):
        """
        Test 5: Intentar actualizar un ejercicio que no existe
        Camino: El ejercicio no existe en validación de horario
        """
        # Arrange
        ejxuser_id = 999
        update_data = EjercicioUsuarioUpdate(
            horario=time(18, 0)
        )
        
        self.ejxuser_repo_mock.get_by_id.return_value = None  # No existe
        
        # Act
        result = self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        # Assert
        self.assertIsNone(result)
        self.ejxuser_repo_mock.get_by_id.assert_called_once_with(ejxuser_id)
        # No debe llamar a update ni check_horario_conflict
        self.ejxuser_repo_mock.update.assert_not_called()

    def test_actualizar_ejercicio_update_retorna_none(self):
        """
        Test 6: Update del repositorio retorna None
        Camino: El update falla después de pasar todas las validaciones
        """
        # Arrange
        ejxuser_id = 5
        update_data = EjercicioUsuarioUpdate(
            notas="Notas nuevas"
        )
        
        self.ejxuser_repo_mock.update.return_value = None  # Update falla
        
        # Act
        result = self.service.actualizar_ejercicio_usuario(ejxuser_id, update_data)
        
        # Assert
        self.assertIsNone(result)
        self.ejxuser_repo_mock.update.assert_called_once()
        # No debe intentar obtener el ejercicio si update falla
        self.ejercicio_repo_mock.get_by_id.assert_not_called()


if __name__ == '__main__':
    unittest.main()
