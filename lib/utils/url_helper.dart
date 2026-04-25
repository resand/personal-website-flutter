import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_logger.dart';

class UrlHelper {
  static Future<void> open(String url, {BuildContext? context}) async {
    if (url.isEmpty) return;
    final messenger = context != null && context.mounted
        ? ScaffoldMessenger.maybeOf(context)
        : null;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        AppLogger.warning('Cannot launch URL: $url');
        _notifyError(messenger, url);
      }
    } catch (e) {
      AppLogger.error('Error launching URL $url: $e');
      _notifyError(messenger, url);
    }
  }

  static void _notifyError(ScaffoldMessengerState? messenger, String url) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Could not open: $url'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
