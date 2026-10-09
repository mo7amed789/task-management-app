# Android release APK

The local workspace cannot build an APK until Flutter and the Android toolchain are installed. The repository includes a manual GitHub Actions workflow at `.github/workflows/android-release.yml`.

Run it from the repository's Actions tab using **Run workflow**, supplying the public Supabase URL and publishable/anon key. The workflow:

1. Generates the missing Android project with `flutter create`.
2. Resolves packages and generates Drift code.
3. Runs analysis and tests.
4. Builds `app-release.apk`.
5. Uploads the APK as a workflow artifact.

The current workflow produces an unsigned release APK suitable for internal testing. For Play Store distribution, add encrypted keystore secrets and configure `key.properties`/Gradle signing in a protected release workflow. Never commit the keystore or passwords.
