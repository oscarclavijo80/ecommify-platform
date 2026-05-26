# Ecommify Platform

Plataforma de comercio electrónico híbrida con arquitectura de microservicios y eventos.

## Stack Técnico

| Capa | Tecnología |
|------|-----------|
| Base de datos transaccional | PostgreSQL |
| Base de datos documental | MongoDB |
| Infraestructura | AWS (EKS, RDS, DocumentDB) |
| Mensajería | Kafka / AWS SQS |
| Autenticación | OAuth2 / JWT |
| Arquitectura | Microservicios + Event-Driven (EDA) |

## Estructura del Proyecto

```
ecommify-platform/
├── sql/
│   ├── migrations/       # Creación de tablas PostgreSQL
│   ├── seeds/            # Datos de ejemplo
│   └── indexes/          # Índices y optimización
├── mongodb/
│   ├── schemas/          # Validadores de colecciones
│   └── examples/         # Documentos de ejemplo
└── docs/                 # Documentación técnica
```

## Requisitos No Funcionales

- Disponibilidad mínima: **99.95%**
- Tiempo de respuesta: **< 300 ms**
- Usuarios concurrentes: **50,000**
- Consistencia fuerte en pagos y órdenes (ACID)

## Arquitectura

```
Cliente → API Gateway (JWT) → Microservicios
                                  ├── Usuarios     → PostgreSQL
                                  ├── Órdenes      → PostgreSQL
                                  ├── Pagos        → PostgreSQL
                                  ├── Inventario   → PostgreSQL
                                  └── Catálogo     → MongoDB
                                       ↓
                                  Event Bus (Kafka/SQS)
                                       ↓
                              ┌────────────────┐
                              │    MongoDB     │
                              │ Recomendaciones│
                              │ Historial Nav. │
                              │ Reseñas / Logs │
                              └────────────────┘
```

## Restricciones de Negocio

| ID | Restricción |
|----|------------|
| RB-01 | Un producto no puede tener inventario negativo |
| RB-02 | Una orden debe tener al menos un detalle |
| RB-03 | Un pago debe estar asociado a una orden válida |
| RB-04 | Un usuario solo puede reseñar productos comprados |
| RB-05 | El estado de envío depende del estado de pago |
| RB-06 | El carrito expira después de 30 días de inactividad |

## Aplicación del Teorema CAP

- **PostgreSQL** → Prioriza Consistencia + Disponibilidad (CP/CA) — pagos y órdenes críticas
- **MongoDB** → Prioriza Disponibilidad + Tolerancia a Particiones (AP) — recomendaciones y navegación
