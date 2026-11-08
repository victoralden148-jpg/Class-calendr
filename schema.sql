-- Kelasku: jalankan seluruh file ini di Supabase > SQL Editor > Run
create table classes(id uuid primary key default gen_random_uuid(), name text not null, code text unique not null, created_by uuid default auth.uid(), created_at timestamptz default now());
create table members(class_id uuid references classes on delete cascade, user_id uuid default auth.uid(), name text not null, role text not null default 'member' check (role in ('admin','member')), primary key(class_id,user_id));
create table events(id uuid primary key default gen_random_uuid(), class_id uuid not null references classes on delete cascade, title text not null, category text default 'Kelas', starts_at timestamptz not null, location text default '', description text default '', created_by uuid default auth.uid(), created_at timestamptz default now());
create table attendance(event_id uuid references events on delete cascade, user_id uuid, class_id uuid not null references classes on delete cascade, at timestamptz default now(), primary key(event_id,user_id));
create table media(id uuid primary key default gen_random_uuid(), event_id uuid references events on delete cascade, class_id uuid not null references classes on delete cascade, user_id uuid default auth.uid(), path text not null, kind text default 'image', created_at timestamptz default now());

create function is_member(cid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from members where class_id=cid and user_id=auth.uid()) $$;
create function is_admin(cid uuid) returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from members where class_id=cid and user_id=auth.uid() and role='admin') $$;

create function create_class(p_class text, p_name text) returns classes language plpgsql security definer set search_path=public as $$
declare c classes; begin
 if auth.uid() is null then raise exception 'Belum login'; end if;
 insert into classes(name,code) values (p_class, upper(substr(md5(random()::text||clock_timestamp()::text),1,6))) returning * into c;
 insert into members(class_id,user_id,name,role) values (c.id,auth.uid(),p_name,'admin'); return c; end $$;
create function join_class(p_code text, p_name text) returns classes language plpgsql security definer set search_path=public as $$
declare c classes; begin
 if auth.uid() is null then raise exception 'Belum login'; end if;
 select * into c from classes where code=upper(trim(p_code));
 if c.id is null then raise exception 'Kode kelas tidak ditemukan'; end if;
 insert into members(class_id,user_id,name,role) values (c.id,auth.uid(),p_name,'member') on conflict do nothing; return c; end $$;

alter table classes enable row level security; alter table members enable row level security; alter table events enable row level security; alter table attendance enable row level security; alter table media enable row level security;
create policy c_sel on classes for select using (is_member(id));
create policy c_upd on classes for update using (is_admin(id));
create policy m_sel on members for select using (is_member(class_id));
create policy m_upd on members for update using (is_admin(class_id));
create policy m_del on members for delete using (user_id=auth.uid() or is_admin(class_id));
create policy e_sel on events for select using (is_member(class_id));
create policy e_ins on events for insert with check (is_admin(class_id));
create policy e_upd on events for update using (is_admin(class_id));
create policy e_del on events for delete using (is_admin(class_id));
create policy a_sel on attendance for select using (is_member(class_id));
create policy a_ins on attendance for insert with check (is_admin(class_id));
create policy a_upd on attendance for update using (is_admin(class_id));
create policy a_del on attendance for delete using (is_admin(class_id));
create policy g_sel on media for select using (is_member(class_id));
create policy g_ins on media for insert with check (is_member(class_id) and user_id=auth.uid());
create policy g_del on media for delete using (user_id=auth.uid() or is_admin(class_id));

insert into storage.buckets(id,name,public) values ('media','media',true) on conflict do nothing;
create policy "media upload" on storage.objects for insert to authenticated with check (bucket_id='media');
create policy "media delete" on storage.objects for delete to authenticated using (bucket_id='media' and owner=auth.uid());

alter publication supabase_realtime add table events, attendance, media, members;
