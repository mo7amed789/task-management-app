# Edge Functions

`deadline-reminders` is intended to run from Supabase Cron at a short interval. Configure `SUPABASE_SERVICE_ROLE_KEY` only as a server-side function secret. The Flutter app must never receive it.

`invite-member` validates the caller using the request's Supabase session, rechecks organization-admin membership server-side, then uses the service role only to send the Auth invitation and persist the invitation record.

Before production deployment, add a uniqueness constraint for notification idempotency (for example, a generated reminder key) and configure FCM delivery/retry handling in the function. The current function persists notification records first; provider delivery is a subsequent server-side concern.
