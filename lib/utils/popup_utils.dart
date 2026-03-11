import 'package:flutter/material.dart';

enum PopupMode {
  info,
  success,
  warning,
  error,
  confirm,
  bottomSheet,
}

class PopupUtils {
  const PopupUtils._();

  static Future<bool?> showByMode(
    BuildContext context, {
    required String text,
    required PopupMode mode,
    String? title,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    if (mode == PopupMode.bottomSheet) {
      return _showBottomSheet(
        context,
        title: title ?? _defaultTitle(mode),
        text: text,
        confirmText: confirmText,
      );
    }

    return _showDialog(
      context,
      mode: mode,
      title: title ?? _defaultTitle(mode),
      text: text,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  static Future<bool?> _showDialog(
    BuildContext context, {
    required PopupMode mode,
    required String title,
    required String text,
    required String confirmText,
    required String cancelText,
  }) {
    final PopupVisual visual = _resolveVisual(mode);
    final bool needCancel = mode == PopupMode.confirm;

    return showDialog<bool>(
      context: context,
      barrierDismissible: !needCancel,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(visual.icon, color: visual.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF334155),
              height: 1.5,
            ),
          ),
          actions: [
            if (needCancel)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(cancelText),
              ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: visual.color,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> _showBottomSheet(
    BuildContext context, {
    required String title,
    required String text,
    required String confirmText,
  }) {
    final PopupVisual visual = _resolveVisual(PopupMode.info);
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: visual.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(visual.icon, color: visual.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF475569),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(confirmText),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static PopupVisual _resolveVisual(PopupMode mode) {
    switch (mode) {
      case PopupMode.success:
        return const PopupVisual(
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xFF16A34A),
        );
      case PopupMode.warning:
        return const PopupVisual(
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFF59E0B),
        );
      case PopupMode.error:
        return const PopupVisual(
          icon: Icons.error_outline_rounded,
          color: Color(0xFFDC2626),
        );
      case PopupMode.confirm:
        return const PopupVisual(
          icon: Icons.help_outline_rounded,
          color: Color(0xFF0EA5E9),
        );
      case PopupMode.bottomSheet:
      case PopupMode.info:
        return const PopupVisual(
          icon: Icons.info_outline_rounded,
          color: Color(0xFF0EA5E9),
        );
    }
  }

  static String _defaultTitle(PopupMode mode) {
    switch (mode) {
      case PopupMode.success:
        return '操作成功';
      case PopupMode.warning:
        return '温馨提示';
      case PopupMode.error:
        return '操作失败';
      case PopupMode.confirm:
        return '请确认';
      case PopupMode.bottomSheet:
      case PopupMode.info:
        return '提示';
    }
  }
}

class PopupVisual {
  final IconData icon;
  final Color color;

  const PopupVisual({required this.icon, required this.color});
}
