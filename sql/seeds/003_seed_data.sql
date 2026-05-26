-- ============================================================
-- Ecommify Platform — Datos de Ejemplo (Seeds)
-- Archivo: 003_seed_data.sql
-- ============================================================

-- ── Categorías ────────────────────────────────────────────
INSERT INTO categorias (nombre, descripcion) VALUES
    ('Tecnología',      'Dispositivos electrónicos y accesorios'),
    ('Ropa',            'Prendas de vestir para hombre y mujer'),
    ('Hogar',           'Artículos para el hogar y decoración'),
    ('Deportes',        'Equipos y ropa deportiva'),
    ('Libros',          'Libros físicos y digitales');

-- Subcategorías
INSERT INTO categorias (nombre, descripcion, categoria_padre) VALUES
    ('Computadores',    'Laptops, PCs y accesorios',    1),
    ('Smartphones',     'Teléfonos inteligentes',        1),
    ('Audio',           'Audífonos, parlantes y más',    1);

-- ── Usuarios ──────────────────────────────────────────────
INSERT INTO usuarios (nombre, email, password_hash, telefono, estado) VALUES
    ('Carlos Torres',   'carlos@email.com',   encode(digest('pass123','sha256'),'hex'), '3001234567', 'ACTIVO'),
    ('Ana Martínez',    'ana@email.com',       encode(digest('pass456','sha256'),'hex'), '3109876543', 'ACTIVO'),
    ('Luis Gómez',      'luis@email.com',      encode(digest('pass789','sha256'),'hex'), '3207654321', 'ACTIVO');

-- ── Direcciones ───────────────────────────────────────────
INSERT INTO direcciones (usuario_id, ciudad, pais, direccion, codigo_postal, es_principal) VALUES
    (1, 'Bogotá',    'Colombia', 'Calle 100 # 15-20, Apto 301', '110111', TRUE),
    (2, 'Medellín',  'Colombia', 'Carrera 80 # 45-10',           '050021', TRUE),
    (3, 'Cali',      'Colombia', 'Avenida 6N # 23-45',           '760001', TRUE);

-- ── Productos ─────────────────────────────────────────────
INSERT INTO productos (nombre, descripcion, precio, categoria_id, atributos, tags) VALUES
    (
        'Laptop Gamer RTX 4080',
        'Laptop de alto rendimiento para gaming y diseño profesional',
        4500000.00,
        6,
        '{"ram": "32GB", "cpu": "Intel i9-13900H", "gpu": "RTX 4080", "almacenamiento": "2TB NVMe", "pantalla": "17.3 pulgadas 240Hz"}',
        ARRAY['gaming','laptop','high-performance','intel','nvidia']
    ),
    (
        'iPhone 15 Pro Max',
        'Smartphone Apple con chip A17 Pro y sistema de cámara avanzado',
        5200000.00,
        7,
        '{"almacenamiento": "256GB", "color": "Titanio Natural", "pantalla": "6.7 pulgadas", "camara": "48MP"}',
        ARRAY['smartphone','apple','iphone','5g']
    ),
    (
        'Audífonos Sony WH-1000XM5',
        'Audífonos inalámbricos con cancelación de ruido líder del mercado',
        950000.00,
        8,
        '{"bateria": "30 horas", "conectividad": "Bluetooth 5.2", "cancelacion_ruido": true}',
        ARRAY['audio','sony','bluetooth','inalambrico']
    );

-- ── Inventarios ───────────────────────────────────────────
INSERT INTO inventarios (producto_id, stock, stock_reservado) VALUES
    (1, 50,  5),
    (2, 120, 10),
    (3, 200, 15);

-- ── Órdenes ───────────────────────────────────────────────
INSERT INTO ordenes (usuario_id, total, estado, fecha_creacion) VALUES
    (1, 4500000.00, 'CONFIRMADA',  '2026-05-01 10:30:00'),
    (2, 5200000.00, 'ENTREGADA',   '2026-05-10 14:00:00'),
    (3,  950000.00, 'EN_PROCESO',  '2026-05-20 09:15:00');

-- ── Detalle de Órdenes ────────────────────────────────────
INSERT INTO detalle_orden (orden_id, producto_id, cantidad, precio_unitario) VALUES
    (1, 1, 1, 4500000.00),
    (2, 2, 1, 5200000.00),
    (3, 3, 1,  950000.00);

-- ── Pagos ─────────────────────────────────────────────────
INSERT INTO pagos (orden_id, metodo_pago, estado_pago, referencia_externa, fecha_pago, monto) VALUES
    (1, 'TARJETA_CREDITO', 'APROBADO',  'REF-2026-001-VISA',  '2026-05-01 10:31:00', 4500000.00),
    (2, 'PSE',             'APROBADO',  'REF-2026-002-PSE',   '2026-05-10 14:01:00', 5200000.00),
    (3, 'NEQUI',           'PENDIENTE', NULL,                  NULL,                   950000.00);

-- ── Envíos ────────────────────────────────────────────────
INSERT INTO envios (orden_id, transportadora, numero_guia, estado_envio, direccion_id, fecha_estimada) VALUES
    (1, 'Servientrega', 'SRV-20260501-001', 'EN_CAMINO', 1, '2026-05-05 18:00:00'),
    (2, 'Coordinadora', 'CRD-20260510-002', 'ENTREGADO', 2, '2026-05-14 18:00:00');
