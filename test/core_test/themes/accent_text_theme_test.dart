import 'package:bb_mobile/core/themes/app_theme.dart';
import 'package:bull_ui/bull_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (type, colors, inverse) in [
    (AppThemeType.light, BullTheme.light, BullTheme.dark),
    (AppThemeType.dark, BullTheme.dark, BullTheme.light),
  ]) {
    test('Material accent text reads the accent text colour ($type)', () {
      final theme = AppTheme.themeData(type);
      expect(
        theme.textButtonTheme.style?.foregroundColor?.resolve({}),
        colors.primaryText,
      );
      expect(
        theme.bottomNavigationBarTheme.selectedItemColor,
        colors.primaryText,
      );
      expect(theme.colorScheme.onPrimaryContainer, colors.primaryText);
      expect(theme.colorScheme.onErrorContainer, colors.errorText);
      // inverseSurface carries the other theme's background.
      expect(theme.colorScheme.inversePrimary, inverse.primaryText);
    });
  }
}
