-- Migration 001: Create order_items relational table
-- Phase 1A.1 — Non-destructive: the old orders.items JSONB column is KEPT.
-- This table will eventually replace the JSONB blob with proper relational data.
--
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- Create the order_items table
CREATE TABLE public.order_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id          UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id        UUID NOT NULL REFERENCES public.products(id),
  quantity          INTEGER NOT NULL CHECK (quantity > 0),
  price_at_purchase NUMERIC NOT NULL CHECK (price_at_purchase >= 0),
  created_at        TIMESTAMPTZ DEFAULT now()
);

-- Add an index for fast lookups by order_id (most common query pattern)
CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);

-- Add an index for product-level analytics queries
CREATE INDEX idx_order_items_product_id ON public.order_items(product_id);

-- Enable Row Level Security
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view order_items that belong to their own orders
CREATE POLICY "Users can view their own order items"
  ON public.order_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- RLS Policy: Users can insert order_items for their own orders
CREATE POLICY "Users can insert their own order items"
  ON public.order_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_items.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- ============================================================================
-- VERIFICATION: Run after migration to confirm success
-- SELECT count(*) FROM information_schema.tables WHERE table_name = 'order_items';
-- Expected result: 1
-- ============================================================================
