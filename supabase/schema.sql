-- Hamilton Ezeonu website CMS (run in a dedicated Supabase project)
create extension if not exists pgcrypto;
create table if not exists public.site_roles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null check(role in ('admin','viewer')) default 'viewer',
 created_at timestamptz not null default now()
);
create table if not exists public.site_content (
 id uuid primary key default gen_random_uuid(),
 type text not null check(type in ('page','post','announcement','video','image','setting')),
 title text not null,
 slug text not null unique,
 summary text not null default '',
 body text not null default '',
 media_url text,
 published boolean not null default false,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists public.site_enquiries (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 email text not null,
 topic text not null default 'General',
 message text not null,
 created_at timestamptz not null default now(),
 read boolean not null default false
);
create or replace function public.is_site_admin() returns boolean
language sql stable security definer set search_path='' as $$
 select exists(select 1 from public.site_roles where user_id=(select auth.uid()) and role='admin');
$$;
revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to authenticated;
create or replace function public.assign_first_site_admin() returns trigger
language plpgsql security definer set search_path='' as $$
begin
 perform pg_advisory_xact_lock(765032114);
 insert into public.site_roles(user_id,role)
 values(new.id,case when not exists(select 1 from public.site_roles where role='admin') then 'admin' else 'viewer' end);
 return new;
end;
$$;
drop trigger if exists site_auth_registration on auth.users;
create trigger site_auth_registration after insert on auth.users for each row execute function public.assign_first_site_admin();
alter table public.site_roles enable row level security;
alter table public.site_content enable row level security;
alter table public.site_enquiries enable row level security;
create policy "own role" on public.site_roles for select to authenticated using (user_id=(select auth.uid()) or public.is_site_admin());
create policy "public published content" on public.site_content for select to anon,authenticated using (published or public.is_site_admin());
create policy "admin insert content" on public.site_content for insert to authenticated with check(public.is_site_admin());
create policy "admin update content" on public.site_content for update to authenticated using(public.is_site_admin()) with check(public.is_site_admin());
create policy "admin delete content" on public.site_content for delete to authenticated using(public.is_site_admin());
create policy "public enquiry insert" on public.site_enquiries for insert to anon,authenticated with check(length(name) between 2 and 200 and length(email) between 5 and 320 and length(message) between 5 and 5000);
create policy "admin enquiry read" on public.site_enquiries for select to authenticated using(public.is_site_admin());
create policy "admin enquiry update" on public.site_enquiries for update to authenticated using(public.is_site_admin()) with check(public.is_site_admin());
create policy "admin enquiry delete" on public.site_enquiries for delete to authenticated using(public.is_site_admin());
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('site-media','site-media',true,52428800,array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm']) on conflict(id) do nothing;
create policy "public read media" on storage.objects for select to anon,authenticated using(bucket_id='site-media');
create policy "admin upload media" on storage.objects for insert to authenticated with check(bucket_id='site-media' and public.is_site_admin());
create policy "admin update media" on storage.objects for update to authenticated using(bucket_id='site-media' and public.is_site_admin()) with check(bucket_id='site-media' and public.is_site_admin());
create policy "admin delete media" on storage.objects for delete to authenticated using(bucket_id='site-media' and public.is_site_admin());
