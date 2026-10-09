# Enterprise Task Management

This repository currently contains an existing ASP.NET Core application and frontend. The new serverless implementation is isolated under `mobile/` and `supabase/` and uses Flutter plus Supabase as its target architecture. Existing applications were not deleted or rewritten.

## Phase 1

- Flutter Material 3 shell with English/Arabic locale support, theme, routing, and Supabase configuration boundary.
- Version-controlled tenant-aware PostgreSQL schema, private attachment bucket, indexes, and RLS policies.
- CI workflow for Flutter formatting, analysis, and tests.
- Architecture and environment documentation.

## Local setup

Install Flutter and the Supabase CLI, then run:

```powershell
cd mobile
flutter pub get
flutter test
flutter analyze
```

Apply the database migration through a linked Supabase project or a local Supabase instance. Use only `SUPABASE_URL` and the publishable/anon key in Flutter. Service-role keys belong exclusively in Supabase server-side configuration.

The Phase 1 scaffold is not declared production-ready: authentication workflows, Edge Functions, complete mobile features, offline synchronization, provider-backed notifications, and executed RLS/integration verification remain subsequent phases.
