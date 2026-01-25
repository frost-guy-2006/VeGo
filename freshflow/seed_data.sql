-- Seed Data for FreshFlow Products

insert into public.products (name, image_url, current_price, market_price, harvest_time)
values
  ('Fresh Tomatoes', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=300&q=80', 45, 60, 'Harvested 2 hours ago'),
  ('Organic Carrots', 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?auto=format&fit=crop&w=300&q=80', 60, 85, 'Harvested today morning'),
  ('Green Spinach', 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=300&q=80', 30, 45, 'Harvested 4 hours ago'),
  ('Red Bell Pepper', 'https://images.unsplash.com/photo-1563565375-f3fdf5dbc240?auto=format&fit=crop&w=300&q=80', 120, 160, 'Harvested yesterday'),
  ('Fresh Broccoli', 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=300&q=80', 85, 120, 'Harvested today'),
  ('Sweet Potatoes', 'https://images.unsplash.com/photo-1596097635121-14b63b7a0c19?auto=format&fit=crop&w=300&q=80', 55, 70, 'Harvested 2 days ago');
