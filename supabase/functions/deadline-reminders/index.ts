import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const url = Deno.env.get('SUPABASE_URL')!;
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const admin = createClient(url, serviceRoleKey, { auth: { persistSession: false } });

// Invoke from Supabase Cron. The service-role key is intentionally read only in
// the Edge Function runtime and is never shipped to the Flutter client.
Deno.serve(async () => {
  const now = new Date();
  const horizon = new Date(now.getTime() + 24 * 60 * 60 * 1000);
  const { data: tasks, error } = await admin
    .from('tasks')
    .select('id,organization_id,title,deadline,assignee_id')
    .not('assignee_id', 'is', null)
    .gte('deadline', now.toISOString())
    .lte('deadline', horizon.toISOString())
    .not('status', 'in', '(completed,cancelled)');
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });

  for (const task of tasks ?? []) {
    await admin.from('notifications').upsert({
      user_id: task.assignee_id,
      organization_id: task.organization_id,
      kind: 'deadline_reminder',
      title: 'Task deadline approaching',
      body: task.title,
      data: { task_id: task.id, deadline: task.deadline },
      dedupe_key: `deadline:${task.id}:${task.deadline}`,
    }, { onConflict: 'dedupe_key' });
  }
  return new Response(JSON.stringify({ processed: tasks?.length ?? 0 }), { headers: { 'content-type': 'application/json' } });
});
