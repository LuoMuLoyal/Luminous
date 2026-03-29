import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

List<_LegalSection> _buildUserAgreementSections(AppLocalizations? l10n) {
  return [
    _LegalSection(
      title: l10n?.legalUserAgreementSection1Title ?? '1. 协议适用范围',
      body:
          l10n?.legalUserAgreementSection1Body ??
          '本协议适用于你使用 Luminous 健康助手应用所提供的健康记录、药品查询、AI 辅助分析、提醒管理等功能。你在注册、登录或继续使用应用时，视为已阅读并同意本协议内容。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection2Title ?? '2. 服务说明',
      body:
          l10n?.legalUserAgreementSection2Body ??
          '本应用提供的是健康信息整理与辅助参考服务，不构成诊断、处方或医疗建议。涉及用药、过敏、孕期、慢病管理等高风险事项时，请务必以医生、药师或正规说明书意见为准。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection3Title ?? '3. 账号与安全',
      body:
          l10n?.legalUserAgreementSection3Body ??
          '你应妥善保管自己的登录信息，不得借用、出租或转让账号。因你主动泄露账号信息、在不安全设备登录、或未及时退出所导致的风险，由你自行承担。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection4Title ?? '4. 使用规范',
      body:
          l10n?.legalUserAgreementSection4Body ??
          '你不得利用本应用从事违法违规行为，包括但不限于伪造身份、上传恶意内容、批量抓取接口、干扰服务稳定性、传播虚假医疗信息等。若存在异常使用行为，平台有权限制相关功能。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection5Title ?? '5. AI 内容说明',
      body:
          l10n?.legalUserAgreementSection5Body ??
          '应用中的 AI 解读、识别结果、安全辅助等内容，会受到模型能力、输入图片质量、药品信息完整度等因素影响，可能出现偏差、遗漏或不适用情形。你应结合药品说明书和专业意见独立判断。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection6Title ?? '6. 免责声明',
      body:
          l10n?.legalUserAgreementSection6Body ??
          '对于因网络中断、第三方服务异常、用户输入错误、设备兼容性问题或不可抗力导致的服务中断、结果偏差或数据延迟，我们会尽力修复，但不对由此产生的直接或间接损失承担医疗责任。',
    ),
    _LegalSection(
      title: l10n?.legalUserAgreementSection7Title ?? '7. 协议更新',
      body:
          l10n?.legalUserAgreementSection7Body ??
          '随着功能迭代，协议内容可能调整。更新后的协议会在应用内展示；你继续使用应用即视为接受更新后的协议。如你不同意更新内容，应停止使用相关服务。',
    ),
  ];
}

List<_LegalSection> _buildPrivacyPolicySections(AppLocalizations? l10n) {
  return [
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection1Title ?? '1. 我们收集的信息',
      body:
          l10n?.legalPrivacyPolicySection1Body ??
          '在你使用注册登录、药品识别、提醒计划、健康记录等功能时，我们可能收集你主动填写的手机号、邮箱、昵称、药品名称、提醒计划、扫描图片及必要的设备基础信息。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection2Title ?? '2. 信息用途',
      body:
          l10n?.legalPrivacyPolicySection2Body ??
          '这些信息主要用于完成账号识别、同步你的个人数据、提供药品搜索与 AI 分析、生成提醒计划、排查服务异常，以及优化产品体验。我们不会将你的个人健康数据用于与你无关的营销用途。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection3Title ?? '3. 图片与 AI 请求',
      body:
          l10n?.legalPrivacyPolicySection3Body ??
          '当你主动使用扫描识别、AI 药品解读或安全辅助时，相关图片、文本和结构化参数会被发送到后端与模型服务完成处理。我们建议你避免上传包含身份证、银行卡、住址等无关敏感信息的图片。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection4Title ?? '4. 本地存储',
      body:
          l10n?.legalPrivacyPolicySection4Body ??
          '为了减少重复登录和提升体验，应用会在本地安全地缓存部分必要信息，例如登录态、用户资料摘要、部分业务记录和主题偏好。你退出登录后，登录态相关信息会被清除。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection5Title ?? '5. 信息共享',
      body:
          l10n?.legalPrivacyPolicySection5Body ??
          '除法律法规要求、为完成你主动发起的服务请求，或保障系统安全所必需的情况外，我们不会向无关第三方出售或公开你的个人信息。若涉及第三方云服务，仅在提供功能所需的最小范围内处理。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection6Title ?? '6. 你的权利',
      body:
          l10n?.legalPrivacyPolicySection6Body ??
          '你可以通过应用内登录、退出、修改资料、删除本地数据等方式管理自己的信息。若后续接入更完整的数据管理能力，也会逐步支持导出、删除和更细粒度的授权控制。',
    ),
    _LegalSection(
      title: l10n?.legalPrivacyPolicySection7Title ?? '7. 联系与更新',
      body:
          l10n?.legalPrivacyPolicySection7Body ??
          '如果后续隐私政策发生实质更新，我们会在应用内提供新版本说明。你继续使用相关功能，即表示你已知悉并接受更新后的内容。',
    ),
  ];
}

/// 用户协议页面。
class UserAgreementPage extends StatelessWidget {
  const UserAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalDocumentPage(
      title: l10n?.legalUserAgreementTitle ?? '用户协议',
      summary:
          l10n?.legalUserAgreementSummary ??
          '请在使用 Luminous 健康助手前，先了解账号、服务边界和使用规范。',
      sections: _buildUserAgreementSections(l10n),
    );
  }
}

/// 隐私政策页面。
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _LegalDocumentPage(
      title: l10n?.legalPrivacyPolicyTitle ?? '隐私政策',
      summary:
          l10n?.legalPrivacyPolicySummary ?? '这里说明应用会收集哪些信息、如何使用，以及你后续可以如何管理。',
      sections: _buildPrivacyPolicySections(l10n),
    );
  }
}

class _LegalDocumentPage extends StatelessWidget {
  const _LegalDocumentPage({
    required this.title,
    required this.summary,
    required this.sections,
  });

  final String title;
  final String summary;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162033) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              summary,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF334155),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162033) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      section.body,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
