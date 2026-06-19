"""
Interfaz del servicio EjercicioUsuario
"""
from abc import ABC, abstractmethod
from typing import List, Optional


class IEjercicioUsuarioService(ABC):

    @abstractmethod
    def registrar_ejercicio_usuario(self, id_usuario: int, data) -> dict:
        """Registrar un ejercicio para un usuario"""
        pass

    @abstractmethod
    def obtener_ejercicios_usuario(self, id_usuario: int) -> Optional[List[dict]]:
        """Obtener todos los ejercicios del usuario"""
        pass

    @abstractmethod
    def actualizar_ejercicio_usuario(self, ejxuser_id: int, data) -> dict:
        """Actualizar un ejercicio del usuario"""
        pass

    @abstractmethod
    def eliminar_ejercicios_usuario(self, id_usuario: int, ejercicio_ids: list[int]) -> bool:
        """Eliminar múltiples ejercicios del usuario"""
        pass