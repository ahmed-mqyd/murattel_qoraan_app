import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murattel_qoraan_app/core/text_app/text_app.dart';

class AppColors {
  // Light Theme Color Palette (Adopting the Visual Identity: Emerald & Gold)
  static const Color primaryLight = Color(
    0xFF003527,
  ); // Deep Emerald Green (#003527)
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFF064E3B);
  static const Color onPrimaryContainerLight = Color(0xFF80BEA6);
  static const Color inversePrimaryLight = Color(0xFFA0D1BC);

  static const Color secondaryLight = Color(0xFFC5A059); // Matte Gold (#C5A059)
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFFED65B);
  static const Color onSecondaryContainerLight = Color(0xFF776005);

  static const Color tertiaryLight = Color(0xFF181918);
  static const Color onTertiaryLight = Color(0xFFFFFFFF);
  static const Color tertiaryContainerLight = Color(0xFF2D2E2C);
  static const Color onTertiaryContainerLight = Color(0xFF959592);

  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color errorContainerLight = Color(0xFFFFDAD6);
  static const Color onErrorContainerLight = Color(0xFF93000A);

  static const Color backgroundLight = Color(0xFFF9F9FC);
  static const Color onBackgroundLight = Color(0xFF1A1C1E);

  static const Color surfaceLight = Color(0xFFF9F9FC);
  static const Color onSurfaceLight = Color(0xFF1A1C1E);
  static const Color surfaceVariantLight = Color(0xFFE2E2E5);
  static const Color onSurfaceVariantLight = Color(0xFF404944);

  static const Color outlineLight = Color(0xFF717974);
  static const Color outlineVariantLight = Color(0xFFBFC9C3);
  static const Color surfaceTintLight = Color(0xFF003527);

  // Custom Surface Containers (Light)
  static const Color surfaceDimLight = Color(0xFFDADADC);
  static const Color surfaceBrightLight = Color(0xFFF9F9FC);
  static const Color surfaceContainerLowestLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF3F3F6);
  static const Color surfaceContainerLight = Color(0xFFEEEEF0);
  static const Color surfaceContainerHighLight = Color(0xFFE8E8EA);
  static const Color surfaceContainerHighestLight = Color(0xFFE2E2E5);
  static const Color inverseSurfaceLight = Color(0xFF2F3133);
  static const Color inverseOnSurfaceLight = Color(0xFFF0F0F3);

  static const Color primaryFixedLight = Color(0xFFBCEDD8);
  static const Color primaryFixedDimLight = Color(0xFFA0D1BC);
  static const Color onPrimaryFixedLight = Color(0xFF002117);
  static const Color onPrimaryFixedVariantLight = Color(0xFF204F3F);

  static const Color secondaryFixedLight = Color(0xFFFFE085);
  static const Color secondaryFixedDimLight = Color(0xFFE3C466);
  static const Color onSecondaryFixedLight = Color(0xFF231B00);
  static const Color onSecondaryFixedVariantLight = Color(0xFF574500);

  static const Color tertiaryFixedLight = Color(0xFFE3E2DF);
  static const Color tertiaryFixedDimLight = Color(0xFFC7C6C3);
  static const Color onTertiaryFixedLight = Color(0xFF1B1C1A);
  static const Color onTertiaryFixedVariantLight = Color(0xFF464745);

  // Dark Theme Color Palette (Balanced "Emerald & Gold" for dark mode)
  static const Color primaryDark = Color(0xFFA0D1BC);
  static const Color onPrimaryDark = Color(0xFF003729);
  static const Color primaryContainerDark = Color(0xFF003527);
  static const Color onPrimaryContainerDark = Color(0xFFA0D1BC);
  static const Color inversePrimaryDark = Color(0xFF003527);

  static const Color secondaryDark = Color(0xFFE3C466);
  static const Color onSecondaryDark = Color(0xFF3E3000);
  static const Color secondaryContainerDark = Color(0xFF574500);
  static const Color onSecondaryContainerDark = Color(0xFFFFE085);

  static const Color tertiaryDark = Color(0xFFC7C6C3);
  static const Color onTertiaryDark = Color(0xFF30302E);
  static const Color tertiaryContainerDark = Color(0xFF464745);
  static const Color onTertiaryContainerDark = Color(0xFFE3E2DF);

  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  static const Color backgroundDark = Color(0xFF0F1110);
  static const Color onBackgroundDark = Color(0xFFE2E2E5);

  static const Color surfaceDark = Color(0xFF0F1110);
  static const Color onSurfaceDark = Color(0xFFE2E2E5);
  static const Color surfaceVariantDark = Color(0xFF404944);
  static const Color onSurfaceVariantDark = Color(0xFFBFC9C3);

  static const Color outlineDark = Color(0xFF8A938E);
  static const Color outlineVariantDark = Color(0xFF404944);
  static const Color surfaceTintDark = Color(0xFFA0D1BC);

  // Custom Surface Containers (Dark)
  static const Color surfaceDimDark = Color(0xFF0B0D0C);
  static const Color surfaceBrightDark = Color(0xFF1B1F1D);
  static const Color surfaceContainerLowestDark = Color(0xFF080909);
  static const Color surfaceContainerLowDark = Color(0xFF141716);
  static const Color surfaceContainerDarkVal = Color(0xFF1A1D1C);
  static const Color surfaceContainerHighDark = Color(0xFF242827);
  static const Color surfaceContainerHighestDark = Color(0xFF2E3331);
  static const Color inverseSurfaceDark = Color(0xFFE2E2E5);
  static const Color inverseOnSurfaceDark = Color(0xFF1A1C1E);
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color? surfaceDim;
  final Color? surfaceBright;
  final Color? surfaceContainerLowest;
  final Color? surfaceContainerLow;
  final Color? surfaceContainer;
  final Color? surfaceContainerHigh;
  final Color? surfaceContainerHighest;
  final TextStyle? quranTextStyle;

  AppThemeExtension({
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.quranTextStyle,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? surfaceDim,
    Color? surfaceBright,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    TextStyle? quranTextStyle,
  }) {
    return AppThemeExtension(
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      quranTextStyle: quranTextStyle ?? this.quranTextStyle,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
    ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t),
      surfaceBright: Color.lerp(surfaceBright, other.surfaceBright, t),
      surfaceContainerLowest: Color.lerp(
        surfaceContainerLowest,
        other.surfaceContainerLowest,
        t,
      ),
      surfaceContainerLow: Color.lerp(
        surfaceContainerLow,
        other.surfaceContainerLow,
        t,
      ),
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t),
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      ),
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      ),
      quranTextStyle: TextStyle.lerp(quranTextStyle, other.quranTextStyle, t),
    );
  }
}

