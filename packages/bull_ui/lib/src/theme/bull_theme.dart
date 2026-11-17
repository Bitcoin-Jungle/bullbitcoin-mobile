import 'package:material_ui/material_ui.dart';

/// The `bull_ui` colour palette, injected by the app as a [ThemeExtension].
///
/// [light] and [dark] hold Bull's values; the app, the catalogue and the tests register the one matching their brightness on [ThemeData] via `extensions:` (see `bullUiExtensions`).
/// Components read colours through [BullThemeX.bull] (e.g. `context.bull.primary`); derived fills use `tokenColor.withValues(alpha: …)` so they adapt to both brightnesses automatically.
@immutable
class BullTheme extends ThemeExtension<BullTheme> {
  const BullTheme({
    required this.primary,
    required this.primaryText,
    required this.onPrimary,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixed,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.bitcoinOrange,
    required this.background,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.surfaceBright,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.inverseSurface,
    required this.cardBackground,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.errorText,
    required this.onError,
    required this.errorContainer,
    required this.success,
    required this.successText,
    required this.warning,
    required this.warningText,
    required this.warningContainer,
    required this.info,
    required this.scrim,
    required this.overlay,
    required this.transparent,
    required this.surfaceFixed,
    required this.onSurfaceFixed,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  // Primary colours.
  /// The accent as a fill: buttons, switches, selection.
  final Color primary;

  /// The accent as text or a standalone icon, at least 4.5:1 on every surface; [primary] stays for fills.
  final Color primaryText;
  final Color onPrimary;
  final Color primaryFixed;
  final Color onPrimaryFixed;

  // Secondary colours.
  final Color secondary;
  final Color onSecondary;
  final Color secondaryFixed;
  final Color secondaryFixedDim;
  final Color onSecondaryFixed;

  // Tertiary colours (accent).
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;

  /// Bitcoin asset colour (`#f7931a`). Used for the on-chain keychain badge and
  /// other BTC-specific accents.
  final Color bitcoinOrange;

  // Surface colours.
  final Color background;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerHighest;
  final Color surfaceBright;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color inverseSurface;
  final Color cardBackground;

  // Text colours.
  final Color text;
  final Color textMuted;

  // Border colours.
  final Color border;
  final Color outline;
  final Color outlineVariant;

  // Status colours. [error], [success] and [warning] are fills, badges and borders; their `*Text` role colours text and standalone icons, at least 4.5:1 on every surface and on its container.
  final Color error;
  final Color errorText;
  final Color onError;
  final Color errorContainer;
  final Color success;
  final Color successText;
  final Color warning;
  final Color warningText;
  final Color warningContainer;
  final Color info;

  // Overlay colours.
  final Color scrim;
  final Color overlay;

  // Fixed colours (same in both themes).
  final Color transparent;
  final Color surfaceFixed;
  final Color onSurfaceFixed;

  // Shimmer / loading colours.
  final Color shimmerBase;
  final Color shimmerHighlight;

  /// Bull's palette on a light theme.
  static const light = BullTheme(
    primary: Color(0xFFC50909),
    primaryText: Color(0xFFC50909),
    onPrimary: Color(0xFFFFFFFF),
    primaryFixed: Color(0xFFC50909),
    onPrimaryFixed: Color(0xFFFFFFFF),
    secondary: Color(0xFF000000),
    onSecondary: Color(0xFFFFFFFF),
    secondaryFixed: Color(0xFF15171C),
    secondaryFixedDim: Color(0xFFC9CACD),
    onSecondaryFixed: Color(0xFFFFFFFF),
    tertiary: Color(0xFFFFCC00),
    onTertiary: Color(0xFFFF9500),
    tertiaryContainer: Color(0xFFFFF4E6),
    bitcoinOrange: Color(0xFFF7931A),
    background: Color(0xFFF5F5F5),
    surface: Color(0xFFFFFFFF),
    surfaceContainer: Color(0xFFF5F5F5),
    surfaceContainerHighest: Color(0xFFE8E8E8),
    surfaceBright: Color(0xFFFFFFFF),
    onSurface: Color(0xFF000000),
    onSurfaceVariant: Color(0xFF555555),
    inverseSurface: Color(0xFF000000),
    cardBackground: Color(0xFFFFFFFF),
    text: Color(0xFF000000),
    textMuted: Color(0xFF555555),
    border: Color(0xFF8D8D8D),
    outline: Color(0xFF8D8D8D),
    outlineVariant: Color(0xFFE8E8E8),
    error: Color(0xFFFF3B30),
    errorText: Color(0xFFD50B00),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    success: Color(0xFF34C759),
    successText: Color(0xFF22813A),
    warning: Color(0xFFFB9300),
    warningText: Color(0xFFA56000),
    warningContainer: Color(0xFFFFF4E6),
    info: Color(0xFF0063F7),
    scrim: Color(0x26000000),
    overlay: Color(0x80000000),
    transparent: Color(0x00000000),
    surfaceFixed: Color(0xFFFFFFFF),
    onSurfaceFixed: Color(0xFF15171C),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
  );

  /// Bull's palette on a dark theme.
  static const dark = BullTheme(
    primary: Color(0xFFC50909),
    primaryText: Color(0xFFFF5C5C),
    onPrimary: Color(0xFFFFFFFF),
    primaryFixed: Color(0xFFC50909),
    onPrimaryFixed: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF15171C),
    secondaryFixed: Color(0xFF15171C),
    secondaryFixedDim: Color(0xFF58585A),
    onSecondaryFixed: Color(0xFFFFFFFF),
    tertiary: Color(0xFFFFCC00),
    onTertiary: Color(0xFFFF9F0A),
    tertiaryContainer: Color(0xFF3D2D00),
    bitcoinOrange: Color(0xFFF7931A),
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceContainer: Color(0xFF2C2C2E),
    surfaceContainerHighest: Color(0xFF3C3C3E),
    surfaceBright: Color(0xFF48484A),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFF939398),
    inverseSurface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFF2C2C2E),
    text: Color(0xFFFFFFFF),
    textMuted: Color(0xFF939398),
    border: Color(0xFF5A5A5C),
    outline: Color(0xFF5A5A5C),
    outlineVariant: Color(0xFF3C3C3E),
    error: Color(0xFFFF453A),
    errorText: Color(0xFFFF5F57),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF3D0000),
    success: Color(0xFF32D74B),
    successText: Color(0xFF32D74B),
    warning: Color(0xFFFF9F0A),
    warningText: Color(0xFFFF9F0A),
    warningContainer: Color(0xFF3D2D00),
    info: Color(0xFF0A84FF),
    scrim: Color(0x26000000),
    overlay: Color(0x80000000),
    transparent: Color(0x00000000),
    surfaceFixed: Color(0xFFFFFFFF),
    onSurfaceFixed: Color(0xFF15171C),
    shimmerBase: Color(0xFF3C3C3E),
    shimmerHighlight: Color(0xFF48484A),
  );

  /// [light] or [dark] for [brightness].
  static BullTheme of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  @override
  BullTheme copyWith({
    Color? primary,
    Color? primaryText,
    Color? onPrimary,
    Color? primaryFixed,
    Color? onPrimaryFixed,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryFixed,
    Color? secondaryFixedDim,
    Color? onSecondaryFixed,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? bitcoinOrange,
    Color? background,
    Color? surface,
    Color? surfaceContainer,
    Color? surfaceContainerHighest,
    Color? surfaceBright,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? inverseSurface,
    Color? cardBackground,
    Color? text,
    Color? textMuted,
    Color? border,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? errorText,
    Color? onError,
    Color? errorContainer,
    Color? success,
    Color? successText,
    Color? warning,
    Color? warningText,
    Color? warningContainer,
    Color? info,
    Color? scrim,
    Color? overlay,
    Color? transparent,
    Color? surfaceFixed,
    Color? onSurfaceFixed,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return BullTheme(
      primary: primary ?? this.primary,
      primaryText: primaryText ?? this.primaryText,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      onPrimaryFixed: onPrimaryFixed ?? this.onPrimaryFixed,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryFixedDim: secondaryFixedDim ?? this.secondaryFixedDim,
      onSecondaryFixed: onSecondaryFixed ?? this.onSecondaryFixed,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      tertiaryContainer: tertiaryContainer ?? this.tertiaryContainer,
      bitcoinOrange: bitcoinOrange ?? this.bitcoinOrange,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      cardBackground: cardBackground ?? this.cardBackground,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      errorText: errorText ?? this.errorText,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      success: success ?? this.success,
      successText: successText ?? this.successText,
      warning: warning ?? this.warning,
      warningText: warningText ?? this.warningText,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      scrim: scrim ?? this.scrim,
      overlay: overlay ?? this.overlay,
      transparent: transparent ?? this.transparent,
      surfaceFixed: surfaceFixed ?? this.surfaceFixed,
      onSurfaceFixed: onSurfaceFixed ?? this.onSurfaceFixed,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  BullTheme lerp(covariant BullTheme? other, double t) {
    if (other == null) return this;
    return BullTheme(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryFixed: Color.lerp(primaryFixed, other.primaryFixed, t)!,
      onPrimaryFixed: Color.lerp(onPrimaryFixed, other.onPrimaryFixed, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryFixedDim: Color.lerp(
        secondaryFixedDim,
        other.secondaryFixedDim,
        t,
      )!,
      onSecondaryFixed: Color.lerp(
        onSecondaryFixed,
        other.onSecondaryFixed,
        t,
      )!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      tertiaryContainer: Color.lerp(
        tertiaryContainer,
        other.tertiaryContainer,
        t,
      )!,
      bitcoinOrange: Color.lerp(bitcoinOrange, other.bitcoinOrange, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      inverseSurface: Color.lerp(inverseSurface, other.inverseSurface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      surfaceFixed: Color.lerp(surfaceFixed, other.surfaceFixed, t)!,
      onSurfaceFixed: Color.lerp(onSurfaceFixed, other.onSurfaceFixed, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}

/// Accessor for the injected [BullTheme] off any [BuildContext].
extension BullThemeX on BuildContext {
  /// The active [BullTheme]. Throws if the app did not register one — every
  /// `bull_ui` consumer must wrap its tree in a [Theme] carrying a [BullTheme]
  /// extension (the app does this in its `ThemeData`).
  BullTheme get bull => Theme.of(this).extension<BullTheme>()!;

  /// The ambient [TextTheme] (Golos Text roles). Exposed so feature code that
  /// may only import `package:bull_ui/bull_ui.dart` can style text from the
  /// design-system typography without touching Material's `Theme` directly.
  TextTheme get bullText => Theme.of(this).textTheme;
}
