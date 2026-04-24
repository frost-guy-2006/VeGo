-- Migration 004: Backfill order_items from existing JSONB data
-- Phase 1B.2 — One-time script to populate the new order_items table
-- from the existing orders.items JSONB column.
--
-- ⚠️ Run this AFTER migration 001 (order_items table exists).
-- ⚠️ This script is IDEMPOTENT — safe to run multiple times.
--
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- Backfill: Parse each JSON array element in orders.items and insert
-- into the relational order_items table.
--
-- IMPORTANT: This handles two possible JSONB key formats:
--   Format A (from Flutter OrderItem.toJson): { "product": { "id": "..." }, "quantity": 2, "priceAtPurchase": 10.0 }
--   Format B (simplified):                    { "product_id": "...", "quantity": 2, "price": 10.0 }

-- Format A: Full product object embedded (matches current Flutter OrderItem.toJson)
INSERT INTO public.order_items (order_id, product_id, quantity, price_at_purchase)
SELECT
  o.id AS order_id,
  (item->'product'->>'id')::UUID AS product_id,
  (item->>'quantity')::INTEGER AS quantity,
  (item->>'priceAtPurchase')::NUMERIC AS price_at_purchase
FROM public.orders o,
  jsonb_array_elements(o.items) AS item
WHERE
  -- Only process items that have the nested product.id format
  item->'product'->>'id' IS NOT NULL
  -- Skip orders already backfilled (idempotent)
  AND NOT EXISTS (
    SELECT 1 FROM public.order_items oi WHERE oi.order_id = o.id
  );

-- Format B: Flat product_id format (fallback for simplified data)
INSERT INTO public.order_items (order_id, product_id, quantity, price_at_purchase)
SELECT
  o.id AS order_id,
  (item->>'product_id')::UUID AS product_id,
  (item->>'quantity')::INTEGER AS quantity,
  COALESCE(
    (item->>'priceAtPurchase')::NUMERIC,
    (item->>'price')::NUMERIC,
    (item->>'price_at_purchase')::NUMERIC
  ) AS price_at_purchase
FROM public.orders o,
  jsonb_array_elements(o.items) AS item
WHERE
  -- Only process items that have the flat product_id format
  item->>'product_id' IS NOT NULL
  AND item->'product'->>'id' IS NULL  -- Not already handled by Format A
  -- Skip orders already backfilled (idempotent)
  AND NOT EXISTS (
    SELECT 1 FROM public.order_items oi WHERE oi.order_id = o.id
  );

-- ============================================================================
-- VERIFICATION: Compare counts to ensure all items were migrated
-- ============================================================================

-- Count of orders with JSONB items
-- SELECT count(*) AS orders_with_jsonb FROM public.orders WHERE items IS NOT NULL;

-- Count of orders with relational items
-- SELECT count(DISTINCT order_id) AS orders_with_relational FROM public.order_items;

-- These two counts should be equal after backfill.
-- ============================================================================
