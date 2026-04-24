-- Migration 002: Create order_status_log audit table
-- Phase 1A.2 — Tracks every status change on an order for debugging & disputes.
--
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- Create the audit log table
CREATE TABLE public.order_status_log (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id   UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_at TIMESTAMPTZ DEFAULT now(),
  changed_by UUID REFERENCES auth.users
);

-- Index for fast lookups of status history by order
CREATE INDEX idx_order_status_log_order_id ON public.order_status_log(order_id);

-- Index for chronological queries
CREATE INDEX idx_order_status_log_changed_at ON public.order_status_log(changed_at);

-- Enable Row Level Security
ALTER TABLE public.order_status_log ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can view audit logs for their own orders
CREATE POLICY "Users can view their own order status logs"
  ON public.order_status_log FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_status_log.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- RLS Policy: Insert is restricted to authenticated users (for their own orders)
CREATE POLICY "Users can insert status logs for their own orders"
  ON public.order_status_log FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = order_status_log.order_id
        AND orders.user_id = auth.uid()
    )
  );

-- ============================================================================
-- OPTIONAL: Auto-log trigger (logs status changes automatically)
-- Uncomment this if you want the database to automatically log status changes
-- instead of relying on the application layer.
-- ============================================================================
--
-- CREATE OR REPLACE FUNCTION log_order_status_change()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   IF OLD.status IS DISTINCT FROM NEW.status THEN
--     INSERT INTO public.order_status_log (order_id, old_status, new_status, changed_by)
--     VALUES (NEW.id, OLD.status, NEW.status, auth.uid());
--   END IF;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER trigger_order_status_change
--   AFTER UPDATE OF status ON public.orders
--   FOR EACH ROW
--   EXECUTE FUNCTION log_order_status_change();
-- ============================================================================

-- ============================================================================
-- VERIFICATION: Run after migration to confirm success
-- SELECT count(*) FROM information_schema.tables WHERE table_name = 'order_status_log';
-- Expected result: 1
-- ============================================================================
