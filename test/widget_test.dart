import 'package:flutter_test/flutter_test.dart';
import 'package:medscan/core/theme/app_colors.dart';

void main() {
  test('AppColors matches template blue and slate palette', () {
    expect(AppColors.primary.toARGB32(), 0xFF1B5FE0);
    expect(AppColors.background.toARGB32(), 0xFFF7F9FC);
    expect(AppColors.surface.toARGB32(), 0xFFFFFFFF);
  });
}

