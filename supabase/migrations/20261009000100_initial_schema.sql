create extension if not exists pgcrypto;

create type public.organization_role as enum ('platform_admin', 'organization_admin', 'project_manager', 'team_leader', 'employee');
create type public.task_status as enum ('backlog', 'todo', 'in_progress', 'blocked', 'in_review', 'completed', 'cancelled');
create type public.task_priority as enum ('low', 'normal', 'high', 'critical');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  avatar_path text,
  locale text not null default 'en' check (locale in ('en', 'ar')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 160),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.organization_members (
  organization_id uuid not null references public.organizations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.organization_role not null default 'employee',
  is_active boolean not null default true,
  joined_at timestamptz not null default now(),
  primary key (organization_id, user_id)
);

create table public.invitations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  email text not null check (email = lower(email)),
  role public.organization_role not null default 'employee',
  invited_by uuid not null references auth.users(id),
  accepted_by uuid references auth.users(id),
  expires_at timestamptz not null default (now() + interval '7 days'),
  accepted_at timestamptz,
  created_at timestamptz not null default now(),
  unique (organization_id, email),
  check ((accepted_at is null) = (accepted_by is null))
);

create table public.departments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 160),
  created_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  department_id uuid references public.departments(id) on delete set null,
  name text not null check (char_length(trim(name)) between 1 and 160),
  leader_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  unique (organization_id, name)
);

create table public.team_members (
  team_id uuid not null references public.teams(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (team_id, user_id)
);

create table public.projects (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 200),
  description text,
  status text not null default 'active' check (status in ('planning', 'active', 'paused', 'completed', 'archived')),
  starts_on date,
  due_on date,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (due_on is null or starts_on is null or due_on >= starts_on)
);

create table public.project_members (
  project_id uuid not null references public.projects(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('manager', 'member', 'viewer')),
  added_at timestamptz not null default now(),
  primary key (project_id, user_id)
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 300),
  description text,
  creator_id uuid not null references auth.users(id),
  assignee_id uuid references public.profiles(id) on delete set null,
  status public.task_status not null default 'backlog',
  priority public.task_priority not null default 'normal',
  starts_at timestamptz,
  deadline timestamptz,
  progress smallint not null default 0 check (progress between 0 and 100),
  estimated_minutes integer check (estimated_minutes is null or estimated_minutes > 0),
  completed_at timestamptz,
  archived_at timestamptz,
  version bigint not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, organization_id),
  check (deadline is null or starts_at is null or deadline >= starts_at),
  check ((status = 'completed') = (completed_at is not null))
);

create table public.task_assignees (
  task_id uuid not null references public.tasks(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  added_at timestamptz not null default now(),
  primary key (task_id, user_id)
);

create table public.task_dependencies (
  task_id uuid not null references public.tasks(id) on delete cascade,
  depends_on_task_id uuid not null references public.tasks(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (task_id, depends_on_task_id),
  check (task_id <> depends_on_task_id)
);

create table public.task_checklist_items (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 300),
  is_completed boolean not null default false,
  position integer not null default 0 check (position >= 0),
  created_at timestamptz not null default now()
);

create table public.task_comments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  author_id uuid not null references auth.users(id),
  body text not null check (char_length(trim(body)) between 1 and 10000),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.task_attachments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  uploaded_by uuid not null references auth.users(id),
  bucket_id text not null default 'private-attachments',
  object_path text not null unique,
  file_name text not null,
  content_type text not null,
  byte_size bigint not null check (byte_size > 0 and byte_size <= 52428800),
  created_at timestamptz not null default now()
);

create table public.task_work_logs (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  user_id uuid not null references auth.users(id),
  minutes integer not null check (minutes > 0),
  note text,
  worked_at timestamptz not null default now()
);

create table public.task_status_history (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  changed_by uuid not null references auth.users(id),
  from_status public.task_status,
  to_status public.task_status not null,
  created_at timestamptz not null default now()
);

