"""
Repositorio para tomas
"""
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.interfaces.toma_repository_interface import ITomaRepository
from app.models.toma import Toma
from datetime import timedelta


class TomaRepository(ITomaRepository):
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, toma_id: int) -> Toma | None:
        return self.db.query(Toma).filter(Toma.id == toma_id).first()

    def update_tomado(self, toma_id: int, tomado: bool) -> Toma | None:
        toma = self.get_by_id(toma_id)
        if not toma:
            return None
        toma.tomado = tomado
        # updatedAt se actualiza por onupdate=func.now() en el modelo
        self.db.commit()
        self.db.refresh(toma)
        return toma

    def count_pendientes_by_medxuser(self, medxuser_id: int) -> int:
        return (
            self.db.query(func.count(Toma.id))
            .filter(Toma.idMedxUser == medxuser_id, Toma.tomado.is_(False))
            .scalar()
        )

    def delete_all_by_medxuser(self, medxuser_id: int) -> int:
        deleted = (
            self.db.query(Toma)
            .filter(Toma.idMedxUser == medxuser_id)
            .delete(synchronize_session=False)
        )
        self.db.commit()
        return deleted

    def postpone_from(self, toma_id: int, minutes: int) -> int:
        """Postpone the toma with id `toma_id` and all subsequent tomas of the
        same medicamento-usuario by `minutes`. Returns number of updated rows."""
        toma = self.get_by_id(toma_id)
        if not toma:
            return 0

        # Select tomas with same medxuser and adquired >= toma.adquired
        tomas = (
            self.db.query(Toma)
            .filter(Toma.idMedxUser == toma.idMedxUser, Toma.adquired >= toma.adquired)
            .all()
        )

        if not tomas:
            return 0

        delta = timedelta(minutes=minutes)
        for t in tomas:
            # Python-side update to avoid DB-specific interval syntax
            if t.adquired is not None:
                t.adquired = t.adquired + delta

        self.db.commit()
        return len(tomas)

    def get_pending_at(self, at_datetime) -> list[Toma]:
        """Return tomas scheduled within the minute starting at `at_datetime`
        (inclusive) where tomado is False."""
        # Normalize to the minute window: floor seconds and microseconds so
        # we search for tomas scheduled in the same minute as `at_datetime`.
        start = at_datetime.replace(second=0, microsecond=0)
        end = start + timedelta(minutes=1)
        return (
            self.db.query(Toma)
            .filter(Toma.adquired >= start, Toma.adquired < end, Toma.tomado.is_(False))
            .all()
        )
