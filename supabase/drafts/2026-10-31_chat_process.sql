-- DRAFT ONLY. DO NOT APPLY TO PRODUCTION.
-- Review against current Supabase schema and test on a development branch first.
begin;

create table if not exists public.omkc_conversations (
  id uuid primary key default gen_random_uuid(),
  title text not null default '' check (char_length(title) <= 120),
  conversation_type text not null check (conversation_type in ('direct','group','support')),
  created_by uuid not null references auth.users(id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.omkc_conversation_participants (
  conversation_id uuid not null references public.omkc_conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  participant_role text not null default 'member' check (participant_role in ('member','moderator')),
  joined_at timestamptz not null default now(),
  blocked_at timestamptz,
  primary key (conversation_id,user_id)
);

create table if not exists public.omkc_messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.omkc_conversations(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete restrict,
  body text not null check (char_length(body) between 1 and 4000),
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz
);

create index if not exists omkc_messages_conversation_created_idx
  on public.omkc_messages(conversation_id, created_at desc);
create index if not exists omkc_participants_user_idx
  on public.omkc_conversation_participants(user_id, conversation_id);

create table if not exists public.omkc_message_reports (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.omkc_messages(id) on delete cascade,
  reporter_id uuid not null references auth.users(id) on delete restrict,
  reason text not null check (char_length(reason) between 1 and 500),
  status text not null default 'open' check (status in ('open','reviewing','resolved','dismissed')),
  created_at timestamptz not null default now(),
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz
);

create table if not exists public.omkc_visitor_requests (
  id uuid primary key default gen_random_uuid(),
  visitor_name text not null check (char_length(visitor_name) between 1 and 80),
  visitor_email text not null check (char_length(visitor_email) between 3 and 254),
  topic text not null check (char_length(topic) between 1 and 80),
  message text not null check (char_length(message) between 1 and 1500),
  status text not null default 'new' check (status in ('new','assigned','answered','closed','spam')),
  created_at timestamptz not null default now(),
  assigned_to uuid references auth.users(id) on delete set null,
  handled_at timestamptz
);

alter table public.omkc_conversations enable row level security;
alter table public.omkc_conversation_participants enable row level security;
alter table public.omkc_messages enable row level security;
alter table public.omkc_message_reports enable row level security;
alter table public.omkc_visitor_requests enable row level security;

-- Verified-email and approved-member checks should be enforced by a hardened helper
-- or trusted server/Edge Function. Do not rely on client metadata or UI-only checks.
-- These policies are intentionally not enabled here because the live project's
-- membership approval schema and admin-role source must be reconciled first.
-- Public/anon users must never receive direct INSERT/SELECT access to private chat
-- tables or visitor request rows. Visitor requests must be accepted via a rate-limited
-- Edge Function/server endpoint with server-side validation and notification.
-- Add explicit participant-only policies after the approved-member helper is tested.
-- Avoid broad TO authenticated policies: authentication alone is not authorization.

commit;
