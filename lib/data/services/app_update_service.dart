import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppUpdateType { none, optional, required }

class AppUpdateConfig {
  AppUpdateConfig({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.optionalUpdateEnabled,
    required this.title,
    required this.message,
    required this.androidDownloadUrl,
    required this.iosDownloadUrl,
  });

  final String latestVersion;
  final String minSupportedVersion;
  final bool optionalUpdateEnabled;
  final String title;
  final String message;
  final String? androidDownloadUrl;
  final String? iosDownloadUrl;

  String? get downloadUrl {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return androidDownloadUrl;
    if (Platform.isIOS) return iosDownloadUrl;
    return null;
  }

  factory AppUpdateConfig.fromMap(Map<String, dynamic> map) {
    return AppUpdateConfig(
      latestVersion: (map['latest_version'] ?? '').toString().trim(),
      minSupportedVersion: (map['min_supported_version'] ?? '0.0.0')
          .toString()
          .trim(),
      optionalUpdateEnabled: map['optional_update_enabled'] == true,
      title: (map['title'] ?? 'Update available').toString(),
      message:
          (map['message'] ??
                  'A newer version of the app is available. Please update now.')
              .toString(),
      androidDownloadUrl: map['android_download_url']?.toString(),
      iosDownloadUrl: map['ios_download_url']?.toString(),
    );
  }
}

class AppUpdateDecision {
  const AppUpdateDecision._(this.type, this.config);

  final AppUpdateType type;
  final AppUpdateConfig? config;

  bool get hasUpdate => type != AppUpdateType.none && config != null;

  factory AppUpdateDecision.none() =>
      const AppUpdateDecision._(AppUpdateType.none, null);

  factory AppUpdateDecision.optional(AppUpdateConfig config) =>
      AppUpdateDecision._(AppUpdateType.optional, config);

  factory AppUpdateDecision.required(AppUpdateConfig config) =>
      AppUpdateDecision._(AppUpdateType.required, config);
}

class AppUpdateService {
  static const String _tableName = 'app_update_config';
  static const int _configId = 1;

  final SupabaseClient _client = Supabase.instance.client;

  Future<AppUpdateDecision> checkForUpdate() async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('id', _configId)
          .maybeSingle();

      if (data == null) return AppUpdateDecision.none();

      final config = AppUpdateConfig.fromMap(Map<String, dynamic>.from(data));
      if (config.latestVersion.isEmpty) return AppUpdateDecision.none();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version.trim();

      if (_compareVersions(currentVersion, config.latestVersion) >= 0) {
        return AppUpdateDecision.none();
      }

      if (_compareVersions(currentVersion, config.minSupportedVersion) < 0) {
        return AppUpdateDecision.required(config);
      }

      if (config.optionalUpdateEnabled) {
        return AppUpdateDecision.optional(config);
      }

      return AppUpdateDecision.none();
    } catch (e, st) {
      debugPrint('App update check failed: $e');
      debugPrint(st.toString());
      return AppUpdateDecision.none();
    }
  }

  int _compareVersions(String current, String target) {
    final currentParts = _normalizeVersionParts(current);
    final targetParts = _normalizeVersionParts(target);
    final maxLen = currentParts.length > targetParts.length
        ? currentParts.length
        : targetParts.length;

    for (var i = 0; i < maxLen; i++) {
      final currentValue = i < currentParts.length ? currentParts[i] : 0;
      final targetValue = i < targetParts.length ? targetParts[i] : 0;
      if (currentValue != targetValue) {
        return currentValue.compareTo(targetValue);
      }
    }
    return 0;
  }

  List<int> _normalizeVersionParts(String version) {
    final core = version.split('+').first;
    final rawParts = core.split('.');

    return rawParts.map((part) {
      final cleaned = part.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(cleaned) ?? 0;
    }).toList();
  }
}
