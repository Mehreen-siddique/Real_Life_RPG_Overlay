import 'package:flutter/material.dart';

/// DEPRECATED: UI interaction tracking has been removed.
/// This wrapper now simply passes through the child widget without any
/// sensor reporting, as typing/scrolling detection is no longer supported.
///
/// Previously reported touch/scroll/typing events to SensorService, but
/// background apps cannot reliably intercept touch events across the entire
/// phone on iOS/Android due to platform restrictions.
class ActivityDetectionWrapper extends StatelessWidget {
  final Widget child;

  const ActivityDetectionWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simply return the child - no sensor reporting
    return child;
  }
}

/// DEPRECATED: Typing detection has been removed.
/// This mixin is kept for backward compatibility but does nothing.
mixin TypingDetectionMixin {
  void onTyping(String value) {
    // No-op: typing detection removed
  }

  void onKeyboardTap() {
    // No-op: keyboard tap detection removed
  }
}

/// DEPRECATED: Typing detection has been removed.
/// This widget simply passes through the child without any focus tracking.
class TypingDetector extends StatelessWidget {
  final Widget child;

  const TypingDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
