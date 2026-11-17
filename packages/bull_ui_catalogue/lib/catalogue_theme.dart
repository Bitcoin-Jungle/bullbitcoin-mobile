import 'package:bull_ui/bull_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Builds a Material [ThemeData] carrying the [BullTheme] extension, matching
/// how the app wires `bull_ui` (extension on `ThemeData.extensions`). Components
/// read their colours via `context.bull`, so the extension is what matters.
ThemeData catalogueThemeData(Brightness brightness) {
  final bull = BullTheme.of(brightness);
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: BullTypography.fontFamily,
    textTheme: BullTypography.standard.toTextTheme(),
    extensions: bullUiExtensions(colors: bull, brightness: brightness),
    colorScheme: ColorScheme.fromSeed(
      seedColor: bull.primary,
      brightness: brightness,
      primary: bull.primary,
    ),
    scaffoldBackgroundColor: bull.surface,
    canvasColor: bull.cardBackground,
  );
}
