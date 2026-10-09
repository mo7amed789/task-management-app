# Environment configuration

## Flutter

Pass only the public Supabase values at build/run time:

```powershell
flutter run --dart-define=SUPABASE_URL=https://<project>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Do not put service-role keys, database passwords, Firebase service-account JSON, or private signing material in Flutter, source control, or CI logs.

## Supabase

Configure the project through the Supabase dashboard or CLI secrets for server-side functions. Required later phases include Firebase/FCM credentials for notification Edge Functions and platform-specific Android/iOS signing configuration.
