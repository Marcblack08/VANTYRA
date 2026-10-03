create extension if not exists pgcrypto;
create type public.user_role as enum ('customer','admin');
create type public.order_status as enum ('pending','paid','processing','shipped','delivered','cancelled');
create table public.profiles(id uuid primary key references auth.users(id) on delete cascade,full_name text,avatar_url text,role public.user_role not null default 'customer',created_at timestamptz not null default now());
create table public.categories(id uuid primary key default gen_random_uuid(),name text not null,slug text not null unique,created_at timestamptz not null default now());
create table public.products(id uuid primary key default gen_random_uuid(),category_id uuid references public.categories(id) on delete set null,name text not null,slug text not null unique,description text,price numeric(12,2) not null check(price>=0),sale_price numeric(12,2) check(sale_price is null or sale_price>=0),stock integer not null default 0 check(stock>=0),images text[] not null default '{}',active boolean not null default true,created_by uuid references auth.users(id) on delete set null,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table public.cart_items(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete cascade,product_id uuid not null references public.products(id) on delete cascade,quantity integer not null check(quantity>0),created_at timestamptz not null default now(),unique(user_id,product_id));
create table public.favorites(user_id uuid not null references auth.users(id) on delete cascade,product_id uuid not null references public.products(id) on delete cascade,created_at timestamptz not null default now(),primary key(user_id,product_id));
create table public.orders(id uuid primary key default gen_random_uuid(),user_id uuid not null references auth.users(id) on delete restrict,status public.order_status not null default 'pending',subtotal numeric(12,2) not null check(subtotal>=0),tax numeric(12,2) not null default 0 check(tax>=0),shipping numeric(12,2) not null default 0 check(shipping>=0),total numeric(12,2) not null check(total>=0),payment_provider text,payment_reference text,created_at timestamptz not null default now());
create table public.order_items(id uuid primary key default gen_random_uuid(),order_id uuid not null references public.orders(id) on delete cascade,product_id uuid references public.products(id) on delete set null,product_name text not null,unit_price numeric(12,2) not null check(unit_price>=0),quantity integer not null check(quantity>0),created_at timestamptz not null default now());
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.cart_items enable row level security;
alter table public.favorites enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin') $$;
create policy profiles_self on public.profiles for select using(id=auth.uid() or public.is_admin());
create policy categories_read on public.categories for select using(true);
create policy categories_admin on public.categories for all using(public.is_admin()) with check(public.is_admin());
create policy products_read on public.products for select using(active=true or public.is_admin());
create policy products_admin on public.products for all using(public.is_admin()) with check(public.is_admin());
create policy cart_owner on public.cart_items for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy favorites_owner on public.favorites for all using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy orders_owner on public.orders for select using(user_id=auth.uid() or public.is_admin());
create policy order_items_owner on public.order_items for select using(public.is_admin() or exists(select 1 from public.orders o where o.id=order_id and o.user_id=auth.uid()));


create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, avatar_url, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'),
    new.raw_user_meta_data->>'avatar_url',
    case when lower(coalesce(new.email,'')) = 'marcjjbeltran08@gmail.com'
         then 'admin'::public.user_role else 'customer'::public.user_role end
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

create index if not exists products_category_idx on public.products(category_id);
create index if not exists products_active_idx on public.products(active);
create index if not exists cart_items_user_idx on public.cart_items(user_id);
create index if not exists orders_user_idx on public.orders(user_id);
create index if not exists orders_status_idx on public.orders(status);


insert into storage.buckets (id, name, public)
values ('product-images','product-images',true)
on conflict (id) do nothing;

create policy "product_images_public_read"
on storage.objects for select
using (bucket_id = 'product-images');

create policy "product_images_admin_insert"
on storage.objects for insert
with check (bucket_id = 'product-images' and public.is_admin());

create policy "product_images_admin_update"
on storage.objects for update
using (bucket_id = 'product-images' and public.is_admin())
with check (bucket_id = 'product-images' and public.is_admin());

create policy "product_images_admin_delete"
on storage.objects for delete
using (bucket_id = 'product-images' and public.is_admin());
