-- Draft only: review and run in the intended Supabase project after confirming the project.
-- No database has been changed by adding this file to GitHub.
create extension if not exists pgcrypto;

create type public.okg_activity_status as enum ('draft', 'pending_review', 'approved', 'rejected');
create type public.okg_visibility as enum ('private', 'family', 'public');

create table public.okg_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  role text not null default 'child' check (role in ('child', 'guardian', 'admin')),
  guardian_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.okg_activities (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 120),
  category text not null check (category in ('study', 'school', 'project', 'video', 'art', 'cricket', 'dance')),
  description text not null check (char_length(description) between 1 and 2000),
  activity_date date,
  status public.okg_activity_status not null default 'draft',
  visibility public.okg_visibility not null default 'private',
  approved_by uuid references auth.users(id) on delete set null,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint okg_approval_consistency check (
    (status = 'approved' and approved_by is not null and approved_at is not null)
    or status <> 'approved'
  ),
  constraint okg_public_requires_approval check (
    visibility <> 'public' or status = 'approved'
  )
);

create table public.okg_media_assets (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.okg_activities(id) on delete cascade,
  uploader_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null check (mime_type in ('image/jpeg','image/png','image/webp','video/mp4','video/webm','video/quicktime')),
  size_bytes bigint not null check (size_bytes > 0 and size_bytes <= 52428800),
  status public.okg_activity_status not null default 'draft',
  created_at timestamptz not null default now()
);

create table public.okg_activity_approvals (
  id uuid primary key default gen_random_uuid(),
  activity_id uuid not null references public.okg_activities(id) on delete cascade,
  reviewer_id uuid not null references auth.users(id) on delete restrict,
  decision text not null check (decision in ('approved', 'rejected')),
  notes text check (notes is null or char_length(notes) <= 1000),
  created_at timestamptz not null default now()
);

alter table public.okg_profiles enable row level security;
alter table public.okg_activities enable row level security;
alter table public.okg_media_assets enable row level security;
alter table public.okg_activity_approvals enable row level security;

-- Profiles can be read by the account owner, their linked guardian, or an admin.
create policy "profile owner guardian admin read"
on public.okg_profiles for select to authenticated
using (
  user_id = (select auth.uid())
  or guardian_user_id = (select auth.uid())
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
);

-- User may create only their own base profile; role remains child by default.
create policy "user creates own child profile"
on public.okg_profiles for insert to authenticated
with check (user_id = (select auth.uid()) and role = 'child' and guardian_user_id is null);

-- Do not grant authenticated users UPDATE on role/guardian linkage in production.
-- Provision guardians/admins and link guardian_user_id through a trusted admin process.

create policy "activity owner guardian or admin reads"
on public.okg_activities for select to authenticated
using (
  author_id = (select auth.uid())
  or exists (
    select 1 from public.okg_profiles owner_profile
    where owner_profile.user_id = okg_activities.author_id
      and owner_profile.guardian_user_id = (select auth.uid())
  )
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
);

create policy "public can read approved public activities"
on public.okg_activities for select to anon, authenticated
using (status = 'approved' and visibility = 'public');

create policy "owner creates private draft"
on public.okg_activities for insert to authenticated
with check (
  author_id = (select auth.uid())
  and status in ('draft', 'pending_review')
  and visibility in ('private', 'family')
);

create policy "owner edits own unapproved activity"
on public.okg_activities for update to authenticated
using (
  author_id = (select auth.uid())
  and status in ('draft', 'pending_review', 'rejected')
)
with check (
  author_id = (select auth.uid())
  and status in ('draft', 'pending_review', 'rejected')
  and visibility in ('private', 'family')
);

create policy "guardian or admin can review activities"
on public.okg_activities for update to authenticated
using (
  exists (
    select 1 from public.okg_profiles owner_profile
    where owner_profile.user_id = okg_activities.author_id
      and owner_profile.guardian_user_id = (select auth.uid())
  )
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
)
with check (
  exists (
    select 1 from public.okg_profiles owner_profile
    where owner_profile.user_id = okg_activities.author_id
      and owner_profile.guardian_user_id = (select auth.uid())
  )
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
);

create policy "media owner guardian admin reads metadata"
on public.okg_media_assets for select to authenticated
using (
  uploader_id = (select auth.uid())
  or exists (
    select 1 from public.okg_profiles owner_profile
    where owner_profile.user_id = okg_media_assets.uploader_id
      and owner_profile.guardian_user_id = (select auth.uid())
  )
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
);

create policy "uploader registers own media metadata"
on public.okg_media_assets for insert to authenticated
with check (uploader_id = (select auth.uid()) and status in ('draft', 'pending_review'));

create policy "guardian or admin reads approval history"
on public.okg_activity_approvals for select to authenticated
using (
  reviewer_id = (select auth.uid())
  or exists (
    select 1 from public.okg_activities a
    join public.okg_profiles p on p.user_id = a.author_id
    where a.id = okg_activity_approvals.activity_id
      and p.guardian_user_id = (select auth.uid())
  )
  or exists (
    select 1 from public.okg_profiles me
    where me.user_id = (select auth.uid()) and me.role = 'admin'
  )
);

create policy "guardian or admin records approval"
on public.okg_activity_approvals for insert to authenticated
with check (
  reviewer_id = (select auth.uid())
  and exists (
    select 1 from public.okg_activities a
    left join public.okg_profiles p on p.user_id = a.author_id
    left join public.okg_profiles me on me.user_id = (select auth.uid())
    where a.id = activity_id
      and (p.guardian_user_id = (select auth.uid()) or me.role = 'admin')
  )
);

-- Storage bucket/policies are intentionally not created here. Create a PRIVATE bucket
-- and policies after validating upload, delete, and approved-media access requirements.
-- Additional production hardening required: restrict column updates (especially role,
-- guardian_user_id, status, approved_by, approved_at), enforce reviewer linkage via a
-- trusted server/RPC, add updated_at trigger, and test all RLS paths before launch.
