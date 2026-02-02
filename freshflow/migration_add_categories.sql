-- Migration: Add category column and seed products
-- Run this in your Supabase SQL Editor

-- Step 1: Add the category column if it doesn't exist
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS category text;

-- Step 2: Add harvest_time column if it doesn't exist (optional)
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS harvest_time text;

-- Step 3: Add stock column if it doesn't exist
ALTER TABLE public.products ADD COLUMN IF NOT EXISTS stock integer DEFAULT 0;

-- Step 4: Clear existing products
DELETE FROM public.products;

-- Step 5: Insert new categorized data
INSERT INTO public.products (name, image_url, current_price, market_price, harvest_time, stock, category)
VALUES
  -- Vegetables
  ('Fresh Tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80', 45, 60, 'Harvested 2 hours ago', 100, 'Vegetables'),
  ('Organic Carrots', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80', 60, 85, 'Harvested today morning', 50, 'Vegetables'),
  ('Green Spinach', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80', 30, 45, 'Harvested 4 hours ago', 30, 'Vegetables'),
  ('Red Bell Pepper', 'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80', 120, 160, 'Harvested yesterday', 40, 'Vegetables'),
  ('Fresh Broccoli', 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80', 85, 120, 'Harvested today', 60, 'Vegetables'),
  ('Cucumber', 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=300&q=80', 25, 35, 'Harvested 5 hours ago', 45, 'Vegetables'),
  
  -- Fruits
  ('Red Apples', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80', 180, 220, 'Fresh from Shimla', 80, 'Fruits'),
  ('Bananas', 'https://images.unsplash.com/photo-1603833665858-e61d17a86271?auto=format&fit=crop&w=300&q=80', 60, 80, 'Organic', 70, 'Fruits'),
  ('Strawberries', 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=300&q=80', 250, 300, 'Freshly picked', 25, 'Fruits'),
  ('Oranges', 'https://images.unsplash.com/photo-1547514354-9520a29f86b1?auto=format&fit=crop&w=300&q=80', 100, 140, 'Juicy & Sweet', 60, 'Fruits'),
  ('Mangoes', 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=300&q=80', 200, 280, 'Alphonso variety', 40, 'Fruits'),
  
  -- Dairy
  ('Fresh Milk', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=300&q=80', 65, 70, 'Farm fresh daily', 100, 'Dairy'),
  ('Greek Yogurt', 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=300&q=80', 120, 150, 'High protein', 50, 'Dairy'),
  ('Cottage Cheese', 'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=300&q=80', 180, 220, 'Fresh paneer', 35, 'Dairy'),
  ('Butter', 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=300&q=80', 250, 280, 'Unsalted premium', 45, 'Dairy'),
  
  -- Bakery
  ('Whole Wheat Bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80', 45, 55, 'Baked fresh today', 80, 'Bakery'),
  ('Croissants', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80', 120, 150, 'Buttery & flaky', 30, 'Bakery'),
  ('Chocolate Muffin', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=300&q=80', 80, 100, 'Double chocolate', 40, 'Bakery'),
  ('Bagels', 'https://images.unsplash.com/photo-1558401391-7899b4bd5bbf?auto=format&fit=crop&w=300&q=80', 60, 80, 'Plain & sesame', 50, 'Bakery'),
  
  -- Tea/Coffee
  ('Assam Tea', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=300&q=80', 180, 220, 'Premium CTC', 60, 'Tea/Coffee'),
  ('Green Tea', 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?auto=format&fit=crop&w=300&q=80', 250, 300, 'Japanese Sencha', 35, 'Tea/Coffee'),
  ('Arabica Coffee', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=300&q=80', 450, 550, 'Single origin', 25, 'Tea/Coffee'),
  ('Earl Grey Tea', 'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?auto=format&fit=crop&w=300&q=80', 200, 250, 'Bergamot flavored', 40, 'Tea/Coffee')
;
