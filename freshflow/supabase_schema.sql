-- Create products table
create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text,
  current_price numeric not null,
  market_price numeric not null,
  harvest_time text,
  stock integer default 0,
  category text, -- Product category (Vegetables, Fruits, Dairy, Bakery, Tea/Coffee)
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

-- Create profiles table (extends auth.users)
create table public.profiles (
  id uuid primary key references auth.users on delete cascade,
  first_name text,
  last_name text,
  phone text,
  avatar_url text,
  created_at timestamptz default now()
);

-- Enable RLS for profiles
alter table public.profiles enable row level security;

-- Profiles RLS
create policy "Public profiles are viewable by everyone"
  on public.profiles for select
  using ( true );

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile"
  on public.profiles for update
  using ( auth.uid() = id );

-- Create addresses table
create table public.addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  street text not null,
  city text not null,
  state text not null,
  zip_code text not null,
  country text default 'USA',
  is_default boolean default false,
  created_at timestamptz default now()
);

-- Enable RLS for addresses
alter table public.addresses enable row level security;

-- Addresses RLS
create policy "Users can see their own addresses"
  on public.addresses for select
  using ( auth.uid() = user_id );

create policy "Users can insert their own addresses"
  on public.addresses for insert
  with check ( auth.uid() = user_id );

create policy "Users can update their own addresses"
  on public.addresses for update
  using ( auth.uid() = user_id );

create policy "Users can delete their own addresses"
  on public.addresses for delete
  using ( auth.uid() = user_id );

-- Storage: Bucket definitions (Run these in Supabase Dashboard SQL Editor if needed)
-- insert into storage.buckets (id, name, public) values ('product-images', 'product-images', true);

-- Storage Policies (Example for 'product-images' bucket)
-- create policy "Public Access" on storage.objects for select using ( bucket_id = 'product-images' );
-- create policy "Admin Upload" on storage.objects for insert with check ( bucket_id = 'product-images' and auth.role() = 'service_role' );
