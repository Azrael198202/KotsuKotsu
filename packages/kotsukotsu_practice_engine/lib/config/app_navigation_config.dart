import 'package:flutter/widgets.dart';

class AppNavigationConfig {
  const AppNavigationConfig({
    required this.allowGradeSelection,
    this.fixedGrade,
    this.enableIntro = true,
    this.enableLogin = true,
    this.enableMembership = true,
  });

  final bool allowGradeSelection;
  final int? fixedGrade;
  final bool enableIntro;
  final bool enableLogin;
  final bool enableMembership;
}

class AppNavigationScope extends InheritedWidget {
  const AppNavigationScope({
    super.key,
    required this.config,
    required super.child,
  });

  final AppNavigationConfig config;

  static const AppNavigationConfig _defaultConfig = AppNavigationConfig(
    allowGradeSelection: true,
  );

  static AppNavigationConfig of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppNavigationScope>();
    return scope?.config ?? _defaultConfig;
  }

  @override
  bool updateShouldNotify(covariant AppNavigationScope oldWidget) {
    return oldWidget.config.allowGradeSelection != config.allowGradeSelection ||
        oldWidget.config.fixedGrade != config.fixedGrade ||
        oldWidget.config.enableIntro != config.enableIntro ||
        oldWidget.config.enableLogin != config.enableLogin ||
        oldWidget.config.enableMembership != config.enableMembership;
  }
}
