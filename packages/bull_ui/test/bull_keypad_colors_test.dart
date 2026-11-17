import 'package:bull_ui/bull_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';
import 'wcag.dart';

void main() {
  group('BullKeypadColors', () {
    final pairs = <String, (Color, Color) Function(BullKeypadColors)>{
      'onKey on key': (c) => (c.onKey, c.key),
      'key on panel': (c) => (c.key, c.panel),
      'functionKey on panel': (c) => (c.functionKey, c.panel),
      'onFunctionKey on functionKey': (c) => (c.onFunctionKey, c.functionKey),
      'onFunctionKeyDisabled on functionKey': (c) =>
          (c.onFunctionKeyDisabled, c.functionKey),
      'disabledGlyph on panel': (c) => (c.disabledGlyph, c.panel),
    };

    for (final MapEntry(key: name, value: pair) in pairs.entries) {
      test('$name reads with the same contrast in both themes', () {
        final (lightFg, lightBg) = pair(BullKeypadColors.light);
        final (darkFg, darkBg) = pair(BullKeypadColors.dark);
        expect(
          contrast(lightFg, lightBg),
          closeTo(contrast(darkFg, darkBg), 0.05),
        );
      });
    }

    // The dark keypad keys and glyphs come from the dark palette. Its greys do not: they keep the keypad pairs at light parity, while the palette greys are sized for text and borders on every surface.
    test('the dark keypad keys match the dark palette', () {
      const keypad = BullKeypadColors.dark;
      const colors = BullTheme.dark;
      expect(keypad.panel, colors.surfaceContainerHighest);
      expect(keypad.key, colors.background);
      expect(keypad.onKey, colors.onSurface);
    });

    test('of picks the preset for the brightness', () {
      expect(BullKeypadColors.of(Brightness.light), BullKeypadColors.light);
      expect(BullKeypadColors.of(Brightness.dark), BullKeypadColors.dark);
    });

    test('copyWith replaces only the given roles', () {
      const red = Color(0xFFFF0000);
      final c = BullKeypadColors.dark.copyWith(panel: red);
      expect(c.panel, red);
      expect(c.key, BullKeypadColors.dark.key);
      expect(c.disabledGlyph, BullKeypadColors.dark.disabledGlyph);
    });

    test('lerp returns the endpoints and itself without another side', () {
      const a = BullKeypadColors.light;
      const b = BullKeypadColors.dark;
      expect(a.lerp(b, 0).panel, a.panel);
      expect(a.lerp(b, 1).panel, b.panel);
      expect(a.lerp(null, 0.5), same(a));
    });

    testWidgets('context.bullKeypad reads the registered colours', (
      tester,
    ) async {
      late BullKeypadColors keypad;
      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (context) {
              keypad = context.bullKeypad;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(keypad, same(BullKeypadColors.light));
    });

    testWidgets('context.bullKeypad throws when none is registered', (
      tester,
    ) async {
      Object? error;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: const [testBullTheme]),
          home: Builder(
            builder: (context) {
              try {
                context.bullKeypad;
              } on StateError catch (e) {
                error = e;
              }
              return const SizedBox();
            },
          ),
        ),
      );
      expect(error, isA<StateError>());
      expect('$error', contains('BullKeypadColors'));
    });
  });
}
