import 'package:bull_ui/bull_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

enum AppThemeType { light, dark }

class AppTheme {
  static ThemeData themeData(AppThemeType themeType) {
    final brightness = themeType == AppThemeType.dark
        ? Brightness.dark
        : Brightness.light;
    final colors = BullTheme.of(brightness);
    const type = BullTypography.standard;
    const shapes = BullShapes.standard;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: bullUiExtensions(colors: colors, brightness: brightness),
      // Material widgets read Bull's colours, so nothing is derived from the red seed. Roles without a Bull colour use the nearest one.
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primary.withValues(alpha: 0.12),
        onPrimaryContainer: colors.primaryText,
        primaryFixed: colors.primaryFixed,
        onPrimaryFixed: colors.onPrimaryFixed,
        // Accent text on inverseSurface, which has the other theme's background.
        inversePrimary: BullTheme.of(
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        ).primaryText,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.surfaceContainerHighest,
        onSecondaryContainer: colors.onSurface,
        secondaryFixed: colors.secondaryFixed,
        secondaryFixedDim: colors.secondaryFixedDim,
        onSecondaryFixed: colors.onSecondaryFixed,
        tertiary: colors.tertiary,
        onTertiary: colors.onTertiary,
        tertiaryContainer: colors.tertiaryContainer,
        onTertiaryContainer: colors.onTertiary,
        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.errorContainer,
        onErrorContainer: colors.errorText,
        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceDim: colors.background,
        surfaceBright: colors.surfaceBright,
        surfaceContainerLowest: colors.surface,
        surfaceContainerLow: colors.surface,
        surfaceContainer: colors.surfaceContainer,
        surfaceContainerHigh: colors.cardBackground,
        surfaceContainerHighest: colors.surfaceContainerHighest,
        onSurfaceVariant: colors.onSurfaceVariant,
        inverseSurface: colors.inverseSurface,
        onInverseSurface: colors.surface,
        outline: colors.outline,
        outlineVariant: colors.outlineVariant,
        scrim: colors.scrim,
        surfaceTint: colors.transparent,
      ),
      canvasColor: colors.cardBackground,
      scaffoldBackgroundColor: colors.background,
      fontFamily: BullTypography.fontFamily,
      textTheme: type.toTextTheme().apply(
        bodyColor: colors.text,
        displayColor: colors.text,
      ),
      /* TODO: Add theme for inputs like TextField here and remove BBInputText
       Make sure to check impact on all different inputs in the app and adjust accordingly.
       + do the same for other widgets like dropdowns, buttons, etc.
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: type.body.copyWith(
          color: colours.surfaceContainer,
        ),
        filled: true,
        fillColor: colours.onPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colours.surface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colours.surface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colours.surface),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: colours.surface),
        ),
      ),
       */
      appBarTheme: AppBarTheme(
        backgroundColor: colors.transparent,
        systemOverlayStyle: themeType == AppThemeType.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: type.subtitle.copyWith(color: colors.text),
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.text),
        actionsIconTheme: IconThemeData(color: colors.text),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) => const Icon(Icons.arrow_back),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedIconTheme: IconThemeData(color: colors.primaryText),
        unselectedIconTheme: IconThemeData(color: colors.textMuted),
        selectedLabelStyle: TextStyle(color: colors.primaryText),
        unselectedLabelStyle: TextStyle(color: colors.textMuted),
        selectedItemColor: colors.primaryText,
        unselectedItemColor: colors.textMuted,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primaryText),
      ),
      cardTheme: CardThemeData(
        color: colors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapes.card),
          side: BorderSide(color: colors.border),
        ),
        elevation: 0,
        shadowColor: colors.border,
        margin: EdgeInsets.zero,
      ),
      switchTheme: BullSwitch.themeData(colors),
      listTileTheme: ListTileThemeData(
        tileColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapes.card),
          side: BorderSide(color: colors.border),
        ),
        textColor: colors.text,
        titleTextStyle: type.subtitle.copyWith(fontWeight: .w400),
        subtitleTextStyle: type.caption.copyWith(color: colors.textMuted),
        leadingAndTrailingTextStyle: type.label.copyWith(color: colors.text),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        refreshBackgroundColor: colors.text,
        color: colors.primary,
        circularTrackColor: colors.primary,
        linearTrackColor: colors.surface,
      ),
    );
  }
}

extension ThemeEx on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get font => theme.textTheme;
  BullTheme get appColors => BullTheme.of(theme.brightness);
}

class WidgetStyles {
  static InputDecoration inputDecoration(
    BuildContext context,
    String hintText,
  ) {
    final shapes = context.bullShapes;
    return InputDecoration(
      fillColor: context.appColors.surface,
      filled: true,
      hintText: hintText,
      hintStyle: context.font.bodyMedium!.copyWith(
        color: context.appColors.textMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.input),
        borderSide: BorderSide(color: context.appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.input),
        borderSide: BorderSide(color: context.appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.input),
        borderSide: BorderSide(color: context.appColors.border, width: 2.0),
      ),
    );
  }
}
