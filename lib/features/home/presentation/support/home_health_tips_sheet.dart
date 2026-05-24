part of '../home.dart';

Future<String?> showHomeHealthTipsSheet({
  required BuildContext context,
  required AppLocalizations? l10n,
  required List<String> tips,
  required String currentTip,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.homeTipsSheetTitle ?? '全部健康小贴士',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.homeTipsSheetSubtitle ?? '点击任意一条即可替换首页提示语',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                itemCount: tips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  final isCurrent = tip == currentTip;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => Navigator.of(context).pop(tip),
                      child: Ink(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFEAF6FF)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFFBFDBFE)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFFDBEAFE)
                                    : const Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCurrent
                                    ? Icons.favorite_rounded
                                    : Icons.lightbulb_outline_rounded,
                                size: 14,
                                color: isCurrent
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
