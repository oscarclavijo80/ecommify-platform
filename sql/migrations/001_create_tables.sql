-- ============================================================
-- Ecommify Platform — PostgreSQL Migrations
-- Archivo: 001_create_tables.sql
-- Descripción: Creación de todas las tablas del esquema relacional
-- ============================================================

-- Extensiones necesarias
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ─────────────────────────────────────────────
-- TABLA: usuarios
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS usuarios (
    id              BIGSERIAL PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    email           VARCHAR(150)    UNIQUE NOT NULL,
    password_hash   TEXT            NOT NULL,
    telefono        VARCHAR(20)     NULL,
    fecha_creacion  TIMESTAMP       DEFAULT NOW(),
    estado          VARCHAR(20)     CHECK (estado IN ('ACTIVO', 'INACTIVO', 'SUSPENDIDO'))
);

-- ─────────────────────────────────────────────
-- TABLA: direcciones
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS direcciones (
    id              BIGSERIAL PRIMARY KEY,
    usuario_id      BIGINT          NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    ciudad          VARCHAR(100)    NOT NULL,
    pais            VARCHAR(100)    NOT NULL,
    direccion       TEXT            NOT NULL,
    codigo_postal   VARCHAR(20)     NULL,
    es_principal    BOOLEAN         DEFAULT FALSE
);

-- ─────────────────────────────────────────────
-- TABLA: categorias
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categorias (
    id              BIGSERIAL PRIMARY KEY,
    nombre          VARCHAR(100)    NOT NULL,
    descripcion     TEXT            NULL,
    categoria_padre BIGINT          NULL REFERENCES categorias(id)
);

-- ─────────────────────────────────────────────
-- TABLA: productos
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS productos (
    id              BIGSERIAL PRIMARY KEY,
    nombre          VARCHAR(200)    NOT NULL,
    descripcion     TEXT            NULL,
    precio          NUMERIC(12,2)   NOT NULL CHECK (precio >= 0),
    categoria_id    BIGINT          REFERENCES categorias(id),
    atributos       JSONB           NULL,
    tags            TEXT[]          NULL,
    fecha_creacion  TIMESTAMP       DEFAULT NOW(),
    activo          BOOLEAN         DEFAULT TRUE
);

-- ─────────────────────────────────────────────
-- TABLA: inventarios
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS inventarios (
    id                  BIGSERIAL PRIMARY KEY,
    producto_id         BIGINT          NOT NULL UNIQUE REFERENCES productos(id),
    stock               INTEGER         NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_reservado     INTEGER         NOT NULL DEFAULT 0 CHECK (stock_reservado >= 0),
    ultima_actualizacion TIMESTAMP      DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- TABLA: carritos
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS carritos (
    id              BIGSERIAL PRIMARY KEY,
    usuario_id      BIGINT          NOT NULL UNIQUE REFERENCES usuarios(id),
    fecha_creacion  TIMESTAMP       DEFAULT NOW(),
    fecha_expiracion TIMESTAMP      DEFAULT NOW() + INTERVAL '30 days'
);

-- ─────────────────────────────────────────────
-- TABLA: items_carrito
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS items_carrito (
    id              BIGSERIAL PRIMARY KEY,
    carrito_id      BIGINT          NOT NULL REFERENCES carritos(id) ON DELETE CASCADE,
    producto_id     BIGINT          NOT NULL REFERENCES productos(id),
    cantidad        INTEGER         NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2)   NOT NULL,
    UNIQUE (carrito_id, producto_id)
);

-- ─────────────────────────────────────────────
-- TABLA: ordenes
-- Particionada por rango mensual en fecha_creacion
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ordenes (
    id              BIGSERIAL,
    usuario_id      BIGINT          NOT NULL REFERENCES usuarios(id),
    total           NUMERIC(12,2)   NOT NULL CHECK (total >= 0),
    estado          VARCHAR(30)     NOT NULL CHECK (estado IN ('PENDIENTE','CONFIRMADA','EN_PROCESO','ENVIADA','ENTREGADA','CANCELADA')),
    fecha_creacion  TIMESTAMP       DEFAULT NOW(),
    metadata        JSONB           NULL,
    PRIMARY KEY (id, fecha_creacion)
) PARTITION BY RANGE (fecha_creacion);

-- Particiones mensuales (ejemplo: 2026)
CREATE TABLE ordenes_2026_01 PARTITION OF ordenes
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE ordenes_2026_02 PARTITION OF ordenes
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE ordenes_2026_03 PARTITION OF ordenes
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE ordenes_2026_04 PARTITION OF ordenes
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE ordenes_2026_05 PARTITION OF ordenes
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE ordenes_2026_06 PARTITION OF ordenes
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

-- ─────────────────────────────────────────────
-- TABLA: detalle_orden
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS detalle_orden (
    id              BIGSERIAL PRIMARY KEY,
    orden_id        BIGINT          NOT NULL,
    producto_id     BIGINT          NOT NULL REFERENCES productos(id),
    cantidad        INTEGER         NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2)   NOT NULL CHECK (precio_unitario >= 0)
);

-- ─────────────────────────────────────────────
-- TABLA: pagos
-- Particionada por rango mensual
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS pagos (
    id                  BIGSERIAL,
    orden_id            BIGINT          NOT NULL,
    metodo_pago         VARCHAR(50)     NOT NULL CHECK (metodo_pago IN ('TARJETA_CREDITO','TARJETA_DEBITO','PSE','NEQUI','EFECTIVO','PAYPAL')),
    estado_pago         VARCHAR(30)     NOT NULL CHECK (estado_pago IN ('PENDIENTE','APROBADO','RECHAZADO','REEMBOLSADO')),
    referencia_externa  VARCHAR(200)    NULL,
    fecha_pago          TIMESTAMP       NULL,
    monto               NUMERIC(12,2)   NOT NULL CHECK (monto >= 0),
    PRIMARY KEY (id, fecha_pago)
) PARTITION BY RANGE (fecha_pago);

CREATE TABLE pagos_2026_01 PARTITION OF pagos
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE pagos_2026_02 PARTITION OF pagos
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE pagos_2026_03 PARTITION OF pagos
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');
CREATE TABLE pagos_2026_04 PARTITION OF pagos
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE pagos_2026_05 PARTITION OF pagos
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE pagos_2026_06 PARTITION OF pagos
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

-- ─────────────────────────────────────────────
-- TABLA: envios
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS envios (
    id              BIGSERIAL PRIMARY KEY,
    orden_id        BIGINT          NOT NULL UNIQUE,
    transportadora  VARCHAR(100)    NULL,
    numero_guia     VARCHAR(200)    NULL,
    estado_envio    VARCHAR(30)     NOT NULL CHECK (estado_envio IN ('PENDIENTE','PREPARANDO','EN_CAMINO','ENTREGADO','DEVUELTO')),
    direccion_id    BIGINT          REFERENCES direcciones(id),
    fecha_estimada  TIMESTAMP       NULL,
    fecha_entrega   TIMESTAMP       NULL
);

-- ─────────────────────────────────────────────
-- TABLA: vendedores
-- ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vendedores (
    id              BIGSERIAL PRIMARY KEY,
    usuario_id      BIGINT          NOT NULL UNIQUE REFERENCES usuarios(id),
    nombre_tienda   VARCHAR(200)    NOT NULL,
    descripcion     TEXT            NULL,
    fecha_registro  TIMESTAMP       DEFAULT NOW(),
    estado          VARCHAR(20)     CHECK (estado IN ('ACTIVO','SUSPENDIDO','VERIFICADO'))
);
