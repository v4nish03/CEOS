from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.services.inventario_service import InventarioService
from app.services.reporte_service import ReporteService


class ReportExportService:
    @staticmethod
    def _pdf_escape(text: str) -> str:
        return text.replace('\\', '\\\\').replace('(', r'\(').replace(')', r'\)')

    @staticmethod
    def generar_reporte_diario_pdf(db: Session) -> bytes:
        resumen = ReporteService.resumen_inventario(db)
        alertas = InventarioService.obtener_alertas(db)

        lines = [
            'Reporte Diario de Inventario',
            f"Generado UTC: {datetime.now(timezone.utc).isoformat()}",
            f"Total materiales: {resumen['total_materiales']}",
            f"Stock total unidades: {resumen['stock_total_unidades']}",
            f"Materiales en stock bajo: {resumen['materiales_stock_bajo']}",
            'Alertas:',
        ]
        if not alertas:
            lines.append('- Sin alertas activas')
        else:
            for alerta in alertas[:20]:
                lines.append(f"- [{alerta['tipo']}] {alerta['material_nombre']}: {alerta['detalle']}")

        content_lines = ['BT', '/F1 11 Tf', '50 760 Td']
        first = True
        for line in lines:
            esc = ReportExportService._pdf_escape(line)
            if first:
                content_lines.append(f"({esc}) Tj")
                first = False
            else:
                content_lines.append("0 -16 Td")
                content_lines.append(f"({esc}) Tj")
        content_lines.append('ET')
        stream = '\n'.join(content_lines).encode('latin-1', errors='ignore')

        objects = []
        objects.append(b'1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n')
        objects.append(b'2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj\n')
        objects.append(b'3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj\n')
        objects.append(b'4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj\n')
        objects.append(f'5 0 obj << /Length {len(stream)} >> stream\n'.encode() + stream + b'\nendstream endobj\n')

        out = b'%PDF-1.4\n'
        xref = [0]
        for obj in objects:
            xref.append(len(out))
            out += obj
        xref_start = len(out)
        out += f'xref\n0 {len(xref)}\n'.encode()
        out += b'0000000000 65535 f \n'
        for off in xref[1:]:
            out += f'{off:010d} 00000 n \n'.encode()
        out += f'trailer << /Size {len(xref)} /Root 1 0 R >>\nstartxref\n{xref_start}\n%%EOF\n'.encode()
        return out
