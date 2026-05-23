from datetime import datetime, timedelta, timezone
from pathlib import Path
import threading
import time

from app.database.session import SessionLocal
from app.services.report_export_service import ReportExportService


class SchedulerService:
    _thread: threading.Thread | None = None
    _stop_event: threading.Event | None = None

    @classmethod
    def start(cls, hour: int, minute: int, output_dir: str) -> None:
        if cls._thread and cls._thread.is_alive():
            return
        cls._stop_event = threading.Event()
        cls._thread = threading.Thread(
            target=cls._run_loop,
            kwargs={"hour": hour, "minute": minute, "output_dir": output_dir, "stop_event": cls._stop_event},
            daemon=True,
            name="daily-report-scheduler",
        )
        cls._thread.start()

    @classmethod
    def shutdown(cls) -> None:
        if cls._stop_event is not None:
            cls._stop_event.set()

    @staticmethod
    def _run_loop(hour: int, minute: int, output_dir: str, stop_event: threading.Event) -> None:
        while not stop_event.is_set():
            now = datetime.now(timezone.utc)
            target = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
            if target <= now:
                target = target + timedelta(days=1)
            sleep_seconds = (target - now).total_seconds()
            if stop_event.wait(timeout=max(1, sleep_seconds)):
                break
            SchedulerService._job_generate_daily_report(output_dir)

    @staticmethod
    def _job_generate_daily_report(output_dir: str) -> None:
        db = SessionLocal()
        try:
            pdf_data = ReportExportService.generar_reporte_diario_pdf(db)
            folder = Path(output_dir)
            folder.mkdir(parents=True, exist_ok=True)
            (folder / "reporte_diario_latest.pdf").write_bytes(pdf_data)
        finally:
            db.close()
