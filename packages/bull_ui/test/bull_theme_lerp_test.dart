import 'package:bull_ui/bull_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lerp starts at this theme and ends at the other', () {
    const light = BullTheme.light;
    const dark = BullTheme.dark;

    final start = light.lerp(dark, 0);
    final end = light.lerp(dark, 1);

    expect(start.primaryText, light.primaryText);
    expect(start.errorText, light.errorText);
    expect(start.text, light.text);
    expect(end.primaryText, dark.primaryText);
    expect(end.successText, dark.successText);
    expect(end.warningText, dark.warningText);
    expect(end.background, dark.background);
  });

  test('lerp halfway mixes both themes', () {
    final half = BullTheme.light.lerp(BullTheme.dark, 0.5);

    expect(
      half.text,
      Color.lerp(BullTheme.light.text, BullTheme.dark.text, 0.5),
    );
  });

  test('lerp with no other theme keeps this one', () {
    expect(BullTheme.light.lerp(null, 0.5), BullTheme.light);
  });
}
