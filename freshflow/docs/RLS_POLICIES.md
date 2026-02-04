# Supabase RLS Policies (Row Level Security)

This document outlines the recommended RLS policies for the Vego app database tables.

## Security Principles

1. **Enable RLS on ALL tables** - No public table should be accessible without policies
2. **Principle of Least Privilege** - Users can only access their own data
3. **Service Role** - Only used in Edge Functions, never in client app

---

## Table Policies

### `products` (Public Read, Admin Write)

```sql
-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Anyone can read products
CREATE POLICY "Products are viewable by everyone"
ON products FOR SELECT
USING (true);

-- Only service role can modify (via Edge Functions)
CREATE POLICY "Products are modifiable by service role only"
ON products FOR ALL
USING (auth.role() = 'service_role');
```

### `orders` (User-specific)

```sql
-- Enable RLS
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Users can only view their own orders
CREATE POLICY "Users can view their own orders"
ON orders FOR SELECT
USING (auth.uid() = user_id);

-- Users can insert their own orders
CREATE POLICY "Users can create their own orders"
ON orders FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Users can update their own orders (for cancellation)
CREATE POLICY "Users can update their own orders"
ON orders FOR UPDATE
USING (auth.uid() = user_id);
```

### `addresses` (User-specific)

```sql
-- Enable RLS
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- Users can only CRUD their own addresses
CREATE POLICY "Users can manage their own addresses"
ON addresses FOR ALL
USING (auth.uid() = user_id);
```

### `wishlists` (User-specific)

```sql
-- Enable RLS
ALTER TABLE wishlists ENABLE ROW LEVEL SECURITY;

-- Users can only CRUD their own wishlist items
CREATE POLICY "Users can manage their own wishlist"
ON wishlists FOR ALL
USING (auth.uid() = user_id);
```

### `cart_items` (User-specific)

```sql
-- Enable RLS
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

-- Users can only CRUD their own cart items
CREATE POLICY "Users can manage their own cart"
ON cart_items FOR ALL
USING (auth.uid() = user_id);
```

---

## Verification Checklist

- [ ] All tables have `ENABLE ROW LEVEL SECURITY`
- [ ] No table uses `USING (true)` for write operations
- [ ] User-specific tables filter by `auth.uid() = user_id`
- [ ] Service role is only used in Edge Functions
- [ ] No client app uses service role key

---

## Edge Function Security

When creating Edge Functions:

```typescript
// ✅ GOOD: Use anon key in client, service role in Edge Function
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!  // Only in server-side code
)

// ❌ BAD: Never expose service role key in client app
```
