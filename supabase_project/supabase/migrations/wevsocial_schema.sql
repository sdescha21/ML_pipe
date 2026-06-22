-- WevSocial core schema
create extension if not exists "uuid-ossp";
create table if not exists profiles (
  id serial primary key,
  "userId" integer unique,
  auth_id text unique,
  full_name text,
  display_name text,
  username text unique,
  email text unique,
  profile_photo_url text,
  avatar_url text,
  avatar_storage_path text,
  cover_photo_url text,
  cover_storage_path text,
  headline text,
  phone_number text,
  bio text,
  date_of_birth date,
  gender text,
  city text,
  country text,
  hourly_rate numeric,
  rating numeric,
  review_count integer default 0,
  roles text[] not null default '{"Companion"}',
  activities text[] default '{}',
  interests text[] default '{}',
  availability text[] default '{}',
  is_verified boolean default false,
  is_bouncer_verified boolean default false,
  certifications text[] default '{}',
  incident_history_count integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
-- Interests catalog
create table if not exists interests (
  id uuid primary key default uuid_generate_v4(),
  name text unique not null,
  category text,
  icon_url text,
  is_active boolean default true,
  created_at timestamptz default now()
);
-- Junction for user interests
create table if not exists user_interests (
  id uuid primary key default uuid_generate_v4(),
  user_id integer references profiles(id) on delete cascade not null,
  interest_id uuid references interests(id) on delete cascade not null,
  created_at timestamptz default now(),
  unique (user_id, interest_id)
);
-- Payment methods
create table if not exists payment_methods (
  id uuid primary key default uuid_generate_v4(),
  user_id integer references profiles(id) on delete cascade not null,
  brand text not null,
  last4 text not null,
  exp_month smallint not null,
  exp_year smallint not null,
  is_default boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
-- Simple interests seed
insert into interests (name, category)
values
 ('Sports','Active'),
 ('Travel','Leisure'),
 ('Food','Social'),
 ('Arts','Culture'),
 ('Technology','Learning'),
 ('Fitness','Active'),
 ('Music','Culture'),
 ('Nightlife','Social'),
 ('Outdoors','Active'),
 ('Wellness','Health')
ON CONFLICT DO NOTHING;
create table if not exists activities (
  id serial primary key,
  "userId" integer references profiles(id),
  title text not null,
  image text,
  category text not null,
  vibe text,
  price numeric,
  host_id integer references profiles(id),
  created_at timestamptz default now()
);
create table if not exists bookings (
  id uuid primary key default uuid_generate_v4(),
  companion_id integer references profiles(id) not null,
  bouncer_id integer references profiles(id),
  client_id integer references profiles(id),
  date date not null,
  time text not null,
  duration integer not null,
  status text not null check (status in ('upcoming','active','completed','canceled')),
  total_amount numeric not null,
  escrow_status text not null check (escrow_status in ('held','released','refunded')),
  created_at timestamptz default now()
);
create index if not exists idx_bookings_companion on bookings(companion_id);
create index if not exists idx_bookings_bouncer on bookings(bouncer_id);
create index if not exists idx_bookings_client on bookings(client_id);
insert into profiles ("userId", display_name, avatar_url, bio, roles, hourly_rate, rating, review_count, is_verified, is_bouncer_verified, certifications, activities)
values
 (1, 'Elena Vance','https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200','Art historian and city explorer. I specialize in curated museum tours and quiet gallery visits.', '{"Companion"}',55,4.9,142,true,false,'{}','{"Museums","Coffee"}'),
 (2, 'Marcus Thorne','https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200','Security background with a passion for live music. I provide safe companionship for late-night venues.', '{"Companion","Bouncer"}',85,4.8,96,true,true,'{"Close Protection","First Aid"}','{"Concerts","Nightlife"}'),
 (3, 'Sarah Shield','https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200','10 years in executive protection. Discreet, professional, and observant. Your safety is my priority.', '{"Bouncer"}',95,5.0,54,true,true,'{"Armed Guard","SIA Licensed"}','{"Active"}')
ON CONFLICT DO NOTHING;
-- Sample activities seed removed for idempotency against existing datasets

 -- Sample activity + booking seed removed for idempotency against existing datasets;