-- Seed Data for FreshFlow Products
-- Run this in your Supabase SQL Editor

delete from public.products; -- Clear existing products to avoid duplicates

insert into public.products (name, image_url, current_price, market_price, harvest_time)
values
  -- Vegetables
  ('Fresh Tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80', 45, 60, 'Harvested 2 hours ago'),
  ('Organic Carrots', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80', 60, 85, 'Harvested today morning'),
  ('Green Spinach', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80', 30, 45, 'Harvested 4 hours ago'),
  ('Red Bell Pepper', 'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80', 120, 160, 'Harvested yesterday'),
  ('Fresh Broccoli', 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80', 85, 120, 'Harvested today'),
  ('Sweet Potatoes', 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?auto=format&fit=crop&w=300&q=80', 55, 70, 'Harvested 2 days ago'),
  ('Cauliflower', 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?auto=format&fit=crop&w=300&q=80', 40, 55, 'Harvested this morning'),
  ('Cucumber', 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=300&q=80', 25, 35, 'Harvested 5 hours ago'),
  
  -- Fruits
  ('Red Apples', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80', 180, 220, 'Fresh from Shimla'),
  ('Bananas', 'https://images.unsplash.com/photo-1603833665858-e61d17a86271?auto=format&fit=crop&w=300&q=80', 60, 80, 'Organic'),
  ('Strawberries', 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=300&q=80', 250, 300, 'Freshly picked'),
  ('Oranges', 'https://images.unsplash.com/photo-1547514354-9520a29f86b1?auto=format&fit=crop&w=300&q=80', 100, 140, 'Juicy & Sweet')
;
