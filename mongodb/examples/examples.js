// ============================================================
// Ecommify Platform — Documentos de Ejemplo MongoDB
// Archivo: examples.js
// Uso: mongo ecommify < examples.js
// ============================================================

// ── product_catalog ──────────────────────────────────────
db.product_catalog.insertMany([
  {
    _id: "PROD-1001",
    name: "Laptop Gamer RTX 4080",
    category: "Tecnología",
    subcategory: "Computadores",
    price: 4500000,
    attributes: {
      ram: "32GB DDR5",
      cpu: "Intel i9-13900H",
      gpu: "RTX 4080 16GB",
      almacenamiento: "2TB NVMe PCIe 4.0",
      pantalla: "17.3 pulgadas 240Hz QHD",
      bateria: "99.9Wh",
      peso: "2.8kg",
      sistema_operativo: "Windows 11 Home"
    },
    tags: ["gaming", "laptop", "high-performance", "intel", "nvidia", "rtx"],
    images: [
      "https://cdn.ecommify.co/products/PROD-1001/front.jpg",
      "https://cdn.ecommify.co/products/PROD-1001/side.jpg",
      "https://cdn.ecommify.co/products/PROD-1001/keyboard.jpg"
    ],
    ratings: { average: 4.8, count: 523 },
    active: true,
    created_at: new Date("2026-01-15"),
    updated_at: new Date("2026-05-20")
  },
  {
    _id: "PROD-2001",
    name: "iPhone 15 Pro Max",
    category: "Tecnología",
    subcategory: "Smartphones",
    price: 5200000,
    attributes: {
      almacenamiento: "256GB",
      color: "Titanio Natural",
      pantalla: "6.7 pulgadas Super Retina XDR",
      chip: "A17 Pro",
      camara_principal: "48MP Fusion",
      camara_frontal: "12MP TrueDepth",
      conectividad: "5G, WiFi 6E, Bluetooth 5.3",
      resistencia: "IP68"
    },
    tags: ["smartphone", "apple", "iphone", "5g", "pro"],
    images: [
      "https://cdn.ecommify.co/products/PROD-2001/front.jpg"
    ],
    ratings: { average: 4.9, count: 1240 },
    active: true,
    created_at: new Date("2026-02-01"),
    updated_at: new Date("2026-05-21")
  }
]);

// ── user_behavior (Bucket Pattern) ───────────────────────
db.user_behavior.insertMany([
  {
    userId: NumberLong(1001),
    period: "2026-05-25",
    events: [
      {
        type: "VIEW_PRODUCT",
        productId: "PROD-1001",
        timestamp: new Date("2026-05-25T10:00:00Z"),
        metadata: { source: "home_banner", duration_seconds: 45 }
      },
      {
        type: "VIEW_PRODUCT",
        productId: "PROD-2001",
        timestamp: new Date("2026-05-25T10:03:00Z"),
        metadata: { source: "search", duration_seconds: 120 }
      },
      {
        type: "ADD_TO_CART",
        productId: "PROD-1001",
        timestamp: new Date("2026-05-25T10:05:00Z"),
        metadata: { quantity: 1 }
      },
      {
        type: "SEARCH",
        query: "laptop gaming",
        timestamp: new Date("2026-05-25T10:10:00Z"),
        metadata: { results_count: 18 }
      }
    ],
    event_count: 4,
    last_updated: new Date("2026-05-25T10:10:00Z")
  }
]);

// ── recommendations ──────────────────────────────────────
db.recommendations.insertMany([
  {
    userId: NumberLong(1001),
    products: [
      { productId: "PROD-1001", score: 0.97, reason: "CONTENT_BASED" },
      { productId: "PROD-3005", score: 0.89, reason: "COLLABORATIVE" },
      { productId: "PROD-3010", score: 0.85, reason: "PURCHASED_TOGETHER" },
      { productId: "PROD-2001", score: 0.78, reason: "TRENDING" }
    ],
    generated_at: new Date("2026-05-25T08:00:00Z"),
    expires_at: new Date("2026-05-26T08:00:00Z")
  }
]);

// ── product_reviews (Embedding Pattern) ──────────────────
db.product_reviews.insertMany([
  {
    productId: "PROD-1001",
    reviews: [
      {
        userId: NumberLong(2001),
        rating: 5,
        title: "Excelente laptop para gaming",
        body: "Increíble rendimiento, corre todos los juegos en ultra sin problemas. La pantalla es espectacular.",
        verified: true,
        helpful: 42,
        created_at: new Date("2026-03-10")
      },
      {
        userId: NumberLong(3002),
        rating: 4,
        title: "Muy buena pero pesada",
        body: "Rendimiento top, la batería dura bien para gaming. Un poco pesada para llevar todo el día.",
        verified: true,
        helpful: 18,
        created_at: new Date("2026-04-05")
      }
    ],
    avg_rating: 4.8,
    total: 523
  }
]);

// ── search_logs ──────────────────────────────────────────
db.search_logs.insertMany([
  {
    userId: NumberLong(1001),
    query: "laptop gaming",
    results_count: 18,
    filters: { price_max: 6000000, category: "Tecnología" },
    timestamp: new Date("2026-05-25T10:10:00Z"),
    session_id: "sess-abc-123"
  },
  {
    userId: NumberLong(2002),
    query: "iphone 15",
    results_count: 5,
    filters: {},
    timestamp: new Date("2026-05-25T11:30:00Z"),
    session_id: "sess-def-456"
  }
]);

print("✅ Documentos de ejemplo insertados correctamente.");
