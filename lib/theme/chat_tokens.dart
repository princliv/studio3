import 'package:flutter/material.dart';

/// Direct-message thread design tokens (Instagram-inspired light chat).
abstract final class ChatTokens {
  /// Soft gray canvas — distinct from home feed cream `#FAFAF7`.
  static const Color background = Color(0xFFEEEEEE);
  static const Color headerBackground = Color(0xFFFAFAFA);
  static const Color timestamp = Color(0xFF8E8E8E);
  static const Color username = Color(0xFF8E8E8E);
  static const Color emptyStats = Color(0xFF8E8E8E);
}
