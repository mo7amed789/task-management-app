# Production review checklist

Implemented in the current increment:

- Supabase Auth sign-in and registration boundary.
- Organization, project, task, comments, notifications, profile, and attachment client repositories.
- RLS-protected private storage paths.
- Optimistic task versions and database-enforced status transitions.
- Realtime publication for tasks, comments, and notifications.
- Server-side deadline reminder function with deduplication.

Still required before a production claim:

1. Install Flutter, Supabase CLI, and Deno; run `flutter pub get`, formatting, analysis, widget/integration tests, local Supabase migrations, and RLS isolation tests.
2. Run Drift code generation and complete task/project cache invalidation, queued writes, conflict records, and logout cache invalidation. The server remains authoritative.
3. Configure Firebase Cloud Messaging and local notifications on Android/iOS, then implement signed server-side delivery retries. The client service boundary is now present.
4. Add Edge Function invitation/admin workflows and verify all role-specific screens against RLS, not client role checks.
5. Add attachment MIME/size validation at the Edge Function or storage boundary and malware scanning appropriate to the deployment.
6. Configure Supabase Cron, backups, retention, Android signing, iOS capabilities, and CI secrets in the deployment environment.
