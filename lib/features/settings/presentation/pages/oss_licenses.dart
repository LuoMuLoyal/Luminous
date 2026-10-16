import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/router/external_url_launcher.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/settings/presentation/routes.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/oss_licenses.dart';

/// Open-source license list for the app's **pub** dependencies.
///
/// Complements the built-in `showLicensePage` rather than replacing it: the
/// built-in page renders Flutter's `NOTICES` registry, which is keyed by
/// component license and carries no pubspec metadata. This list is generated
/// from `pubspec.lock`, so each entry has the resolved version and a copyable
/// license text. Data comes from `lib/oss_licenses.dart`.
class OssLicensesPage extends StatelessWidget {
  const OssLicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // 排序只做一次：ListView.builder 每帧都会重建条目，排序放 build 里会重复。
    final packages = _sortedPackages;

    return PageScaffold(
      title: l10n.settingsAboutOssLicensesTitle,
      child: ResponsiveContentFrame(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
          itemCount: packages.length,
          itemBuilder: (context, index) {
            final package = packages[index];
            return FTile(
              title: Text(package.name),
              subtitle: Text(
                package.version ?? '',
                style: context.theme.typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              suffix: const Icon(SemanticIcons.actionNext),
              onPress: () => SettingsOssLicenseDetailRoute(
                name: package.name,
              ).push(context),
            );
          },
        ),
      ),
    );
  }
}

/// `allDependencies` is a compile-time constant list from the generator; sort it
/// once at library load instead of on every rebuild.
final List<Package> _sortedPackages = [...allDependencies]
  ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

/// Single-package license text with a copy action.
class OssLicenseDetailPage extends StatelessWidget {
  const OssLicenseDetailPage({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final package = _packageByName(name);
    final license = package?.license?.trim();
    final homepage = package?.homepage ?? package?.repository;

    return PageScaffold(
      title: name,
      actions: [
        FButton(
          variant: FButtonVariant.ghost,
          onPress: license == null || license.isEmpty
              ? null
              : () => _copy(
                  context,
                  license,
                  l10n.settingsAboutLicenseCopiedToast,
                ),
          prefix: const Icon(SemanticIcons.actionCopy),
          child: Text(l10n.commonCopy),
        ),
      ],
      child: ResponsiveContentFrame(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (package?.version != null)
                _DetailRow(
                  label: l10n.settingsAboutLicenseVersionLabel,
                  value: package!.version!,
                ),
              if (homepage != null && homepage.isNotEmpty) ...[
                const SizedBox(height: Spacing.md),
                _DetailRow(
                  label: l10n.settingsAboutLicenseHomepageLabel,
                  value: homepage,
                  onTap: () => _openHomepage(homepage),
                ),
              ],
              const SizedBox(height: Spacing.xl),
              SelectableText(
                license == null || license.isEmpty
                    ? l10n.settingsAboutLicenseMissing
                    : license,
                style: context.theme.typography.body.xs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(
    BuildContext context,
    String license,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: license));
    if (!context.mounted) return;
    await Toast.show(context, message);
  }

  Future<void> _openHomepage(String homepage) async {
    final uri = Uri.tryParse(homepage);
    if (uri != null) {
      await const ExternalUrlLauncher().open(uri);
    }
  }
}

/// 按名字查回 `allDependencies` 里的条目。
///
/// 详情页只从路由拿到 `name`（路由参数必须是可序列化的原始值，不能传
/// `Package` 对象），所以这里查一次表。包名在 `pubspec.lock` 内唯一。
Package? _packageByName(String name) {
  for (final package in allDependencies) {
    if (package.name == name) return package;
  }
  return null;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(width: Spacing.md),
        // 值是可变长的 URL / 版本号：必须 Flexible，否则长 URL 会把行右溢出。
        Flexible(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              value,
              style: typography.body.xs.copyWith(
                color: onTap == null
                    ? null
                    : SemanticColor.primary.solid(context),
                decoration: onTap == null ? null : TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
