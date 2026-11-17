import 'package:bb_mobile/core/themes/app_theme.dart';
import 'package:bull_ui/bull_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each app theme registers the keypad of its brightness', () {
    expect(
      AppTheme.themeData(AppThemeType.light).extension<BullKeypadColors>(),
      BullKeypadColors.light,
    );
    expect(
      AppTheme.themeData(AppThemeType.dark).extension<BullKeypadColors>(),
      BullKeypadColors.dark,
    );
  });
}
