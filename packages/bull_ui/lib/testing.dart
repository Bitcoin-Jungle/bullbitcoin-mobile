import 'package:bull_ui/bull_ui.dart';
import 'package:material_ui/material_ui.dart';

/// The light [BullTheme] for widget tests. A bare `MaterialApp` would crash
/// `context.bull` (the accessor force-unwraps the extension), so every test
/// wraps its widget in this.
const testBullTheme = BullTheme.light;

/// Every theme extension `bull_ui` components read, for tests that build their
/// own `ThemeData`: `ThemeData(extensions: testBullExtensions)`.
final testBullExtensions = bullUiExtensions(
  colors: testBullTheme,
  brightness: Brightness.light,
);

/// Wraps [child] in a `MaterialApp` carrying [testBullExtensions].
Widget wrapWithTheme(Widget child) {
  return MaterialApp(
    theme: ThemeData(extensions: testBullExtensions),
    localizationsDelegates: bullUiLocalizationsDelegates,
    supportedLocales: BullUiLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}
