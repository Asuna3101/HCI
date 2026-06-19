from datetime import datetime, date, time
from typing import List, Dict, Any
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
import base64
from app.interfaces.report_service_interface import IReportService
from app.models.medicamentoUsuario import MedicamentoUsuario
from app.models.medicamento import Medicamento
from app.models.unidad import Unidad
from app.models.toma import Toma
from app.models.appointment_reminder import AppointmentReminder
from app.models.comidas_usuario import ComidaUsuario
from app.models.comidas import Alimento
from app.models.ejercicioUsuario import EjercicioUsuario
from app.models.ejercicio import Ejercicio


class ReportService(IReportService):
    def __init__(self, db: Session):
        self.db = db

    def get_summary(self, user_id: int) -> Dict[str, Any]:
        events = self._build_timeline(user_id)
        user = self._get_user(user_id)
        photo_b64 = None
        if getattr(user, "photo", None):
            photo_b64 = base64.b64encode(user.photo).decode("utf-8")
        return {
            "user": {
                "id": user.id,
                "nombre": user.nombre,
                "correo": user.correo,
                "fecha_nacimiento": user.fecha_nacimiento,
                "fecha_creacion": user.fecha_creacion,
                "photo": photo_b64,
                "photo_content_type": getattr(user, "photo_content_type", None),
            },
            "timeline": events,
        }

    def get_module_events(self, user_id: int, module: str) -> List[Dict[str, Any]]:
        allowed = {"registro", "medicacion", "toma", "cita", "comida", "ejercicio"}
        if module not in allowed:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Modulo invalido. Usa uno de: {', '.join(sorted(allowed))}",
            )
        events = self._build_timeline(user_id)
        return [e for e in events if e["type"] == module]

    def download_module(self, user_id: int, module: str, fmt: str = "txt") -> tuple[bytes, str, str]:
        filtered = self.get_module_events(user_id, module)
        if fmt == "txt":
            content = self._render_text(module, filtered)
            return content.encode("utf-8"), "text/plain", f"reporte_{module}.txt"
        if fmt == "html":
            content = self._render_html(module, filtered)
            return content.encode("utf-8"), "text/html", f"reporte_{module}.html"
        if fmt == "pdf":
            try:
                content = self._render_pdf(module, filtered)
                return content, "application/pdf", f"reporte_{module}.pdf"
            except ImportError:
                raise HTTPException(status_code=501, detail="PDF no disponible (falta dependencia reportlab)")
        raise HTTPException(status_code=400, detail="Formato inválido. Usa txt|html|pdf")

    # ------- helpers -------
    def _get_user(self, user_id: int):
        from app.models.user import User
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        return user

    def _build_timeline(self, user_id: int) -> List[Dict[str, Any]]:
        events: List[Dict[str, Any]] = []
        user = self._get_user(user_id)
        events.append(
            {
                "type": "registro",
                "title": "Registro inicial",
                "subtitle": "Creaste tu cuenta en MiMedicApp",
                "status": None,
                "date": (user.fecha_creacion or datetime.utcnow()).isoformat(),
            }
        )

        from datetime import timezone
        now = datetime.now(timezone.utc)
        med_rows = (
            self.db.query(MedicamentoUsuario, Medicamento, Unidad)
            .join(Medicamento, Medicamento.id == MedicamentoUsuario.idMedicamento)
            .join(Unidad, Unidad.id == MedicamentoUsuario.idUnidad)
            .filter(MedicamentoUsuario.idUsuario == user_id)
            .all()
        )
        for mxu, med, uni in med_rows:
            events.append(
                {
                    "type": "medicacion",
                    "title": f"Inicio de {med.nombre}",
                    "subtitle": f"Dosis {mxu.dosis} {uni.nombre} • cada {mxu.frecuencia_horas}h",
                    "status": "Plan activo",
                    "date": mxu.fecha_inicio.isoformat(),
                }
            )
            if mxu.fecha_fin and mxu.fecha_fin <= now:
                events.append(
                    {
                        "type": "medicacion",
                        "title": f"Fin de {med.nombre}",
                        "subtitle": "Ciclo concluido",
                        "status": "Finalizado",
                        "date": mxu.fecha_fin.isoformat(),
                    }
                )

        toma_rows = (
            self.db.query(Toma, MedicamentoUsuario, Medicamento, Unidad)
            .join(MedicamentoUsuario, Toma.idMedxUser == MedicamentoUsuario.id)
            .join(Medicamento, Medicamento.id == MedicamentoUsuario.idMedicamento)
            .join(Unidad, Unidad.id == MedicamentoUsuario.idUnidad)
            .filter(MedicamentoUsuario.idUsuario == user_id, Toma.tomado.is_(True))
            .order_by(Toma.adquired.desc())
            .limit(50)
            .all()
        )
        for toma, mxu, med, uni in toma_rows:
            events.append(
                {
                    "type": "toma",
                    "title": f"Toma completada: {med.nombre}",
                    "subtitle": f"{mxu.dosis} {uni.nombre}",
                    "status": "Completado",
                    "date": toma.adquired.isoformat(),
                }
            )

        citas = (
            self.db.query(AppointmentReminder)
            .filter(AppointmentReminder.user_id == user_id)
            .order_by(AppointmentReminder.starts_at.desc())
            .all()
        )
        for c in citas:
            events.append(
                {
                    "type": "cita",
                    "title": f"Cita con {c.doctor.nombre}",
                    "subtitle": f"{c.clinic.nombre} • {c.specialty.nombre}",
                    "status": c.status.title(),
                    "date": c.starts_at.isoformat(),
                }
            )

        comidas = (
            self.db.query(ComidaUsuario, Alimento)
            .join(Alimento, ComidaUsuario.comida_id == Alimento.id)
            .filter(ComidaUsuario.usuario_id == user_id)
            .order_by(ComidaUsuario.createdAt.desc())
            .all()
        )
        for cu, alimento in comidas:
            events.append(
                {
                    "type": "comida",
                    "title": "Registro de comida",
                    "subtitle": alimento.nombre,
                    "status": None,
                    "date": cu.createdAt.isoformat(),
                }
            )

        ejercicios = (
            self.db.query(EjercicioUsuario, Ejercicio)
            .join(Ejercicio, Ejercicio.id == EjercicioUsuario.idEjercicio)
            .filter(
                EjercicioUsuario.idUsuario == user_id,
                EjercicioUsuario.realizado.is_(True),
            )
            .order_by(EjercicioUsuario.createdAt.desc())
            .all()
        )
        for ej, ej_cat in ejercicios:
            events.append(
                {
                    "type": "ejercicio",
                    "title": f"Ejercicio completado: {ej_cat.nombre}",
                    "subtitle": ej.notas or "",
                    "status": "Realizado",
                    "date": self._combine_date_time(
                        ej.ultimo_realizado or ej.createdAt, ej.horario
                    ).isoformat(),
                }
            )

        events.sort(key=lambda e: e["date"], reverse=True)
        return events

    def _combine_date_time(self, d: datetime | date | None, t: time | None) -> datetime:
        if d is None and t is None:
            return datetime.utcnow()
        if isinstance(d, datetime):
            base_date = d
        elif isinstance(d, date):
            base_date = datetime(d.year, d.month, d.day, tzinfo=None)
        else:
            base_date = datetime.utcnow()
        if t is None:
            return base_date
        return datetime(
            base_date.year, base_date.month, base_date.day, t.hour, t.minute, t.second
        )

    # ----- renders -----
    def _render_text(self, module: str, filtered: List[Dict[str, Any]]) -> str:
        lines = [
            f"Informe de {module}\n",
            f"Total eventos: {len(filtered)}\n",
        ]
        for ev in filtered:
            lines.append(
                f"- {ev['date']} | {ev['title']} | {ev['subtitle']} | {ev.get('status','')}"
            )
        return "\n".join(lines)

    def _render_html(self, module: str, filtered: List[Dict[str, Any]]) -> str:
        rows = "\n".join(
            [
                f"<tr><td>{ev['date']}</td><td>{ev['title']}</td><td>{ev['subtitle']}</td><td>{ev.get('status','')}</td></tr>"
                for ev in filtered
            ]
        )
        return f"""<!doctype html>
<html><head><meta charset="utf-8"><title>Reporte {module}</title>
<style>table{{border-collapse:collapse;width:100%;}}td,th{{border:1px solid #ddd;padding:8px;}}</style>
</head><body>
<h2>Reporte de {module}</h2>
<p>Total eventos: {len(filtered)}</p>
<table>
<tr><th>Fecha</th><th>Título</th><th>Detalle</th><th>Estado</th></tr>
{rows}
</table>
</body></html>"""

    def _render_pdf(self, module: str, filtered: List[Dict[str, Any]]) -> bytes:
        from reportlab.lib.pagesizes import letter
        from reportlab.pdfgen import canvas
        from io import BytesIO

        buffer = BytesIO()
        c = canvas.Canvas(buffer, pagesize=letter)
        width, height = letter
        y = height - 50
        c.setFont("Helvetica-Bold", 14)
        c.drawString(50, y, f"Reporte de {module}")
        y -= 20
        c.setFont("Helvetica", 10)
        for ev in filtered:
            line = f"{ev['date']} | {ev['title']} | {ev['subtitle']} | {ev.get('status','')}"
            if y < 50:
                c.showPage()
                y = height - 50
                c.setFont("Helvetica", 10)
            c.drawString(50, y, line[:200])
            y -= 14
        c.save()
        pdf = buffer.getvalue()
        buffer.close()
        return pdf
