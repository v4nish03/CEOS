from app.services.report_export_service import ReportExportService


def test_pdf_builder_generates_non_empty_pdf(monkeypatch):
    class DummyDB:
        pass

    from app.services import reporte_service, inventario_service

    monkeypatch.setattr(reporte_service.ReporteService, "resumen_inventario", staticmethod(lambda db: {"total_materiales": 1, "stock_total_unidades": 10, "materiales_stock_bajo": 0}))
    monkeypatch.setattr(inventario_service.InventarioService, "obtener_alertas", staticmethod(lambda db: []))

    pdf = ReportExportService.generar_reporte_diario_pdf(DummyDB())
    assert pdf.startswith(b"%PDF-1.4")
    assert len(pdf) > 100
