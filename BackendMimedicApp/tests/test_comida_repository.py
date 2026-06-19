"""
Pruebas unitarias para ComidaRepository
Pruebas para las funciones: crear comida, editar comida, eliminar comida
python -m pytest tests/test_comida_repository.py -v
"""
import unittest
from unittest.mock import Mock, MagicMock
from app.repositories.comidas_repo import ComidaRepository
from app.models.comidas import Alimento


class TestComidaRepositoryCreate(unittest.TestCase):
    """
    Clase de pruebas para el método create de ComidaRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = ComidaRepository(db=self.db_mock)

    def test_crear_comida_exitosamente(self):
        """
        Test 1: Crear comida exitosamente con nombre válido
        Verifica que se cree un alimento con el nombre proporcionado
        """
        # Arrange
        nombre = "Manzana"
        detalles = None
        
        # Mock del alimento creado
        alimento_mock = Mock(spec=Alimento)
        alimento_mock.id = 1
        alimento_mock.nombre = nombre
        
        # Configurar comportamiento del db_mock
        self.db_mock.add = Mock()
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock(side_effect=lambda x: setattr(x, 'id', 1))
        
        # Act
        with unittest.mock.patch('app.repositories.comidas_repo.Alimento') as AlimentoMock:
            AlimentoMock.return_value = alimento_mock
            result = self.repository.create(nombre, detalles)
        
        # Assert
        self.assertEqual(result.nombre, nombre)
        self.db_mock.add.assert_called_once()
        self.db_mock.commit.assert_called_once()
        self.db_mock.refresh.assert_called_once()

    def test_crear_comida_con_nombre_vacio_retorna_objeto(self):
        """
        Test 2: Crear comida con nombre vacío aún genera objeto
        El repositorio no valida, solo crea el objeto con lo que recibe
        """
        # Arrange
        nombre = ""
        
        alimento_mock = Mock(spec=Alimento)
        alimento_mock.nombre = nombre
        
        self.db_mock.add = Mock()
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act
        with unittest.mock.patch('app.repositories.comidas_repo.Alimento') as AlimentoMock:
            AlimentoMock.return_value = alimento_mock
            result = self.repository.create(nombre)
        
        # Assert
        self.assertEqual(result.nombre, "")
        self.db_mock.add.assert_called_once()

    def test_crear_comida_con_commit_fallido_propaga_excepcion(self):
        """
        Test 3: Error en commit propaga la excepción
        Verifica que errores de base de datos se propaguen correctamente
        """
        # Arrange
        nombre = "Banana"
        
        self.db_mock.add = Mock()
        self.db_mock.commit = Mock(side_effect=Exception("DB Error"))
        
        alimento_mock = Mock(spec=Alimento)
        
        # Act & Assert
        with unittest.mock.patch('app.repositories.comidas_repo.Alimento') as AlimentoMock:
            AlimentoMock.return_value = alimento_mock
            with self.assertRaises(Exception) as context:
                self.repository.create(nombre)
            
            self.assertIn("DB Error", str(context.exception))
            self.db_mock.add.assert_called_once()


class TestComidaRepositoryUpdate(unittest.TestCase):
    """
    Clase de pruebas para el método update de ComidaRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = ComidaRepository(db=self.db_mock)

    def test_actualizar_comida_existente_exitosamente(self):
        """
        Test 1: Actualizar comida existente con nuevos datos
        Verifica que se actualicen los campos correctamente
        """
        # Arrange
        id_comida = 1
        nuevo_nombre = "Manzana Verde"
        
        # Mock del alimento existente
        alimento_existente = Mock(spec=Alimento)
        alimento_existente.id = id_comida
        alimento_existente.nombre = "Manzana"
        
        # Simular hasattr
        def mock_hasattr(obj, name):
            return name in ['id', 'nombre', 'createdAt', 'updatedAt']
        
        # Mock de get_by_id que retorna el alimento
        self.repository.get_by_id = Mock(return_value=alimento_existente)
        
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act
        with unittest.mock.patch('builtins.hasattr', side_effect=mock_hasattr):
            result = self.repository.update(id_comida, nombre=nuevo_nombre)
        
        # Assert
        self.assertIsNotNone(result)
        self.assertEqual(alimento_existente.nombre, nuevo_nombre)
        self.db_mock.commit.assert_called_once()
        self.db_mock.refresh.assert_called_once_with(alimento_existente)

    def test_actualizar_comida_inexistente_retorna_none(self):
        """
        Test 2: Actualizar comida que no existe retorna None
        Verifica el manejo de IDs inexistentes
        """
        # Arrange
        id_inexistente = 999
        
        # Mock de get_by_id que retorna None
        self.repository.get_by_id = Mock(return_value=None)
        
        # Act
        result = self.repository.update(id_inexistente, nombre="Nuevo Nombre")
        
        # Assert
        self.assertIsNone(result)
        self.db_mock.commit.assert_not_called()

    def test_actualizar_comida_ignora_valores_none(self):
        """
        Test 3: Actualizar comida ignorando valores None
        Verifica que solo se actualicen campos con valores no None
        """
        # Arrange
        id_comida = 2
        
        alimento_existente = Mock(spec=Alimento)
        alimento_existente.id = id_comida
        alimento_existente.nombre = "Naranja"
        nombre_original = alimento_existente.nombre
        
        self.repository.get_by_id = Mock(return_value=alimento_existente)
        
        def mock_hasattr(obj, name):
            return name in ['id', 'nombre']
        
        self.db_mock.commit = Mock()
        self.db_mock.refresh = Mock()
        
        # Act - pasar None como valor
        with unittest.mock.patch('builtins.hasattr', side_effect=mock_hasattr):
            result = self.repository.update(id_comida, nombre=None)
        
        # Assert
        # Como v es None, no se debe modificar el nombre
        self.assertEqual(alimento_existente.nombre, nombre_original)
        self.db_mock.commit.assert_called_once()


