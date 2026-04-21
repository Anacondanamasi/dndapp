-- Repo mapped for APK hosting:
-- https://github.com/Anacondanamasi/dndapp
--
-- IMPORTANT:
-- 1) In each GitHub Release, upload APK with exact file name: dndapp-latest.apk
-- 2) Keep app package and signing key same between builds.
-- 3) Increase Flutter version in pubspec.yaml before building each release.

-- Optional update (user can tap "Later")
update public.app_update_config
set latest_version = '1.0.1',
    min_supported_version = '1.0.0',
    optional_update_enabled = true,
    android_download_url = 'https://github.com/Anacondanamasi/dndapp/releases/latest/download/dndapp-latest.apk',
    title = 'Update available',
    message = 'A new version is available with improvements. Please update for the best experience.'
where id = 1;

-- Force update (old app cannot continue)
-- update public.app_update_config
-- set latest_version = '1.0.1',
--     min_supported_version = '1.0.1',
--     optional_update_enabled = true,
--     android_download_url = 'https://github.com/Anacondanamasi/dndapp/releases/latest/download/dndapp-latest.apk',
--     title = 'Update required',
--     message = 'Please update to continue using the app.'
-- where id = 1;
