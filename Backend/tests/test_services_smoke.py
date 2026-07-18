from app.services.report_export_service import ReportExportService
from app.services.solicitud_service import SolicitudService
from app.schemas.solicitud import SolicitudCreate
from app.models.material import Material
import pytest


def test_pdf_builder_generates_non_empty_pdf(monkeypatch):
    class DummyDB:
        pass

    from app.services import reporte_service, inventario_service

    monkeypatch.setattr(reporte_service.ReporteService, "resumen_inventario", staticmethod(lambda db: {"total_materiales": 1, "stock_total_unidades": 10, "materiales_stock_bajo": 0}))
    monkeypatch.setattr(inventario_service.InventarioService, "obtener_alertas", staticmethod(lambda db: []))

    pdf = ReportExportService.generar_reporte_diario_pdf(DummyDB())
    assert pdf.startswith(b"%PDF-1.4")
    assert len(pdf) > 100


def test_crear_solicitud_insuficiente_stock_raises_value_error(monkeypatch):
    class DummyDB:
        def get(self, model, id):
            if model == Material:
                # Return material with stock 5
                m = Material(id=1, nombre="Jeringas", stock_actual=5, stock_minimo=2)
                return m
            return None

    db = DummyDB()
    payload = SolicitudCreate(material_id=1, cantidad=10, motivo="Prueba")
    
    with pytest.raises(ValueError) as exc:
        SolicitudService.crear(db, payload, solicitante_id=1)
    
    assert "La cantidad solicitada supera el stock disponible" in str(exc.value)