create table public.task_approvals (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  reviewer_id uuid not null references auth.users(id),
  decision text not null check (decision in ('approved', 'rejected')),
  feedback text,
  created_at timestamptz not null default now(),
  check (decision <> 'rejected' or char_length(trim(coalesce(feedback, ''))) > 0)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  organization_id uuid references public.organizations(id) on delete cascade,
  kind text not null,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  dedupe_key text unique,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.notification_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  push_enabled boolean not null default true,
  email_enabled boolean not null default true,
  deadline_reminders boolean not null default true,
  updated_at timestamptz not null default now()
);

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('android', 'ios', 'web')),
  last_seen_at timestamptz not null default now()
);

create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid references public.organizations(id) on delete cascade,
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index tasks_org_status_deadline_idx on public.tasks (organization_id, status, deadline);
create index tasks_project_idx on public.tasks (project_id, updated_at desc);
create index tasks_assignee_idx on public.tasks (assignee_id, status, deadline);
create index project_members_user_idx on public.project_members (user_id, project_id);
create index notifications_user_created_idx on public.notifications (user_id, created_at desc);
create index audit_logs_org_created_idx on public.audit_logs (organization_id, created_at desc);
create index invitations_email_idx on public.invitations (email, expires_at);

create schema if not exists private;

create or replace function private.is_org_member(target_org uuid, target_user uuid default auth.uid())
returns boolean language sql stable security definer set search_path = public, private
as $$ select exists (select 1 from public.organization_members m where m.organization_id = target_org and m.user_id = target_user and m.is_active); $$;

create or replace function private.is_org_admin(target_org uuid, target_user uuid default auth.uid())
returns boolean language sql stable security definer set search_path = public, private
as $$ select exists (select 1 from public.organization_members m where m.organization_id = target_org and m.user_id = target_user and m.is_active and m.role in ('platform_admin', 'organization_admin')); $$;

create or replace function private.is_project_member(target_project uuid, target_user uuid default auth.uid())
returns boolean language sql stable security definer set search_path = public, private
as $$ select exists (select 1 from public.project_members pm join public.projects p on p.id = pm.project_id join public.organization_members om on om.organization_id = p.organization_id and om.user_id = pm.user_id and om.is_active where pm.project_id = target_project and pm.user_id = target_user); $$;

create or replace function private.task_org(target_task uuid)
returns uuid language sql stable security definer set search_path = public, private
as $$ select organization_id from public.tasks where id = target_task; $$;

alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.invitations enable row level security;
alter table public.departments enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.tasks enable row level security;
alter table public.task_assignees enable row level security;
alter table public.task_dependencies enable row level security;
alter table public.task_checklist_items enable row level security;
alter table public.task_comments enable row level security;
alter table public.task_attachments enable row level security;
alter table public.task_work_logs enable row level security;
alter table public.task_status_history enable row level security;
alter table public.task_approvals enable row level security;
alter table public.notifications enable row level security;
alter table public.notification_preferences enable row level security;
alter table public.device_tokens enable row level security;
alter table public.audit_logs enable row level security;

create policy profiles_self_or_org on public.profiles for select using (id = auth.uid() or exists (select 1 from public.organization_members m where m.user_id = profiles.id and private.is_org_member(m.organization_id)));
create policy profiles_self_update on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy organizations_member_read on public.organizations for select using (private.is_org_member(id));
create policy organizations_creator_insert on public.organizations for insert with check (created_by = auth.uid());
create policy organizations_admin_update on public.organizations for update using (private.is_org_admin(id)) with check (private.is_org_admin(id));
create policy org_members_member_read on public.organization_members for select using (private.is_org_member(organization_id));
create policy org_members_admin_write on public.organization_members for all using (private.is_org_admin(organization_id)) with check (private.is_org_admin(organization_id));
create policy invitations_admin_read on public.invitations for select using (private.is_org_admin(organization_id));
create policy invitations_admin_delete on public.invitations for delete using (private.is_org_admin(organization_id));

