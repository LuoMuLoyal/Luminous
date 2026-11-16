/// 风险预检仓储的对外出口。
///
/// `search` 的「加入药箱」闭环要先做一次风险预检，但它不是 `data/` 的消费者；
/// 装配留在本目录，`search` 只引用这一个符号，不直接 import 别的 feature 的
/// `data/`。
library;

export 'package:luminous/features/medicine/data/repositories/risk_check.dart'
    show medicineRiskCheckRepositoryProvider;
