-- ============================================================
-- Ecommify Platform — Índices y Optimización
-- Archivo: 002_create_indexes.sql
-- ============================================================

-- ── usuarios ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_usuarios_email       ON usuarios (email);
CREATE INDEX IF NOT EXISTS idx_usuarios_estado      ON usuarios (estado);

-- ── productos ─────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_productos_categoria  ON productos (categoria_id);
CREATE INDEX IF NOT EXISTS idx_productos_precio     ON productos (precio);
CREATE INDEX IF NOT EXISTS idx_productos_tags       ON productos USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_productos_atributos  ON productos USING GIN (atributos);
-- Búsqueda textual con trigramas (requiere pg_trgm)
CREATE INDEX IF NOT EXISTS idx_productos_nombre_trgm ON productos USING GIN (nombre gin_trgm_ops);

-- ── inventarios ───────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_inventarios_producto ON inventarios (producto_id);
CREATE INDEX IF NOT EXISTS idx_inventarios_stock    ON inventarios (stock) WHERE stock > 0;

-- ── ordenes ───────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_ordenes_usuario      ON ordenes (usuario_id, fecha_creacion DESC);
CREATE INDEX IF NOT EXISTS idx_ordenes_estado       ON ordenes (estado, fecha_creacion DESC);

-- ── detalle_orden ─────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_detalle_orden_orden  ON detalle_orden (orden_id);
CREATE INDEX IF NOT EXISTS idx_detalle_orden_prod   ON detalle_orden (producto_id);

-- ── pagos ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_pagos_orden          ON pagos (orden_id);
CREATE INDEX IF NOT EXISTS idx_pagos_estado         ON pagos (estado_pago, fecha_pago DESC);
CREATE INDEX IF NOT EXISTS idx_pagos_referencia     ON pagos (referencia_externa);

-- ── envios ────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_envios_orden         ON envios (orden_id);
CREATE INDEX IF NOT EXISTS idx_envios_guia          ON envios (numero_guia);

-- ── carritos ──────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_carritos_usuario     ON carritos (usuario_id);
CREATE INDEX IF NOT EXISTS idx_carritos_expiracion  ON carritos (fecha_expiracion) WHERE fecha_expiracion < NOW();

-- ── direcciones ───────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_direcciones_usuario  ON direcciones (usuario_id);
