import 'package:bull_ui/bull_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'wcag.dart';

typedef _Role = (String, Color Function(BullTheme));

void main() {
  const themes = {'light': BullTheme.light, 'dark': BullTheme.dark};

  // The surfaces text sits on.
  final surfaces = <_Role>[
    ('background', (c) => c.background),
    ('surface', (c) => c.surface),
    ('cardBackground', (c) => c.cardBackground),
    ('surfaceContainer', (c) => c.surfaceContainer),
  ];

  final textRoles = <_Role>[
    ('text', (c) => c.text),
    ('textMuted', (c) => c.textMuted),
    ('onSurface', (c) => c.onSurface),
    ('onSurfaceVariant', (c) => c.onSurfaceVariant),
    ('primaryText', (c) => c.primaryText),
    ('errorText', (c) => c.errorText),
    ('successText', (c) => c.successText),
    ('warningText', (c) => c.warningText),
  ];

  group('BullTheme contrast', () {
    for (final MapEntry(key: theme, value: colors) in themes.entries) {
      for (final (role, fg) in textRoles) {
        for (final (surface, bg) in surfaces) {
          test('$role on $surface reads at AA ($theme)', () {
            expect(contrast(fg(colors), bg(colors)), greaterThanOrEqualTo(4.5));
          });
        }
      }

      test('status text reads at AA on its container ($theme)', () {
        expect(
          contrast(colors.errorText, colors.errorContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(colors.warningText, colors.warningContainer),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('border and outline stand out from the background ($theme)', () {
        expect(
          contrast(colors.border, colors.background),
          greaterThanOrEqualTo(3.0),
        );
        expect(
          contrast(colors.outline, colors.background),
          greaterThanOrEqualTo(3.0),
        );
      });
    }

    // A light #F5F5F5 background caps black text at 19.3:1, against 21:1 for white on black, so text is held to near-maximal contrast rather than parity.
    test('text reads near the maximum on the background in both themes', () {
      for (final colors in themes.values) {
        expect(
          contrast(colors.text, colors.background),
          greaterThanOrEqualTo(19.0),
        );
      }
    });

    final parityPairs = <String, (Color, Color) Function(BullTheme)>{
      'textMuted on background': (c) => (c.textMuted, c.background),
      'border on background': (c) => (c.border, c.background),
    };
    for (final MapEntry(key: name, value: pair) in parityPairs.entries) {
      test('$name has the same contrast in both themes', () {
        final (lightFg, lightBg) = pair(BullTheme.light);
        final (darkFg, darkBg) = pair(BullTheme.dark);
        expect(
          contrast(lightFg, lightBg),
          closeTo(contrast(darkFg, darkBg), 0.1),
        );
      });
    }
  });
}
