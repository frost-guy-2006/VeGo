-- Seed Data for VeGo Products
-- Run this in your Supabase SQL Editor

delete from public.products; -- Clear existing products to avoid duplicates

insert into public.products (name, image_url, current_price, market_price, harvest_time, category)
values
  -- Vegetables
  ('Fresh Tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80', 45, 60, 'Harvested 2 hours ago', 'Vegetables'),
  ('Organic Carrots', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80', 60, 85, 'Harvested today morning', 'Vegetables'),
  ('Green Spinach', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80', 30, 45, 'Harvested 4 hours ago', 'Vegetables'),
  ('Red Bell Pepper', 'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80', 120, 160, 'Harvested yesterday', 'Vegetables'),
  ('Fresh Broccoli', 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80', 85, 120, 'Harvested today', 'Vegetables'),
  ('Sweet Potatoes', 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?auto=format&fit=crop&w=300&q=80', 55, 70, 'Harvested 2 days ago', 'Vegetables'),
  ('Cauliflower', 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ca3?auto=format&fit=crop&w=300&q=80', 40, 55, 'Harvested this morning', 'Vegetables'),
  ('Cucumber', 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&w=300&q=80', 25, 35, 'Harvested 5 hours ago', 'Vegetables'),
  
  -- Fruits
  ('Red Apples', 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=300&q=80', 180, 220, 'Fresh from Shimla', 'Fruits'),
  ('Bananas', 'https://images.unsplash.com/photo-1603833665858-e61d17a86271?auto=format&fit=crop&w=300&q=80', 60, 80, 'Organic', 'Fruits'),
  ('Strawberries', 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=300&q=80', 250, 300, 'Freshly picked', 'Fruits'),
  ('Oranges', 'https://images.unsplash.com/photo-1547514354-9520a29f86b1?auto=format&fit=crop&w=300&q=80', 100, 140, 'Juicy & Sweet', 'Fruits'),
  ('Mangoes', 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=300&q=80', 200, 280, 'Alphonso variety', 'Fruits'),
  ('Grapes', 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?auto=format&fit=crop&w=300&q=80', 120, 150, 'Seedless green', 'Fruits'),

  -- Dairy
  ('Fresh Milk', 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=300&q=80', 65, 70, 'Farm fresh daily', 'Dairy'),
  ('Greek Yogurt', 'https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=300&q=80', 120, 150, 'High protein', 'Dairy'),
  ('Cottage Cheese', 'https://images.unsplash.com/photo-1559561853-08451507cbe7?auto=format&fit=crop&w=300&q=80', 180, 220, 'Fresh paneer', 'Dairy'),
  ('Butter', 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?auto=format&fit=crop&w=300&q=80', 250, 280, 'Unsalted premium', 'Dairy'),
  ('Cheddar Cheese', 'https://images.unsplash.com/photo-1618164436241-4473940d1f5e?auto=format&fit=crop&w=300&q=80', 350, 400, 'Aged 12 months', 'Dairy'),

  -- Bakery
  ('Whole Wheat Bread', 'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=300&q=80', 45, 55, 'Baked fresh today', 'Bakery'),
  ('Croissants', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=300&q=80', 120, 150, 'Buttery & flaky', 'Bakery'),
  ('Chocolate Muffin', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=300&q=80', 80, 100, 'Double chocolate', 'Bakery'),
  ('Sourdough Loaf', 'https://images.unsplash.com/photo-1585478259715-1c093a7b7f77?auto=format&fit=crop&w=300&q=80', 180, 220, 'Artisan baked', 'Bakery'),
  ('Bagels', 'https://images.unsplash.com/photo-1558401391-7899b4bd5bbf?auto=format&fit=crop&w=300&q=80', 60, 80, 'Plain & sesame', 'Bakery'),

  -- Tea/Coffee
  ('Assam Tea', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?auto=format&fit=crop&w=300&q=80', 180, 220, 'Premium CTC', 'Tea/Coffee'),
  ('Green Tea', 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?auto=format&fit=crop&w=300&q=80', 250, 300, 'Japanese Sencha', 'Tea/Coffee'),
  ('Arabica Coffee', 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=300&q=80', 450, 550, 'Single origin', 'Tea/Coffee'),
  ('Instant Coffee', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=300&q=80', 280, 350, 'Premium blend', 'Tea/Coffee'),
  ('Earl Grey Tea', 'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?auto=format&fit=crop&w=300&q=80', 200, 250, 'Bergamot flavored', 'Tea/Coffee')
;
