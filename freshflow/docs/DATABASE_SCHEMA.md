# Vego Database Schema Recommendations

Following PostgreSQL Table Design skill best practices.

---

## Index Recommendations

### `products` Table

```sql
-- Primary lookup by category
CREATE INDEX idx_products_category ON products(category);

-- Ordering by creation date
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- Composite index for category + date (common query pattern)
CREATE INDEX idx_products_category_date ON products(category, created_at DESC);
```

### `orders` Table

```sql
-- User orders lookup (most common query)
CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Order status filtering
CREATE INDEX idx_orders_status ON orders(status);

-- Composite: user orders by date
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at DESC);
```

### `addresses` Table

```sql
-- User addresses lookup
CREATE INDEX idx_addresses_user_id ON addresses(user_id);

-- Default address quick lookup
CREATE INDEX idx_addresses_default ON addresses(user_id, is_default) WHERE is_default = true;
```

### `wishlists` Table

```sql
-- User wishlist lookup
CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);

-- Product in wishlist check
CREATE INDEX idx_wishlists_product ON wishlists(product_id);
```

---

## Data Type Recommendations

| Column | Current | Recommended | Reason |
|--------|---------|-------------|--------|
| `price` | `integer` | `numeric(10,2)` | Precision for currency |
| `created_at` | `timestamp` | `timestamptz` | Timezone-aware |
| `updated_at` | `timestamp` | `timestamptz` | Timezone-aware |
| `order_total` | `integer` | `numeric(12,2)` | Large order totals |

---

## Normalization Notes

### Current: Denormalized Price in Orders ✅
- **Good**: `orders` table stores `order_total` at time of purchase
- **Reason**: Product prices can change; order total should be immutable

### Recommendation: Add `order_items` Table
```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,      -- Snapshot at purchase time
  unit_price NUMERIC(10,2) NOT NULL,  -- Snapshot
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
```

---

## Triggers

### Auto-update `updated_at`

```sql
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to products
CREATE TRIGGER update_products_modtime
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();

-- Apply to orders
CREATE TRIGGER update_orders_modtime
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_column();
```
