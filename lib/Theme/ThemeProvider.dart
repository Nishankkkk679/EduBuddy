import 'package:edubuddy/Theme/ThemeNotifier.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends InheritedNotifier<ThemeNotifier> {
  final ThemeNotifier notifier;

  const ThemeProvider({
    Key? key, // Add Key parameter here
    required this.notifier,
    required Widget child,
  }) : super(
            key: key,
            notifier: notifier,
            child: child); // Call super constructor with key parameter

  static ThemeProvider? watch(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  static ThemeNotifier of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider!.notifier;
  }
}
