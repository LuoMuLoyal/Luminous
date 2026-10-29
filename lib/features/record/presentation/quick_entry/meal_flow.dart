import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/utils/image_compressor.dart';
import 'package:luminous/features/record/domain/services/meal_quick_entry.dart';
import 'package:luminous/features/record/presentation/pages/create.dart';

/// Presentation adapter for the meal camera picker.
///
/// The flow itself (draft → confirmation → write) is the application-layer
/// [MealQuickEntryFlow]; this file only supplies the platform edge (camera /
/// gallery + compression) through a provider the flow can be built from.
final mealQuickImagePickerProvider = Provider<PickMealQuickImage>((ref) {
  final picker = ImagePicker();
  return (source) async {
    final image = await picker.pickImage(
      source: switch (source) {
        MealQuickImageSource.camera => ImageSource.camera,
        MealQuickImageSource.gallery => ImageSource.gallery,
      },
      requestFullMetadata: false,
    );
    if (image == null) return null;

    final contentType = RecordCreatePage.resolveImageContentType(image);
    if (contentType == null) {
      throw const MealQuickImageUnsupportedException();
    }

    final rawBytes = await image.readAsBytes();
    final compressedBytes = await ImageCompressor.compressForUpload(rawBytes);
    return MealQuickImage(
      bytes: compressedBytes,
      fileName: image.name,
      contentType: 'image/jpeg',
    );
  };
});
