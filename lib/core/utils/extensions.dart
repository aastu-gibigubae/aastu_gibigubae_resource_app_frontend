import 'package:flutter/material.dart';

/// ================================================================
/// EXTENSIONS
///
/// Convenience extensions on common Dart / Flutter types.
/// ================================================================

// ── String ───────────────────────────────────────────────────────

extension StringX on String {
  /// Capitalises the first character.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns true when the string is a valid email.
  bool get isEmail => RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Trims and returns null if the result is empty.
  String? get trimmedOrNull {
    final t = trim();
    return t.isEmpty ? null : t;
  }
}

extension NullableStringX on String? {
  /// Returns true when null or blank.
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
}

// ── DateTime ─────────────────────────────────────────────────────

extension DateTimeX on DateTime {
  /// True when this date is more than [days] days in the past.
  bool isOlderThan(int days) {
    return DateTime.now().difference(this).inDays >= days;
  }

  /// ISO-8601 string representation.
  String get iso8601 => toIso8601String();
}

// ── BuildContext ──────────────────────────────────────────────────

extension ContextX on BuildContext {
  // ── Size helpers ───────────────────────────────────────────────
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // ── Theme shortcuts ────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Snack bars ─────────────────────────────────────────────────
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnack(String message) => showSnack(message, isError: true);
}

// ── AsyncValue helpers ────────────────────────────────────────────

extension ListX<T> on List<T> {
  /// Safe first element; returns null if empty.
  T? get firstOrNull => isEmpty ? null : first;
}