class TestComidaRepositoryDelete(unittest.TestCase):
    """
    Clase de pruebas para el método delete de ComidaRepository
    """

    def setUp(self):
        """Configuración inicial para cada test"""
        self.db_mock = Mock()
        self.repository = ComidaRepository(db=self.db_mock)

    def test_eliminar_comida_existente_exitosamente(self):
        """
        Test 1: Eliminar comida existente retorna True
        Verifica que la eliminación sea exitosa
        """
        # Arrange
        id_comida = 1
        
        alimento_existente = Mock(spec=Alimento)
        alimento_existente.id = id_comida
        
        self.repository.get_by_id = Mock(return_value=alimento_existente)
        self.db_mock.delete = Mock()
        self.db_mock.commit = Mock()
        
        # Act
        result = self.repository.delete(id_comida)
        
        # Assert
        self.assertTrue(result)
        self.db_mock.delete.assert_called_once_with(alimento_existente)
        self.db_mock.commit.assert_called_once()

    def test_eliminar_comida_inexistente_retorna_false(self):
        """
        Test 2: Eliminar comida que no existe retorna False
        Verifica el manejo de IDs inexistentes sin error
        """
        # Arrange
        id_inexistente = 999
        
        self.repository.get_by_id = Mock(return_value=None)
        
        # Act
        result = self.repository.delete(id_inexistente)
        
        # Assert
        self.assertFalse(result)
        self.db_mock.delete.assert_not_called()
        self.db_mock.commit.assert_not_called()

    def test_eliminar_comida_con_error_db_propaga_excepcion(self):
        """
        Test 3: Error en base de datos durante delete propaga excepción
        Verifica que errores de DB se manejen apropiadamente
        """
        # Arrange
        id_comida = 3
        
        alimento_existente = Mock(spec=Alimento)
        
        self.repository.get_by_id = Mock(return_value=alimento_existente)
        self.db_mock.delete = Mock(side_effect=Exception("Foreign key constraint"))
        
        # Act & Assert
        with self.assertRaises(Exception) as context:
            self.repository.delete(id_comida)
        
        self.assertIn("Foreign key constraint", str(context.exception))
        self.db_mock.delete.assert_called_once()
        self.db_mock.commit.assert_not_called()


if __name__ == '__main__':
    unittest.main()
