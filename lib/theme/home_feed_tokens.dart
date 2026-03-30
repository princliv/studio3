import 'package:flutter/material.dart';

/// Home feed design tokens (Studio 3 Pinterest-style).
abstract final class HomeFeedTokens {
  static const Color background = Color(0xFFFAFAF7);
  static const Color textPrimary = Color(0xFF231F1B);
  static const Color textInverse = Color(0xFFFAFAF7);

  static const double cardRadius = 10;
  static const double sideMargin = 10;
  static const double rowGap = 10;

  static const double tallCardHeight = 448;
  static const double shortCardHeight = 202;
  static const double rowBHeight = 211;
  static const double rowCSize = 118;
  static const double gapB = 10;
  static const double gapC = 5;

  static const double dotSize = 6;
  static const double dotInset = 8;
  static const double avatarSize = 28;
  static const double artistTextWidth = 76;
}
