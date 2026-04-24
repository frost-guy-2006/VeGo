-- Migration 003: Add CHECK constraints to existing tables
-- Phase 1A.3 — "Do not trust client input." Adds server-side validation
-- as a last line of defense against invalid data.
--
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- Products: Ensure prices are always positive
ALTER TABLE public.products
  ADD CONSTRAINT positive_current_price CHECK (current_price > 0);

ALTER TABLE public.products
  ADD CONSTRAINT positive_market_price CHECK (market_price > 0);

-- Products: Ensure stock is never negative
ALTER TABLE public.products
  ADD CONSTRAINT non_negative_stock CHECK (stock >= 0);

-- Orders: Ensure total amount is positive
ALTER TABLE public.orders
  ADD CONSTRAINT positive_total_amount CHECK (total_amount > 0);

-- Orders: Expand the status CHECK to include all OrderStatus enum values
-- The existing constraint only allows: pending, confirmed, delivered, cancelled
-- Our Flutter model also has: preparing, outForDelivery
-- First drop the old inline check, then add the new one.
--
-- NOTE: If the inline CHECK doesn't have a name, you may need to find it:
-- SELECT conname FROM pg_constraint WHERE conrelid = 'public.orders'::regclass;
--
-- Then drop it by name and add the expanded one:
-- ALTER TABLE public.orders DROP CONSTRAINT orders_status_check;

ALTER TABLE public.orders
  DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE public.orders
  ADD CONSTRAINT orders_status_check
  CHECK (status IN ('pending', 'confirmed', 'preparing', 'out_for_delivery', 'delivered', 'cancelled'));

-- ============================================================================
-- VERIFICATION: Run after migration to confirm constraints exist
-- SELECT conname, contype FROM pg_constraint
--   WHERE conrelid = 'public.products'::regclass OR conrelid = 'public.orders'::regclass;
-- ============================================================================