create policy departments_member_all on public.departments for all using (private.is_org_member(organization_id)) with check (private.is_org_member(organization_id));
create policy teams_member_all on public.teams for all using (private.is_org_member(organization_id)) with check (private.is_org_member(organization_id));
create policy team_members_member_all on public.team_members for all using (exists (select 1 from public.teams t where t.id = team_id and private.is_org_member(t.organization_id))) with check (exists (select 1 from public.teams t where t.id = team_id and private.is_org_member(t.organization_id)));
create policy projects_member_read on public.projects for select using (private.is_org_member(organization_id));
create policy projects_member_insert on public.projects for insert with check (private.is_org_member(organization_id) and created_by = auth.uid());
create policy projects_member_update on public.projects for update using (private.is_org_member(organization_id)) with check (private.is_org_member(organization_id));
create policy projects_admin_delete on public.projects for delete using (private.is_org_admin(organization_id));
create policy project_members_member_all on public.project_members for all using (exists (select 1 from public.projects p where p.id = project_id and private.is_org_member(p.organization_id))) with check (private.is_project_member(project_id) or exists (select 1 from public.projects p where p.id = project_id and private.is_org_admin(p.organization_id)));

create policy tasks_member_read on public.tasks for select using (private.is_org_member(organization_id));
create policy tasks_member_insert on public.tasks for insert with check (private.is_org_member(organization_id) and creator_id = auth.uid() and exists (select 1 from public.projects p where p.id = project_id and p.organization_id = tasks.organization_id));
create policy tasks_member_update on public.tasks for update using (private.is_org_member(organization_id)) with check (private.is_org_member(organization_id) and exists (select 1 from public.projects p where p.id = project_id and p.organization_id = tasks.organization_id));
create policy tasks_admin_delete on public.tasks for delete using (private.is_org_admin(organization_id));

create policy task_assignees_member_all on public.task_assignees for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)));
create policy task_dependencies_member_all on public.task_dependencies for all using (private.is_org_member(private.task_org(task_id)) and private.task_org(task_id) = private.task_org(depends_on_task_id)) with check (private.is_org_member(private.task_org(task_id)) and private.task_org(task_id) = private.task_org(depends_on_task_id));
create policy task_checklist_member_all on public.task_checklist_items for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)));
create policy task_comments_member_all on public.task_comments for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)) and author_id = auth.uid());
create policy task_attachments_member_all on public.task_attachments for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)) and uploaded_by = auth.uid());
create policy task_work_logs_member_all on public.task_work_logs for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)) and user_id = auth.uid());
create policy task_history_member_read on public.task_status_history for select using (private.is_org_member(private.task_org(task_id)));
create policy task_approvals_member_all on public.task_approvals for all using (private.is_org_member(private.task_org(task_id))) with check (private.is_org_member(private.task_org(task_id)) and reviewer_id = auth.uid());
create policy notifications_self_all on public.notifications for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy notification_preferences_self_all on public.notification_preferences for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy device_tokens_self_all on public.device_tokens for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy audit_logs_member_read on public.audit_logs for select using (private.is_org_member(organization_id));

insert into storage.buckets (id, name, public) values ('private-attachments', 'private-attachments', false) on conflict (id) do nothing;

create policy private_attachment_read on storage.objects for select to authenticated using (bucket_id = 'private-attachments' and private.is_org_member((storage.foldername(name))[1]::uuid));
create policy private_attachment_insert on storage.objects for insert to authenticated with check (bucket_id = 'private-attachments' and private.is_org_member((storage.foldername(name))[1]::uuid));
create policy private_attachment_delete on storage.objects for delete to authenticated using (bucket_id = 'private-attachments' and private.is_org_member((storage.foldername(name))[1]::uuid));

create or replace function private.touch_updated_at()
returns trigger language plpgsql security invoker set search_path = public
as $$ begin new.updated_at = now(); return new; end; $$;

