import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const admin = createClient(supabaseUrl, serviceRoleKey, { auth: { persistSession: false } });

Deno.serve(async (request) => {
  if (request.method !== 'POST') return new Response('Method not allowed', { status: 405 });
  const authorization = request.headers.get('Authorization');
  if (!authorization) return new Response('Unauthorized', { status: 401 });
  const caller = createClient(supabaseUrl, Deno.env.get('SUPABASE_ANON_KEY')!, { global: { headers: { Authorization: authorization } } });
  const { data: { user } } = await caller.auth.getUser();
  if (!user) return new Response('Unauthorized', { status: 401 });

  const body = await request.json() as { organization_id?: string; email?: string; role?: string };
  const email = body.email?.trim().toLowerCase();
  if (!body.organization_id || !email || !email.includes('@')) return new Response('Invalid invitation request', { status: 400 });

  const { data: membership } = await admin.from('organization_members').select('role,is_active').eq('organization_id', body.organization_id).eq('user_id', user.id).maybeSingle();
  if (!membership?.is_active || !['platform_admin', 'organization_admin'].includes(membership.role)) return new Response('Forbidden', { status: 403 });

  const role = body.role ?? 'employee';
  if (!['organization_admin', 'project_manager', 'team_leader', 'employee'].includes(role)) return new Response('Invalid role', { status: 400 });
  const { data: invited, error: inviteError } = await admin.auth.admin.inviteUserByEmail(email);
  if (inviteError) return new Response(JSON.stringify({ error: inviteError.message }), { status: 400 });
  const { error } = await admin.from('invitations').upsert({ organization_id: body.organization_id, email, role, invited_by: user.id }, { onConflict: 'organization_id,email' });
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  return new Response(JSON.stringify({ invited_user_id: invited.user.id }), { headers: { 'content-type': 'application/json' } });
});
