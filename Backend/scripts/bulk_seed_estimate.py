"""Carga masiva sintética para CEOS y estimación de espacio.

Uso ejemplo:
  python scripts/bulk_seed_estimate.py --materials 2000 --users 120 --movements 300000 --solicitudes 80000 --reset

Por defecto usa SQLite en: sqlite:///./ceos_load_estimate.db
También acepta PostgreSQL con --database-url y medirá tamaño con pg_database_size.
"""

from __future__ import annotations

import argparse
import os
import random
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

REPO_BACKEND = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(REPO_BACKEND))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Carga masiva sintética + estimación de espacio de BD")
    parser.add_argument("--materials", type=int, default=2000)
    parser.add_argument("--users", type=int, default=120)
    parser.add_argument("--movements", type=int, default=300000)
    parser.add_argument("--solicitudes", type=int, default=80000)
    parser.add_argument("--batch-size", type=int, default=5000)
    parser.add_argument("--database-url", type=str, default="sqlite:///./ceos_load_estimate.db")
    parser.add_argument("--reset", action="store_true", help="Borra tablas de destino antes de cargar")
    return parser.parse_args()


def sqlite_path_from_url(database_url: str) -> Path | None:
    if not database_url.startswith("sqlite:///"):
        return None
    return Path(database_url.replace("sqlite:///", "")).resolve()


def human_mb(bytes_size: int) -> float:
    return round(bytes_size / (1024 * 1024), 2)


def main() -> None:
    args = parse_args()
    os.environ["DATABASE_URL"] = args.database_url

    from sqlalchemy import text

    from app.database.base import Base
    from app.database.session import SessionLocal, engine
    from app.models.enums import EstadoSolicitudEnum, RoleEnum, TipoMovimientoEnum
    from app.models.material import Material
    from app.models.movimiento import MovimientoInventario
    from app.models.solicitud import SolicitudMaterial
    from app.models.usuario import Usuario

    sqlite_path = sqlite_path_from_url(args.database_url)
    if sqlite_path:
        sqlite_path.parent.mkdir(parents=True, exist_ok=True)

    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        if args.reset:
            db.query(MovimientoInventario).delete()
            db.query(SolicitudMaterial).delete()
            db.query(Material).delete()
            db.query(Usuario).delete()
            db.commit()

        before_size_bytes = None
        if sqlite_path and sqlite_path.exists():
            before_size_bytes = sqlite_path.stat().st_size
        elif not sqlite_path:
            before_size_bytes = db.execute(text("SELECT pg_database_size(current_database())")).scalar_one()

        # Usuarios
        users = []
        roles = [RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO, RoleEnum.DOCTOR]
        for i in range(args.users):
            users.append(
                Usuario(
                    nombre=f"Usuario {i}",
                    email=f"user{i}@seed.ceos",
                    hashed_password="$2b$12$abcdefghijklmnopqrstuv1234567890abcdefghijklmn",
                    rol=roles[i % len(roles)],
                )
            )
        db.bulk_save_objects(users)
        db.commit()

        # Materiales
        materials = []
        for i in range(args.materials):
            materials.append(
                Material(
                    nombre=f"Material {i}",
                    categoria=f"Categoria {i % 20}",
                    stock_actual=random.randint(0, 600),
                    stock_minimo=random.randint(5, 40),
                    fecha_vencimiento=date(2028, 12, 31),
                    fecha_alerta_vencimiento=date(2028, 11, 30),
                )
            )
        db.bulk_save_objects(materials)
        db.commit()

        user_ids = [row[0] for row in db.query(Usuario.id).all()]
        material_ids = [row[0] for row in db.query(Material.id).all()]

        # Movimientos (por lotes)
        base_time = datetime(2026, 1, 1)
        for start in range(0, args.movements, args.batch_size):
            chunk = []
            end = min(start + args.batch_size, args.movements)
            for i in range(start, end):
                chunk.append(
                    MovimientoInventario(
                        material_id=random.choice(material_ids),
                        tipo=[TipoMovimientoEnum.ENTRADA, TipoMovimientoEnum.SALIDA, TipoMovimientoEnum.AJUSTE][i % 3],
                        cantidad=random.randint(1, 25),
                        fecha=base_time + timedelta(minutes=i),
                        usuario_id=random.choice(user_ids),
                    )
                )
            db.bulk_save_objects(chunk)
            db.commit()

        # Solicitudes (por lotes)
        for start in range(0, args.solicitudes, args.batch_size):
            chunk = []
            end = min(start + args.batch_size, args.solicitudes)
            for i in range(start, end):
                chunk.append(
                    SolicitudMaterial(
                        material_id=random.choice(material_ids),
                        cantidad=random.randint(1, 12),
                        motivo="Consumo clínico diario",
                        estado=[EstadoSolicitudEnum.PENDIENTE, EstadoSolicitudEnum.APROBADA, EstadoSolicitudEnum.RECHAZADA][
                            i % 3
                        ],
                        solicitante_id=random.choice(user_ids),
                        fecha_creacion=base_time + timedelta(hours=i),
                    )
                )
            db.bulk_save_objects(chunk)
            db.commit()

        after_size_bytes = None
        if sqlite_path and sqlite_path.exists():
            after_size_bytes = sqlite_path.stat().st_size
        elif not sqlite_path:
            after_size_bytes = db.execute(text("SELECT pg_database_size(current_database())")).scalar_one()

        inserted_rows = args.materials + args.users + args.movements + args.solicitudes
        delta = (after_size_bytes - before_size_bytes) if (before_size_bytes is not None and after_size_bytes is not None) else None

        print("=== CEOS bulk seed report ===")
        print(f"database_url: {args.database_url}")
        print(f"rows_inserted: {inserted_rows}")
        print(
            f"breakdown: materials={args.materials}, users={args.users}, movements={args.movements}, solicitudes={args.solicitudes}"
        )

        if before_size_bytes is not None and after_size_bytes is not None:
            print(f"size_before_bytes: {before_size_bytes} ({human_mb(before_size_bytes)} MB)")
            print(f"size_after_bytes: {after_size_bytes} ({human_mb(after_size_bytes)} MB)")
            print(f"size_delta_bytes: {delta} ({human_mb(delta)} MB)")
            if inserted_rows > 0:
                kb_per_1000 = (delta / 1024) / (inserted_rows / 1000)
                print(f"density_kb_per_1000_rows: {round(kb_per_1000, 2)}")
        else:
            print("No fue posible medir tamaño antes/después para este motor")

    finally:
        db.close()


if __name__ == "__main__":
    main()
