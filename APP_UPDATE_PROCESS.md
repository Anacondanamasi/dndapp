# App Update Process (GitHub Releases + Supabase)

This project is configured to use this APK URL for in-app updates:

`https://github.com/Anacondanamasi/dndapp/releases/latest/download/dndapp-latest.apk`

## 1) Build a new APK

1. Update version in `pubspec.yaml`, example:
   - from `1.0.0+1` to `1.0.1+2`
2. Build release APK:

```bash
flutter build apk --release
```

Output path:
`build/app/outputs/flutter-apk/app-release.apk`

## 2) Upload APK to GitHub Release

1. Open: `https://github.com/Anacondanamasi/dndapp/releases`
2. Create new release (or edit latest).
3. Upload APK file.
4. Rename uploaded asset to exactly: `dndapp-latest.apk`
   - Keep this filename stable for every release.

## 3) Trigger update popup from backend (Supabase)

Run SQL from:

- `supabase/app_update_release_commands.sql`

Optional update:
- `latest_version` > installed version
- `min_supported_version` remains lower

Force update:
- set `min_supported_version = latest_version`

## 4) How users receive update

The app checks `public.app_update_config`:
- on app start
- on app resume
- every 5 minutes

If update is available, users get popup with `Update now`.

## 5) Critical rules

1. Keep the same Android package name.
2. Sign every new APK with the same keystore.
3. Always increase version each release.

