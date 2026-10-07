import 'package:flutter/material.dart';

/// Mofu's visual language: soft cream surfaces, a warm cocoa ink, one candy
/// pink accent, and rounded type everywhere.
class MofuColors {
  const MofuColors._();
  static const ink = Color(0xFF4A3542);
  static const inkSoft = Color(0xFF8A7280);
  static const accent = Color(0xFFFF7FA8);
  static const accentDeep = Color(0xFFE85C8A);
  static const cream = Color(0xFFFFF8F2);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFF1E3EA);
  static const lock = Color(0xFFCDBFC7);
  static const gold = Color(0xFFFFC94D);
}

const kLatinFont = 'Nunito';
const kArabicFont = 'BalooBhaijaan2';

/// iOS ships a rounded Japanese face; using it as the fallback keeps Japanese
/// in the same soft style without bundling a 4 MB CJK font.
const kFallbackFonts = ['Hiragino Maru Gothic ProN', 'Hiragino Sans', 'PingFang SC'];

ThemeData mofuTheme(Locale locale) {
  final family = locale.languageCode == 'ar' ? kArabicFont : kLatinFont;
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MofuColors.accent,
      primary: MofuColors.accentDeep,
      surface: MofuColors.cream,
      onSurface: MofuColors.ink,
    ),
    scaffoldBackgroundColor: MofuColors.cream,
    fontFamily: family,
    fontFamilyFallback: kFallbackFonts,
  );
  final text = base.textTheme.apply(
    bodyColor: MofuColors.ink,
    displayColor: MofuColors.ink,
    fontFamily: family,
    fontFamilyFallback: kFallbackFonts,
  );
  return base.copyWith(
    textTheme: text.copyWith(
      titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      bodyMedium: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: text.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: MofuColors.inkSoft),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: MofuColors.cream,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: MofuColors.lock,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: MofuColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MofuColors.accentDeep,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 52),
        shape: const StadiumBorder(),
        textStyle: TextStyle(fontFamily: family, fontWeight: FontWeight.w800, fontSize: 17),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MofuColors.inkSoft,
        minimumSize: const Size(64, 48),
        textStyle: TextStyle(fontFamily: family, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? MofuColors.accentDeep : MofuColors.lock),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MofuColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: MofuColors.accent, width: 2),
      ),
    ),
  );
}
