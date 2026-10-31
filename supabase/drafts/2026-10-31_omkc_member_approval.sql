-- DRAFT ONLY — do not apply until reviewed against the live project.
-- OM Krishna Connect member approval foundation.
-- Authentication passwords and reset links remain managed by Supabase Auth.
-- This draft intentionally does not modify the existing homepage/login or production schema.

begin;

create or replace function public.omkc_is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_profiles fp
    where fp.user_id = auth.uid()
      and fp.role = 'parent_admin'
  );
$$;

revoke all on function public.omkc_is_admin() from public;
grant execute on function public.omkc_is_admin() to authenticated;

create table if not exists public.omkc_member_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 80),
  requested_categories text[] not null default array['public_member']::text[],
  account_status text not null default 'pending'
    check (account_status in ('pending','approved','rejected','suspended')),
  approved_by uuid references auth.users(id) on delete set null,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint omkc_categories_valid check (
    requested_categories <@ array[
      'public_member',
      'om_friend',
      'om_school_friend',
      'krishna_friend',
      'krishna_school_friend',
      'om_krishna_common_friend',
      'family_member'
    ]::text[]
  )
);

create table if not exists public.omkc_admin_audit_log (
  id bigint generated always as identity primary key,
  actor_user_id uuid references auth.users(id) on delete set null,
  action text not null check (char_length(action) between 1 and 80),
  target_user_id uuid references auth.users(id) on delete set null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.omkc_member_profiles enable row level security;
alter table public.omkc_admin_audit_log enable row level security;

-- Members can read only their own profile. No client-side update policy is provided,
-- so users cannot approve themselves or alter account_status/approved_by.
drop policy if exists "omkc members read own profile" on public.omkc_member_profiles;
create policy "omkc members read own profile"
  on public.omkc_member_profiles for select to authenticated
  using (user_id = auth.uid() or public.omkc_is_admin());

drop policy if exists "omkc admins insert member profile" on public.omkc_member_profiles;
create policy "omkc admins insert member profile"
  on public.omkc_member_profiles for insert to authenticated
  with check (public.omkc_is_admin());

drop policy if exists "omkc admins update member profile" on public.omkc_member_profiles;
create policy "omkc admins update member profile"
  on public.omkc_member_profiles for update to authenticated
  using (public.omkc_is_admin())
  with check (public.omkc_is_admin());

drop policy if exists "omkc admins read audit log" on public.omkc_admin_audit_log;
create policy "omkc admins read audit log"
  on public.omkc_admin_audit_log for select to authenticated
  using (public.omkc_is_admin());

drop policy if exists "omkc admins append audit log" on public.omkc_admin_audit_log;
create policy "omkc admins append audit log"
  on public.omkc_admin_audit_log for insert to authenticated
  with check (public.omkc_is_admin());

grant select on public.omkc_member_profiles to authenticated;
grant insert, update on public.omkc_member_profiles to authenticated;
grant select, insert on public.omkc_admin_audit_log to authenticated;
grant usage, select on sequence public.omkc_admin_audit_log_id_seq to authenticated;

commit;

-- Before use, add server-side/Edge Function workflows:
-- 1) Signup: create Auth user with email confirmation enabled, then create pending profile
--    through a trusted server/Edge Function; never accept account_status from the browser.
-- 2) Approval: require an authenticated parent_admin, validate pending -> approved/rejected,
--    write audit log in the same transaction, then notify the user.
-- 3) Admin email: recipient comes from server secret ADMIN_APPROVAL_EMAIL. Email links only
--    open the authenticated admin dashboard; GET requests never approve/reject.
-- 4) Password reset: use Supabase Auth resetPasswordForEmail and updateUser({password});
--    Option 2 creates an admin help request and sends the same provider-generated reset link
--    only to the verified account email. Never email or log a password.
-- 5) Enforce approved status server-side for chat/call access; RLS on this profile alone
--    does not secure future chat tables. Add rate limits, abuse reporting, and retention rules.