create trigger profiles_touch_updated_at before update on public.profiles for each row execute function private.touch_updated_at();
create trigger organizations_touch_updated_at before update on public.organizations for each row execute function private.touch_updated_at();
create trigger projects_touch_updated_at before update on public.projects for each row execute function private.touch_updated_at();
create trigger tasks_touch_updated_at before update on public.tasks for each row execute function private.touch_updated_at();

create or replace function private.create_profile_for_user()
returns trigger language plpgsql security definer set search_path = public
as $$ begin insert into public.profiles (id, display_name) values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', '')); return new; end; $$;

create trigger on_auth_user_created after insert on auth.users for each row execute function private.create_profile_for_user();

create or replace function private.enforce_task_transition()
returns trigger language plpgsql security definer set search_path = public, private
as $$
begin
  if new.status <> old.status then
    if not (
      (old.status = 'backlog' and new.status in ('todo', 'cancelled')) or
      (old.status = 'todo' and new.status in ('in_progress', 'cancelled')) or
      (old.status = 'in_progress' and new.status in ('blocked', 'in_review', 'cancelled')) or
      (old.status = 'blocked' and new.status in ('in_progress', 'cancelled')) or
      (old.status = 'in_review' and new.status in ('in_progress', 'completed', 'cancelled')) or
      (old.status in ('completed', 'cancelled') and new.status = old.status)
    ) then
      raise exception 'invalid task status transition from % to %', old.status, new.status using errcode = '22023';
    end if;
    if new.status = 'completed' and exists (
      select 1 from public.task_dependencies d
      join public.tasks dependency on dependency.id = d.depends_on_task_id
      where d.task_id = new.id and dependency.status <> 'completed'
    ) then
      raise exception 'all task dependencies must be completed before completion' using errcode = '23514';
    end if;
    new.completed_at = case when new.status = 'completed' then coalesce(new.completed_at, now()) else null end;
  end if;
  if new.version <= old.version then
    raise exception 'task version must increase for every update' using errcode = '40001';
  end if;
  return new;
end;
$$;

create or replace function private.record_task_status_change()
returns trigger language plpgsql security definer set search_path = public, private
as $$ begin
  if new.status <> old.status then
    insert into public.task_status_history (task_id, changed_by, from_status, to_status)
    values (new.id, coalesce(auth.uid(), new.creator_id), old.status, new.status);
  end if;
  return new;
end; $$;

create trigger tasks_validate_transition before update on public.tasks for each row execute function private.enforce_task_transition();
create trigger tasks_record_status_change after update on public.tasks for each row execute function private.record_task_status_change();

create or replace function private.validate_task_assignment()
returns trigger language plpgsql security definer set search_path = public, private
as $$
begin
  if new.assignee_id is not null and not exists (
    select 1 from public.organization_members m
    where m.organization_id = new.organization_id and m.user_id = new.assignee_id and m.is_active
  ) then
    raise exception 'assignee must be an active member of the task organization' using errcode = '23514';
  end if;
  if not exists (select 1 from public.projects p where p.id = new.project_id and p.organization_id = new.organization_id) then
    raise exception 'project must belong to the task organization' using errcode = '23514';
  end if;
  return new;
end;
$$;

create trigger tasks_validate_relationships before insert or update on public.tasks for each row execute function private.validate_task_assignment();

create or replace function public.transition_task(target_task uuid, target_status public.task_status, expected_version bigint)
returns public.tasks language plpgsql security invoker set search_path = public, private
as $$
declare updated_task public.tasks;
begin
  update public.tasks
  set status = target_status, version = expected_version + 1
  where id = target_task and version = expected_version and private.is_org_member(organization_id)
  returning * into updated_task;
  if updated_task.id is null then
    raise exception 'task not found or version is stale' using errcode = '40001';
  end if;
  return updated_task;
end;
$$;

grant execute on function public.transition_task(uuid, public.task_status, bigint) to authenticated;

do $$ begin
  alter publication supabase_realtime add table public.tasks;
  alter publication supabase_realtime add table public.task_comments;
  alter publication supabase_realtime add table public.notifications;
exception when duplicate_object then null;
end $$;
