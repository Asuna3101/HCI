"""
Interfaz simplificada de servicio medicamento usuario
"""
from abc import ABC, abstractmethod
from typing import Optional, List


class IMedicamentoUsuarioService(ABC):
    """Interfaz del servicio simplificada de servicio medicamento usuario"""
    
    @abstractmethod
    def registrar_medicamento_usuario(self, id_usuario: int, data) -> dict:
        """Registrar medicamento para un usuario"""
        pass
    
    @abstractmethod
    def obtener_medicamentos_por_usuario(self, id_usuario: int) -> Optional[list]:
        """Obtener medicamentos por usuario"""
        pass

    @abstractmethod
    def actualizar_medicamento_usuario(self, id_usuario: int, id_medicamento_usuario: int, data) -> dict:
        """Actualizar un registro de medicamento asociado a un usuario en la base de datos.
        """
        pass

    @abstractmethod
    def eliminar_medicamento_usuario(self, id_usuario: int, id_medicamento_usuario: int) -> bool:
        """Eliminar un registro medicamento-usuario si pertenece al usuario.
        """
        pass

    @abstractmethod
    def eliminar_lista_medicamento_usuario(self, id_usuario: int, ids: List[int]) -> dict:
        """Eliminar múltiples registros medicamento-usuario por sus IDs.
        """
        pass