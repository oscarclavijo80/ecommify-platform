// ============================================================
// Ecommify Platform — MongoDB Collection Schemas
// Archivo: schemas.js
// Uso: mongo ecommify < schemas.js
// ============================================================

// ── product_catalog ──────────────────────────────────────
db.createCollection("product_catalog", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["_id", "name", "price", "category"],
      properties: {
        _id:      { bsonType: "string",  description: "ID del producto (ej: PROD-1001)" },
        name:     { bsonType: "string",  description: "Nombre del producto" },
        category: { bsonType: "string",  description: "Categoría principal" },
        price:    { bsonType: "number",  minimum: 0, description: "Precio en COP" },
        attributes: {
          bsonType: "object",
          description: "Atributos variables según tipo de producto"
        },
        tags: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        images: {
          bsonType: "array",
          items: { bsonType: "string" }
        },
        ratings: {
          bsonType: "object",
          properties: {
            average: { bsonType: "double", minimum: 0, maximum: 5 },
            count:   { bsonType: "int",    minimum: 0 }
          }
        },
        active:       { bsonType: "bool" },
        created_at:   { bsonType: "date" },
        updated_at:   { bsonType: "date" }
      }
    }
  }
});

// Índices product_catalog
db.product_catalog.createIndex({ name: "text", "tags": 1 });
db.product_catalog.createIndex({ category: 1, price: 1 });
db.product_catalog.createIndex({ "ratings.average": -1 });

// ── user_behavior ────────────────────────────────────────
// Patrón Bucket: agrupa eventos por usuario y período
db.createCollection("user_behavior", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "period", "events"],
      properties: {
        userId: { bsonType: "long",   description: "ID de usuario (FK lógico a PostgreSQL)" },
        period: { bsonType: "string", description: "Período agrupado: YYYY-MM-DD" },
        events: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["type", "timestamp"],
            properties: {
              type:      { bsonType: "string", enum: ["VIEW_PRODUCT","ADD_TO_CART","REMOVE_FROM_CART","SEARCH","PURCHASE","WISHLIST"] },
              productId: { bsonType: "string" },
              query:     { bsonType: "string" },
              timestamp: { bsonType: "date" },
              metadata:  { bsonType: "object" }
            }
          }
        },
        event_count:  { bsonType: "int" },
        last_updated: { bsonType: "date" }
      }
    }
  }
});

// TTL index: eliminar comportamiento antiguo tras 180 días
db.user_behavior.createIndex({ last_updated: 1 }, { expireAfterSeconds: 15552000 });
db.user_behavior.createIndex({ userId: 1, period: 1 }, { unique: true });

// ── recommendations ──────────────────────────────────────
db.createCollection("recommendations", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "products", "generated_at"],
      properties: {
        userId:       { bsonType: "long" },
        products: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              productId: { bsonType: "string" },
              score:     { bsonType: "double", minimum: 0, maximum: 1 },
              reason:    { bsonType: "string", enum: ["COLLABORATIVE","CONTENT_BASED","TRENDING","PURCHASED_TOGETHER"] }
            }
          }
        },
        generated_at: { bsonType: "date" },
        expires_at:   { bsonType: "date" }
      }
    }
  }
});

// TTL index: recomendaciones expiran en 24h
db.recommendations.createIndex({ expires_at: 1 }, { expireAfterSeconds: 0 });
db.recommendations.createIndex({ userId: 1 }, { unique: true });

// ── product_reviews ──────────────────────────────────────
// Patrón Embedding: reseñas embebidas dentro del documento del producto
db.createCollection("product_reviews", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["productId", "reviews"],
      properties: {
        productId: { bsonType: "string" },
        reviews: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["userId", "rating", "created_at"],
            properties: {
              userId:     { bsonType: "long" },
              rating:     { bsonType: "int", minimum: 1, maximum: 5 },
              title:      { bsonType: "string" },
              body:       { bsonType: "string" },
              verified:   { bsonType: "bool" },
              helpful:    { bsonType: "int", minimum: 0 },
              created_at: { bsonType: "date" }
            }
          }
        },
        avg_rating: { bsonType: "double" },
        total:      { bsonType: "int" }
      }
    }
  }
});

db.product_reviews.createIndex({ productId: 1 }, { unique: true });
db.product_reviews.createIndex({ avg_rating: -1 });

// ── search_logs ──────────────────────────────────────────
db.createCollection("search_logs", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["query", "timestamp"],
      properties: {
        userId:       { bsonType: "long" },
        query:        { bsonType: "string" },
        results_count: { bsonType: "int", minimum: 0 },
        filters:      { bsonType: "object" },
        timestamp:    { bsonType: "date" },
        session_id:   { bsonType: "string" }
      }
    }
  }
});

// TTL: logs de búsqueda se retienen 90 días
db.search_logs.createIndex({ timestamp: 1 }, { expireAfterSeconds: 7776000 });
db.search_logs.createIndex({ query: "text" });
db.search_logs.createIndex({ userId: 1, timestamp: -1 });

print("✅ Colecciones e índices de MongoDB creados correctamente.");
