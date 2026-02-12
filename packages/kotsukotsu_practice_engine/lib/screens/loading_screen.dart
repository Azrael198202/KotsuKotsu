import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_navigation_config.dart';
import '../models/navigation_args.dart';
import '../services/app_user_service.dart';
import 'grade_select_screen.dart';
import 'intro_screen.dart';
import 'login_screen.dart';
import 'task_select_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  static const String routeName = '/loading';

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const String _loadingBase = 'ロード中';

  Timer? _bootTimer;
  Timer? _animTimer;
  double _progress = 0.0;
  int _textFrame = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _goNext();
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
    _animTimer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _animTimer = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (!mounted) return;
      setState(() {
        _progress += 0.04;
        if (_progress > 1.0) _progress = 0.0;
        _textFrame++;
      });
    });
  }

  void _goNext() {
    _bootTimer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;

      final nav = AppNavigationScope.of(context);
      if (nav.allowGradeSelection) {
        Navigator.pushReplacementNamed(context, GradeSelectScreen.routeName);
        return;
      }

      final grade = nav.fixedGrade ?? 1;
      if (nav.enableIntro) {
        Navigator.pushReplacementNamed(context, IntroScreen.routeName);
        return;
      }

      if (nav.enableLogin) {
        final loggedIn = await AppUserService.isLoggedIn();
        if (!mounted) return;
        if (loggedIn) {
          Navigator.pushReplacementNamed(
            context,
            TaskSelectScreen.routeName,
            arguments: GradeArgs(grade: grade),
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            LoginScreen.routeName,
            arguments: LoginArgs(grade: grade),
          );
        }
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        TaskSelectScreen.routeName,
        arguments: GradeArgs(grade: grade),
      );
    });
  }

  String get _animatedText {
    final frame = _textFrame % 6;
    final dotCount = frame <= 3 ? frame : 6 - frame;
    return '$_loadingBase${'.' * dotCount}';
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final backgroundAsset = orientation == Orientation.portrait
        ? 'assets/bg/back-v.png'
        : 'assets/bg/back.png';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE3F2FD), Color(0xFFFFFFFF)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 44,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFDFD),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF8D6E63),
                            width: 2.2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: SizedBox(
                            height: 20,
                            child: Stack(
                              children: [
                                Container(color: const Color(0xFFD7CCC8)),
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progress.clamp(0.0, 1.0),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final width = constraints.maxWidth;
                                      final tailStart =
                                          width <= 40 ? 0.0 : (1 - 40 / width).clamp(0.0, 1.0);
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            stops: [0.0, tailStart, 1.0],
                                            colors: const [
                                              Color(0xFF8BC34A),
                                              Color(0xFF66BB6A),
                                              Color(0xFFFFA726),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                IgnorePointer(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      height: 7,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.42),
                                            Colors.white.withValues(alpha: 0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 260,
                        child: Text(
                          _animatedText,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6D4C41),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
