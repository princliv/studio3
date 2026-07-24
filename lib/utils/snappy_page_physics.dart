import 'package:flutter/material.dart';

/// A `PageScrollPhysics` tuned for a horizontal page-swipe that lives
/// alongside vertical scrollables (e.g. a `ListView` inside each page):
///
/// - [dragStartDistanceMotionThreshold] requires a clearly-horizontal drag
///   before the page actually starts moving, so scrolling a list to its top
///   or bottom (which can have a little horizontal wobble) doesn't get
///   misread as the start of a page swipe.
/// - [spring] is stiffer/lighter than the default, so a swipe settles onto
///   the next/previous page quickly instead of leaving a long "tail" that
///   blocks a follow-up vertical scroll.
class SnappyPageScrollPhysics extends PageScrollPhysics {
  const SnappyPageScrollPhysics({super.parent});

  @override
  SnappyPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappyPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double? get dragStartDistanceMotionThreshold => 12.0;

  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
        mass: 0.3,
        stiffness: 200,
        ratio: 1.1,
      );
}