class AppTheme {
  // Spacing & Shapes definitions
  static const double spacingUnit = 8.0;
  static const double spacingGutter = 24.0;
  static const double spacingMarginMobile = 16.0;
  static const double spacingMarginDesktop = 40.0;
  static const double spacingContainerMax = 720.0;

  static const double roundedSm = 4.0;
  static const double roundedDefault = 8.0;
  static const double roundedMd = 12.0;
  static const double roundedLg = 16.0;
  static const double roundedXl = 24.0;
  static const double roundedFull = 9999.0;

  // Custom shadows tinted with primary emerald green at very low opacity
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF003527).withValues(alpha: 0.05),
      blurRadius: 4.0,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF003527).withValues(alpha: 0.08),
      blurRadius: 8.0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: const Color(0xFF003527).withValues(alpha: 0.12),
      blurRadius: 24.0,
      offset: const Offset(0, 8),
    ),
  ];

  // Base Typography - Combined Noto Serif & Noto Naskh Arabic for bilingual support
  static TextStyle get displayLg => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 60 / 48,
      letterSpacing: -0.02,
    ),
  );

  static TextStyle get headlineLg => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 40 / 32,
    ),
  );

  static TextStyle get headlineLgMobile => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 32 / 24,
    ),
  );

  static TextStyle get titleMd => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 20,
      fontWeight: FontWeight.w500,
      height: 28 / 20,
    ),
  );

  static TextStyle get bodyLg => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 32 / 18,
    ),
  );

  static TextStyle get bodyMd => GoogleFonts.notoSerif(
    textStyle: GoogleFonts.getFont(
      TextApp.arabicFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 28 / 16,
    ),
  );

  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: 0.01,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
  );

  // Dedicated Quran text style using primary Noto Naskh Arabic
  static TextStyle get quranText => GoogleFonts.getFont(
    TextApp.arabicFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 2.0, // 200%
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        primaryContainer: AppColors.primaryContainerLight,
        onPrimaryContainer: AppColors.onPrimaryContainerLight,
        inversePrimary: AppColors.inversePrimaryLight,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondaryLight,
        secondaryContainer: AppColors.secondaryContainerLight,
        onSecondaryContainer: AppColors.onSecondaryContainerLight,
        tertiary: AppColors.tertiaryLight,
        onTertiary: AppColors.onTertiaryLight,
        tertiaryContainer: AppColors.tertiaryContainerLight,
        onTertiaryContainer: AppColors.onTertiaryContainerLight,
        error: AppColors.errorLight,
        onError: AppColors.onErrorLight,
        errorContainer: AppColors.errorContainerLight,
        onErrorContainer: AppColors.onErrorContainerLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        surfaceContainerHighest: AppColors.surfaceVariantLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
        outlineVariant: AppColors.outlineVariantLight,
        surfaceTint: AppColors.surfaceTintLight,
      ),
      textTheme: TextTheme(
        displayLarge: displayLg,
        headlineLarge: headlineLg,
        titleMedium: titleMd,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        labelMedium: labelMd,
        labelSmall: labelSm,
      ),
      extensions: [
        AppThemeExtension(
          surfaceDim: AppColors.surfaceDimLight,
          surfaceBright: AppColors.surfaceBrightLight,
          surfaceContainerLowest: AppColors.surfaceContainerLowestLight,
          surfaceContainerLow: AppColors.surfaceContainerLowLight,
          surfaceContainer: AppColors.surfaceContainerLight,
          surfaceContainerHigh: AppColors.surfaceContainerHighLight,
          surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
          quranTextStyle: quranText,
        ),
      ],
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        inversePrimary: AppColors.inversePrimaryDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        secondaryContainer: AppColors.secondaryContainerDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        tertiary: AppColors.tertiaryDark,
        onTertiary: AppColors.onTertiaryDark,
        tertiaryContainer: AppColors.tertiaryContainerDark,
        onTertiaryContainer: AppColors.onTertiaryContainerDark,
        error: AppColors.errorDark,
        onError: AppColors.onErrorDark,
        errorContainer: AppColors.errorContainerDark,
        onErrorContainer: AppColors.onErrorContainerDark,
         surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        surfaceTint: AppColors.surfaceTintDark,
      ),
      textTheme: TextTheme(
        displayLarge: displayLg.copyWith(color: AppColors.onBackgroundDark),
        headlineLarge: headlineLg.copyWith(color: AppColors.onBackgroundDark),
        titleMedium: titleMd.copyWith(color: AppColors.onBackgroundDark),
        bodyLarge: bodyLg.copyWith(color: AppColors.onBackgroundDark),
        bodyMedium: bodyMd.copyWith(color: AppColors.onBackgroundDark),
        labelMedium: labelMd.copyWith(color: AppColors.onBackgroundDark),
        labelSmall: labelSm.copyWith(color: AppColors.onBackgroundDark),
      ),
      extensions: [
        AppThemeExtension(
          surfaceDim: AppColors.surfaceDimDark,
          surfaceBright: AppColors.surfaceBrightDark,
          surfaceContainerLowest: AppColors.surfaceContainerLowestDark,
          surfaceContainerLow: AppColors.surfaceContainerLowDark,
          surfaceContainer: AppColors.surfaceContainerDarkVal,
          surfaceContainerHigh: AppColors.surfaceContainerHighDark,
          surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
          quranTextStyle: quranText.copyWith(color: AppColors.onSurfaceDark),
        ),
      ],
    );
  }

  // Sepia (Warm Paper) Theme
  static ThemeData get sepiaTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF5D4037),
      scaffoldBackgroundColor: const Color(0xFFF4ECD8),
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF5D4037),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF4E342E),
        onPrimaryContainer: Color(0xFFD7CCC8),
        inversePrimary: Color(0xFFD7CCC8),
        secondary: Color(0xFFC5A059),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFAF4E8),
        onSecondaryContainer: Color(0xFF5D4037),
        tertiary: Color(0xFF8C7A5B),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFFAF4E8),
        onTertiaryContainer: Color(0xFF8C7A5B),
        error: AppColors.errorLight,
        onError: AppColors.onErrorLight,
        errorContainer: AppColors.errorContainerLight,
        onErrorContainer: AppColors.onErrorContainerLight,
        surface: Color(0xFFFAF4E8),
        onSurface: Color(0xFF3E2723),
        surfaceContainerHighest: Color(0xFFFAF4E8),
        onSurfaceVariant: Color(0xFF8C7A5B),
        outline: Color(0xFF8C7A5B),
        outlineVariant: Color(0xFFD7CCC8),
        surfaceTint: Color(0xFF5D4037),
      ),
      textTheme: TextTheme(
        displayLarge: displayLg.copyWith(color: const Color(0xFF3E2723)),
        headlineLarge: headlineLg.copyWith(color: const Color(0xFF3E2723)),
        titleMedium: titleMd.copyWith(color: const Color(0xFF3E2723)),
        bodyLarge: bodyLg.copyWith(color: const Color(0xFF3E2723)),
        bodyMedium: bodyMd.copyWith(color: const Color(0xFF3E2723)),
        labelMedium: labelMd.copyWith(color: const Color(0xFF3E2723)),
        labelSmall: labelSm.copyWith(color: const Color(0xFF3E2723)),
      ),
      extensions: [
        AppThemeExtension(
          surfaceDim: const Color(0xFFEFE6D0),
          surfaceBright: const Color(0xFFFAF4E8),
          surfaceContainerLowest: const Color(0xFFFFFDF9),
          surfaceContainerLow: const Color(0xFFFAF4E8),
          surfaceContainer: const Color(0xFFF5EFE0),
          surfaceContainerHigh: const Color(0xFFEFE6D0),
          surfaceContainerHighest: const Color(0xFFE5DBC4),
          quranTextStyle: quranText.copyWith(color: const Color(0xFF3E2723)),
        ),
      ],
    );
  }
}
