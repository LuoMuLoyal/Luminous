import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/features/customizer/domain/entities/draft.dart';
import 'package:luminous/features/customizer/domain/repositories/layout.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 进入编排：读取现有布局 → 生成草稿。
///
/// 读不到（新账号/后端不可用）时回退到各 surface 的 defaultLayout 并进入
/// **可编辑的降级态**，而不是拦住用户：编排本身不依赖网络，只有保存才依赖。
class StartDraft {
  const StartDraft(this._repository);

  final LayoutRepository _repository;

  Future<LayoutDraft> call(SurfaceCatalog catalog) async {
    final result = await _repository.readAll().run();
    return result.match(
      (_) => _fromDefaults(catalog),
      (layouts) => _fromLayouts(catalog, layouts),
    );
  }

  LayoutDraft _fromDefaults(SurfaceCatalog catalog) {
    return LayoutDraft(
      surfaces: {
        for (final definition in catalog.definitions)
          definition.surface: definition.defaultLayout,
      },
    );
  }

  LayoutDraft _fromLayouts(
    SurfaceCatalog catalog,
    Map<SurfaceId, SurfaceLayout> layouts,
  ) {
    return LayoutDraft(
      surfaces: {
        for (final definition in catalog.definitions)
          definition.surface:
              layouts[definition.surface] ?? definition.defaultLayout,
      },
    );
  }
}

/// 提交草稿：逐 surface 落盘。
///
/// 单个 surface 失败不中断其余——用户可能改了三个 tab，其中一个保存失败时
/// 另外两个应该已经存下，避免"全有或全无"导致白改。
TaskEither<LucentFailure, List<SurfaceId>> commitDraft(
  LayoutRepository repository,
  LayoutDraft draft,
) {
  return TaskEither<LucentFailure, List<SurfaceId>>(() async {
    final saved = <SurfaceId>[];
    LucentFailure? firstFailure;

    for (final entry in draft.surfaces.entries) {
      final result = await repository.write(entry.key, entry.value).run();
      result.match((failure) {
        firstFailure ??= failure;
      }, (_) {
        saved.add(entry.key);
      });
    }

    // 一个都没存成功才算失败；部分成功时调用方仍应看到"已保存 X 个"。
    if (saved.isEmpty) {
      return Left(
        firstFailure ??
            const LucentFailure(
              kind: LucentFailureKind.unknown,
              message: 'layout save failed on every surface',
            ),
      );
    }
    return Right(saved);
  });
}
