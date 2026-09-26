-- Seed Products for VeGo / FreshFlow
-- Run this script in the Supabase SQL Editor (SQL Query Runner)

-- 1. Enable RLS policy on products so anon (unauthenticated/authenticated users) can SELECT products
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to products" ON public.products;
CREATE POLICY "Allow public read access to products"
  ON public.products FOR SELECT
  USING (true);

-- 2. Insert sample fresh produce products
INSERT INTO public.products (id, name, image_url, current_price, market_price, harvest_time, stock, category)
VALUES
  (gen_random_uuid(), 'Organic Farm Tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=500&q=80', 32.00, 45.00, 'Harvested 2 hrs ago', 50, 'Vegetables'),
  (gen_random_uuid(), 'Fresh Ooty Carrots', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=500&q=80', 40.00, 55.00, 'Harvested 4 hrs ago', 35, 'Vegetables'),
  (gen_random_uuid(), 'Crisp Green Spinach', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=500&q=80', 25.00, 35.00, 'Harvested 1 hr ago', 40, 'Vegetables'),
  (gen_random_uuid(), 'Fresh Broccoli Head', 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=500&q=80', 65.00, 85.00, 'Harvested 3 hrs ago', 20, 'Vegetables'),
  (gen_random_uuid(), 'Royal Gala Red Apples', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=500&q=80', 120.00, 150.00, 'Fresh Arrival', 60, 'Fruits'),
  (gen_random_uuid(), 'Robusta Bananas (1 Dozen)', 'https://images.unsplash.com/photo-1571771896328-7963057c1e9c?auto=format&fit=crop&w=500&q=80', 48.00, 60.00, 'Fresh Arrival', 80, 'Fruits'),
  (gen_random_uuid(), 'Nagpur Juicy Oranges', 'https://images.unsplash.com/photo-1547514701-42782101795e?auto=format&fit=crop&w=500&q=80', 75.00, 95.00, 'Fresh Arrival', 45, 'Fruits'),
  (gen_random_uuid(), 'Farm Fresh Whole Milk (1L)', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=500&q=80', 64.00, 70.00, 'Bottled Today', 100, 'Dairy'),
  (gen_random_uuid(), 'Whole Wheat Artisanal Bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=500&q=80', 45.00, 55.00, 'Baked Today', 30, 'Bakery'),
  (gen_random_uuid(), 'Country Farm Eggs (6 pcs)', 'https://images.unsplash.com/photo-1519448135893-b6ed8e37602e?auto=format&fit=crop&w=500&q=80', 52.00, 60.00, 'Fresh Arrival', 70, 'Dairy')
ON CONFLICT DO NOTHING;
