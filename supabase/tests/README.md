# Supabase verification plan

These tests should run against a disposable local Supabase instance before a migration is promoted:

- an authenticated user in organization A cannot select, insert, update, or delete organization B resources;
- an inactive member loses access immediately;
- project and task foreign keys cannot cross organization boundaries;
- private attachment paths require membership in the first path segment organization UUID;
- task status transitions, dependency completion, review rejection feedback, and optimistic version checks are transactional;
- notification rows and device tokens are visible only to their owner.

The repository currently has no Supabase CLI installed on this machine, so execution is intentionally pending rather than reported as passing.
