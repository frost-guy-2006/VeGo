-- Migration 005: Add missing fields to orders table
--
-- This migration adds delivery_fee, delivery_address, delivered_at, 
-- and cancellation_reason to the orders table.
--
-- Run this in the Supabase SQL Editor:
-- ============================================================================

-- Add delivery_fee
ALTER TABLE public.orders 
  ADD COLUMN IF NOT EXISTS delivery_fee NUMERIC DEFAULT 0.0;

-- Add delivery_address
ALTER TABLE public.orders 
  ADD COLUMN IF NOT EXISTS delivery_address TEXT;

-- Add delivered_at
ALTER TABLE public.orders 
  ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMPTZ;

-- Add cancellation_reason
ALTER TABLE public.orders 
  ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- ============================================================================
-- VERIFICATION: Run after migration to confirm columns exist
-- SELECT column_name, data_type 
-- FROM information_schema.columns 
-- WHERE table_name = 'orders' 
--   AND column_name IN ('delivery_fee', 'delivery_address', 'delivered_at', 'cancellation_reason');
-- ============================================================================
