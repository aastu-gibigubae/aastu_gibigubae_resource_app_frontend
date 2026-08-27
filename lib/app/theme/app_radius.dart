import 'package:flutter/material.dart';

/// ================================================================
/// APP RADIUS
///
/// Consistent border-radius tokens.
/// ================================================================

class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 100;

  // ── BorderRadius shortcuts ────────────────────────────────────────

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  // ── RoundedRectangleBorder shortcuts ──────────────────────────────

  static RoundedRectangleBorder get smShape =>
      RoundedRectangleBorder(borderRadius: smAll);

  static RoundedRectangleBorder get mdShape =>
      RoundedRectangleBorder(borderRadius: mdAll);

  static RoundedRectangleBorder get lgShape =>
      RoundedRectangleBorder(borderRadius: lgAll);

  static RoundedRectangleBorder get pillShape =>
      RoundedRectangleBorder(borderRadius: pillAll);
}
