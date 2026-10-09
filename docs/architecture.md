# Enterprise Task Management architecture

The mobile client is a thin Flutter client. Supabase Auth owns sessions and token refresh. PostgreSQL owns tenant isolation, permissions, constraints, task transitions, and reporting. Realtime is used only as an invalidation/synchronization signal; every resulting read still passes through authenticated Supabase access and RLS.

## Security boundary

The Flutter app receives only the Supabase publishable/anon key. It never receives a service-role key. Every sensitive table has RLS enabled. Policies use `auth.uid()` and non-recursive security-definer helper functions in the `private` schema. Organization and project relationships are checked in the database, not trusted from client-provided IDs.

## Phase 1 scope

This first increment establishes the Flutter shell, environment-variable boundary, Supabase configuration, and the version-controlled relational foundation. Authentication screens, complete feature modules, Edge Functions, and device integrations follow the migration and policy verification work.
