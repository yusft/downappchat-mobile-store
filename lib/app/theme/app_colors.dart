import 'package:flutter/material.dart';

/// Uygulama renk paleti 
/// Modern, premium bir app store hissi için özenle seçilmiş renkler.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E8);
  static const Color primaryContainer = Color(0xFFE8E6FF);

  // ── Secondary ────────────────────────────────
  static const Color secondary = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFF8FA6);
  static const Color secondaryDark = Color(0xFFE84567);

  // ── Accent ───────────────────────────────────
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentGreen = Color(0xFF2EA043);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentPurple = Color(0xFFA855F7);

  // ── Status ───────────────────────────────────
  static const Color success = Color(0xFF2EA043);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // ── Dark Theme ───────────────────────────────
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkCard = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkDivider = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextTertiary = Color(0xFF6E7681);

  // ── Light Theme ──────────────────────────────
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightDivider = Color(0xFFEAEEF2);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);
  static const Color lightTextTertiary = Color(0xFF8C959F);

  // ── Gradients ────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFFFF8A65)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF21262D),
      Color(0xFF30363D),
      Color(0xFF21262D),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // ── Badge Colors ─────────────────────────────
  static const Color verifiedBadge = Color(0xFF58A6FF);
  static const Color developerBadge = Color(0xFF2EA043);
  static const Color topReviewerBadge = Color(0xFFD29922);

  // ── Category Colors ──────────────────────────
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF00D2FF),
    Color(0xFF2EA043),
    Color(0xFFFF9F43),
    Color(0xFFA855F7),
    Color(0xFFEF4444),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
  ];

  /// Kategori index'ine göre renk döndürür
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
