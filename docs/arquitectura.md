# Decisiones Arquitectónicas — Ecommify Platform

## Matriz de Decisión por Entidad

| Entidad | PostgreSQL | MongoDB | Justificación |
|---------|-----------|---------|--------------|
| Usuarios | ✅ | — | Consistencia e integridad referencial |
| Órdenes | ✅ | — | Transacciones ACID críticas |
| Pagos | ✅ | — | Alta criticidad financiera |
| Inventario | ✅ | — | Control de stock con integridad |
| Productos (core) | ✅ | ✅ | Datos híbridos |
| Recomendaciones | — | ✅ | Alta flexibilidad y volumen masivo |
| Historial Navegación | — | ✅ | 500M registros/año |
| Reseñas | — | ✅ | Embedding en productos |
| Logs búsqueda | — | ✅ | Analítica, alta escritura |

## Teorema CAP

```
            Consistency
                 C
                / \
               /   \
         PG ●/     \
             /       \
            A─────────P
       Availability  Partition
                      Tolerance
                         ● MDB
```

**PostgreSQL** → Zona CA: prioriza Consistencia + Disponibilidad
- Ideal para pagos, órdenes e inventario
- Garantías ACID estrictas
- Menor tolerancia a particiones de red extremas

**MongoDB** → Zona AP: prioriza Disponibilidad + Tolerancia a Particiones
- Ideal para recomendaciones, historial y catálogo flexible
- Consistencia eventual aceptable para estos módulos
- Escala horizontalmente con sharding

## Trade-offs

| Decisión | Beneficio | Riesgo | Mitigación |
|----------|-----------|--------|-----------|
| Arquitectura Híbrida | Flexibilidad total | Complejidad operativa | IaC + observabilidad centralizada |
| MongoDB para recomendaciones | Escala masiva | Consistencia eventual | Reprocesamiento asíncrono + TTL |
| Microservicios | Escalabilidad independiente | Complejidad distribuida | API Gateway + tracing (Jaeger) |
| Event-Driven (EDA) | Desacoplamiento | Duplicidad de eventos | Idempotencia + esquemas versionados |

## Flujos de Sincronización

### Flujo de Órdenes
```
1. Usuario crea orden
2. PostgreSQL almacena la transacción (ACID)
3. Evento ORDER_CREATED → Event Bus (Kafka/SQS)
4. MongoDB actualiza recomendaciones del usuario
5. Servicio analítico consume el evento para reportes
```

### Flujo de Comportamiento
```
1. Usuario navega el catálogo
2. Eventos capturados → MongoDB (Bucket Pattern)
3. Motor analítico procesa eventos por lotes
4. Genera recomendaciones personalizadas
5. Resultados disponibles en API de recomendaciones
```

## Particionamiento PostgreSQL

| Tabla | Estrategia | Criterio |
|-------|-----------|---------|
| ordenes | RANGE mensual | fecha_creacion |
| pagos | RANGE mensual | fecha_pago |
| historial_transacciones | RANGE + archivado | fecha |

## Extensiones PostgreSQL

| Extensión | Propósito |
|-----------|----------|
| `pgcrypto` | Encriptación de contraseñas y generación UUID |
| `pg_partman` | Automatización de particionamiento |
| `uuid-ossp` | Generación de UUID estándar |
| `pg_trgm` | Búsquedas textuales con trigramas |

## Patrones MongoDB

| Patrón | Aplicación |
|--------|-----------|
| **Embedding** | Reseñas dentro del documento de producto |
| **Referencing** | Relación usuarios ↔ productos (FK lógico) |
| **Bucket Pattern** | Eventos de navegación agrupados por usuario y día |
| **Polymorphic** | Productos con atributos variables según categoría |
