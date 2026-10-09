# Notifications deployment

The mobile client registers FCM device tokens in the RLS-protected `device_tokens` table and displays foreground messages through local notifications. Call `PushNotificationService.initialize()` only after Firebase platform configuration has been added to the Android/iOS projects.

The server-side notification function must use Firebase Admin credentials stored as Supabase Edge Function secrets. It should claim notification rows idempotently, record delivery attempts, retry transient failures, and never accept a service credential from the mobile client.
