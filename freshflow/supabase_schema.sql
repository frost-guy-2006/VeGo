-- Create products table
create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text,
  current_price numeric not null,
  market_price numeric not null,
  harvest_time text,
  stock integer default 0,
  created_at timestamptz default now()
);

-- Enable Row Level Security (RLS)
alter table public.products enable row level security;

-- Create policy to allow public read access
create policy "Public products are viewable by everyone"
  on public.products for select
  using ( true );

-- Create orders table
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  total_amount numeric not null,
  status text check (status in ('pending', 'confirmed', 'delivered', 'cancelled')) default 'pending',
  items jsonb not null, -- Stores snapshot of cart items: [{product_id, name, price, quantity}]
  created_at timestamptz default now()
);

-- Enable RLS
alter table public.orders enable row level security;

-- Create policy to allow users to see their own orders
create policy "Users can see their own orders"
  on public.orders for select
  using ( auth.uid() = user_id );

-- Create policy to allow users to insert their own orders
create policy "Users can create their own orders"
  on public.orders for insert
  with check ( auth.uid() = user_id );
