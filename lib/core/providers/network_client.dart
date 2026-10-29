/// 网络客户端接缝。
///
/// presentation 层不应直接依赖 `lib/core/network/client/`（Dio 构造、拦截器、
/// 重试策略等 I/O 细节）。组合根（各 feature 的 `presentation/providers/`）
/// 需要拿到已配置的 Dio / 生成 API 客户端时，从这里取。
library;

export 'package:luminous/core/network/client/client_providers.dart'
    show
        lastTraceIdProvider,
        lucentBaseUrlProvider,
        lucentClientProvider,
        lucentDioClientProvider;
export 'package:luminous/core/network/client/dio_client.dart'
    show LucentDioClient;
export 'package:luminous/core/network/contract/error_code.dart';
export 'package:luminous/core/network/contract/error_mapper.dart';
export 'package:luminous/core/network/contract/problem_details.dart';
