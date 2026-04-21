import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jewello/data/services/app_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateGuard extends StatefulWidget {
  const UpdateGuard({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateGuard> createState() => _UpdateGuardState();
}

class _UpdateGuardState extends State<UpdateGuard> with WidgetsBindingObserver {
  static const Duration _checkInterval = Duration(minutes: 5);
  static const String _skippedVersionKey = 'skipped_optional_update_version';

  final AppUpdateService _updateService = AppUpdateService();
  final GetStorage _storage = GetStorage();

  Timer? _timer;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runUpdateCheck();
    _timer = Timer.periodic(_checkInterval, (_) => _runUpdateCheck());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runUpdateCheck();
    }
  }

  Future<void> _runUpdateCheck() async {
    if (!mounted || _dialogOpen) return;

    final decision = await _updateService.checkForUpdate();
    if (!mounted || !decision.hasUpdate || decision.config == null) return;

    final config = decision.config!;
    final skippedVersion = _storage.read<String>(_skippedVersionKey);
    final shouldSkip =
        decision.type == AppUpdateType.optional &&
        skippedVersion == config.latestVersion;

    if (shouldSkip) return;

    await _showUpdateDialog(decision.type, config);
  }

  Future<void> _showUpdateDialog(
    AppUpdateType type,
    AppUpdateConfig config,
  ) async {
    _dialogOpen = true;
    final isRequired = type == AppUpdateType.required;

    await showDialog<void>(
      context: context,
      barrierDismissible: !isRequired,
      builder: (context) {
        return PopScope(
          canPop: !isRequired,
          child: AlertDialog(
            title: Text(config.title),
            content: Text(config.message),
            actions: [
              if (!isRequired)
                TextButton(
                  onPressed: () {
                    _storage.write(_skippedVersionKey, config.latestVersion);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Later'),
                ),
              FilledButton(
                onPressed: () async {
                  final launched = await _openUpdateLink(config);
                  if (!context.mounted) return;
                  if (launched && !isRequired) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Update now'),
              ),
            ],
          ),
        );
      },
    );

    _dialogOpen = false;
  }

  Future<bool> _openUpdateLink(AppUpdateConfig config) async {
    final url = config.downloadUrl;
    if (url == null || url.trim().isEmpty) {
      _showSnackBar('Update link is not configured for this platform.');
      return false;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      _showSnackBar('Invalid update link. Please contact support.');
      return false;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showSnackBar('Could not open update link. Please try again.');
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
