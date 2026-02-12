import 'package:flutter/material.dart';

import 'config/app_navigation_config.dart';
import 'models/navigation_args.dart';
import 'screens/grade_select_screen.dart';
import 'screens/intro_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/login_screen.dart';
import 'screens/membership_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/task_select_screen.dart';

class KotsuKotsuPracticeApp extends StatelessWidget {
  const KotsuKotsuPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScope(
      config: const AppNavigationConfig(allowGradeSelection: true),
      child: MaterialApp(
        title: 'KotsuKotsu',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF0D47A1)),
          useMaterial3: true,
        ),
        initialRoute: LoadingScreen.routeName,
        routes: {
          LoadingScreen.routeName: (_) => const LoadingScreen(),
          GradeSelectScreen.routeName: (_) => const GradeSelectScreen(),
          IntroScreen.routeName: (_) => const IntroScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          MembershipScreen.routeName: (_) => const MembershipScreen(),
          OverviewScreen.routeName: (_) => const OverviewScreen(),
          PaymentScreen.routeName: (_) => const PaymentScreen(),
          TaskSelectScreen.routeName: (_) => const TaskSelectScreen(),
          QuizScreen.routeName: (_) => const QuizScreen(),
          ResultScreen.routeName: (_) => const ResultScreen(),
        },
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}

class Grade1PracticeApp extends StatelessWidget {
  const Grade1PracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigationScope(
      config: const AppNavigationConfig(
        allowGradeSelection: false,
        fixedGrade: 1,
        enableIntro: false,
        enableLogin: false,
        enableMembership: false,
      ),
      child: MaterialApp(
        title: 'KotsuKotsu Grade 1',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
          useMaterial3: true,
        ),
        initialRoute: LoadingScreen.routeName,
        routes: {
          LoadingScreen.routeName: (_) => const LoadingScreen(),
          IntroScreen.routeName: (_) => const IntroScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          MembershipScreen.routeName: (_) => const MembershipScreen(),
          OverviewScreen.routeName: (_) => const OverviewScreen(),
          PaymentScreen.routeName: (_) => const PaymentScreen(),
          QuizScreen.routeName: (_) => const QuizScreen(),
          ResultScreen.routeName: (_) => const ResultScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == TaskSelectScreen.routeName) {
            return MaterialPageRoute(
              builder: (_) => const TaskSelectScreen(),
              settings: const RouteSettings(
                name: TaskSelectScreen.routeName,
                arguments: GradeArgs(grade: 1),
              ),
            );
          }
          return _onGenerateRoute(settings, allowGradeSelection: false, fixedGrade: 1);
        },
      ),
    );
  }
}

Route<dynamic>? _onGenerateRoute(
  RouteSettings settings, {
  bool allowGradeSelection = true,
  int? fixedGrade,
}) {
  if (settings.name == TaskSelectScreen.routeName &&
      settings.arguments is GradeArgs) {
    return MaterialPageRoute(
      builder: (_) => const TaskSelectScreen(),
      settings: settings,
    );
  }
  if (settings.name == QuizScreen.routeName && settings.arguments is TaskArgs) {
    return MaterialPageRoute(
      builder: (_) => const QuizScreen(),
      settings: settings,
    );
  }
  if (settings.name == ResultScreen.routeName &&
      settings.arguments is ResultArgs) {
    return MaterialPageRoute(
      builder: (_) => const ResultScreen(),
      settings: settings,
    );
  }
  if (settings.name == LoginScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const LoginScreen(),
      settings: settings.arguments is LoginArgs
          ? settings
          : RouteSettings(
              name: LoginScreen.routeName,
              arguments: LoginArgs(grade: fixedGrade ?? 1),
            ),
    );
  }
  if (settings.name == MembershipScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const MembershipScreen(),
      settings: settings,
    );
  }
  if (settings.name == OverviewScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const OverviewScreen(),
      settings: settings,
    );
  }
  if (settings.name == PaymentScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const PaymentScreen(),
      settings: settings.arguments is PaymentArgs
          ? settings
          : RouteSettings(
              name: PaymentScreen.routeName,
              arguments: PaymentArgs(grade: fixedGrade ?? 1),
            ),
    );
  }
  if (settings.name == IntroScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const IntroScreen(),
      settings: settings,
    );
  }
  if (settings.name == LoadingScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const LoadingScreen(),
      settings: settings,
    );
  }
  if (allowGradeSelection && settings.name == GradeSelectScreen.routeName) {
    return MaterialPageRoute(
      builder: (_) => const GradeSelectScreen(),
      settings: settings,
    );
  }
  return null;
}
