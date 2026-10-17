import 'package:flutter/material.dart';

/// Mofu's visual language: soft cream surfaces, a warm cocoa ink, one candy
/// pink accent, and rounded type everywhere.
class MofuColors {
  const MofuColors._();
  static const ink = Color(0xFF4A3542);
  static const inkSoft = Color(0xFF8A7280);
  static const accent = Color(0xFFFF7FA8);
  static const accentDeep = Color(0xFFC2386A); // AA: 5.2:1 with white text, 5.3:1 as text on cards
  static const cream = Color(0xFFFFF8F2);
  static const card = Color(0xFFFFFFFF);
  static const line = Color(0xFFF1E3EA);
  static const lock = Color(0xFFCDBFC7);
  static const gold = Color(0xFFFFC94D);
}

/// Paper-craft cozy tokens from the "Mofu & Friends — UI design" canvas
/// (every text pair checked AA with tools/contrast).
class House {
  const House._();
  static const paper = Color(0xFFFBF3E8);
  static const ink = Color(0xFF3A2A2E); // 12.3:1 on paper
  static const inkSoft = Color(0xFF5B4E57); // 7.9:1 on white
  static const rose = Color(0xFFC2386A); // white text 5.2:1
  static const roseDeep = Color(0xFF8A1F48);
  static const tag = Color(0xFFFFF9F1);
  static const stitch = Color(0xFFD4B08F);
  static const tagShadow = Color(0xFFE3C7A8);
  static const wood = Color(0xFF94603D); // cream text 4.8:1
  static const woodDeep = Color(0xFF7E4F31);
  static const woodEdge = Color(0xFFC38B5E);
  static const woodText = Color(0xFFFFF3E3);
  static const coinShadow = Color(0xFF6E4429);
  static const star = Color(0xFFF2B632);
  static const starEdge = Color(0xFFC98A12);
  static const night = Color(0xFF241F45);
  static const nightText = Color(0xFFF3EEFF);
  static const lilac = Color(0xFF5A4E8E);
  static const sky = Color(0xFF2F6F86);
  static const leaf = Color(0xFF2E6B3B);
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
      surface: House.paper,
      onSurface: House.ink,
    ),
    scaffoldBackgroundColor: House.paper,
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
