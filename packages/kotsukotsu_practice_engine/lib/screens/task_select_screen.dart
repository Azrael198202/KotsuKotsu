import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_engine_config.dart';
import '../config/app_navigation_config.dart';
import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../models/task_progress.dart';
import '../services/ad_popup_service.dart';
import '../services/assignment_rules_loader.dart';
import '../services/monetization_service.dart';
import '../services/task_progress_store.dart';
import 'membership_screen.dart';
import 'overview_screen.dart';
import 'payment_screen.dart';
import 'quiz_screen.dart';
import 'legal_safety_screen.dart';

class TaskSelectScreen extends StatefulWidget {
  const TaskSelectScreen({super.key});

  static const String routeName = '/tasks';

  @override
  State<TaskSelectScreen> createState() => _TaskSelectScreenState();
}

class _TaskSelectScreenState extends State<TaskSelectScreen> {
  final _rulesLoader = AssignmentRulesLoader(
    assetPath: appEngineConfig.assignmentRulesAssetPath,
  );

  Future<_TaskSelectData>? _future;
  Future<MonetizationStatus>? _statusFuture;
  int? _grade;
  Timer? _freeExpiryTimer;
  bool _adRequestedOnce = false;
  bool _hideStatusBanner = false;
  final ScrollController _listController = ScrollController();
  bool _didInitialAutoScroll = false;

  @override
  void dispose() {
    _freeExpiryTimer?.cancel();
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GradeArgs;
    if (_grade != args.grade || _future == null) {
      _grade = args.grade;
      _future = _loadData(args.grade);
      _statusFuture = MonetizationService.status();
      _didInitialAutoScroll = false;
      _hideStatusBanner = false;
    }

    if (!_adRequestedOnce) {
      _adRequestedOnce = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await AdPopupService.showLocalAdPopup(context);
      });
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 92,
        titleSpacing: 12,
        title: Row(
          children: [
            const Text(
              'かだい せんたく',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 72,
                  child: Image.asset(
                    'assets/bg/title.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'かだい せんたく',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          _WhiteImageActionButton(
            icon: Icons.bar_chart_rounded,
            label: 'せいせき',
            onTap: () => Navigator.pushNamed(context, OverviewScreen.routeName),
          ),
          if (AppNavigationScope.of(context).enableMembership)
            IconButton(
              onPressed: () async {
                await Navigator.pushNamed(context, MembershipScreen.routeName);
                if (!mounted) return;
                setState(() {
                  _future = _loadData(args.grade);
                });
              },
              icon: const Icon(Icons.workspace_premium),
              tooltip: 'メンバー',
            ),
          FutureBuilder<MonetizationStatus>(
            future: _statusFuture,
            builder: (context, snapshot) {
              final purchased = snapshot.data?.purchased ?? false;
              if (kReleaseMode && purchased) {
                return const SizedBox.shrink();
              }
              return _WhiteImageActionButton(
                icon: Icons.lock_open_rounded,
                label: purchased ? '課金済み' : '課金',
                onTap: () async {
                  await Navigator.pushNamed(
                    context,
                    PaymentScreen.routeName,
                    arguments: PaymentArgs(grade: args.grade),
                  );
                  if (!mounted) return;
                  setState(() {
                    _future = _loadData(args.grade);
                    _statusFuture = MonetizationService.status();
                  });
                },
              );
            },
          ),
          _WhiteImageActionButton(
            icon: Icons.shield_outlined,
            label: 'けんり',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LegalSafetyScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<_TaskSelectData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.configs.isEmpty) {
            return const Center(child: Text('かだいが みつかりません'));
          }

          final now = DateTime.now();
          final freeEnd = MonetizationService.launchDate.add(
            const Duration(days: 7),
          );
          final inFreeWeek =
              !now.isBefore(MonetizationService.launchDate) &&
              now.isBefore(freeEnd);
          final liveStatus = MonetizationStatus(
            purchased: data.monetizationStatus.purchased,
            inLaunchFreeWeek: inFreeWeek,
            freeDaysRemaining: inFreeWeek ? freeEnd.difference(now).inDays + 1 : 0,
          );

          var prevPassed = true;
          final autoScrollIndex = _findLastSelectableIndex(
            configs: data.configs,
            progressByKey: data.progressByKey,
            status: liveStatus,
          );
          _scheduleInitialAutoScroll(autoScrollIndex);
          return Column(
            children: [
              if (!_hideStatusBanner)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: _FreeCountdownBanner(
                    status: liveStatus,
                    freeEnd: freeEnd,
                    onClose: () {
                      setState(() {
                        _hideStatusBanner = true;
                      });
                    },
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  controller: _listController,
                  padding: const EdgeInsets.all(16),
                  itemCount: data.configs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final config = data.configs[index];
                    final progress = data.progressByKey[config.taskKey];

                    final isFlowEnabled = index == 0 || prevPassed;
                    if (isFlowEnabled) {
                      prevPassed = progress?.isPassed ?? false;
                    }
                    final isLockedByPayment = MonetizationService.isTaskLocked(
                      taskIndex: index,
                      status: liveStatus,
                    );

                    return _TaskTypeTile(
                      config: config,
                      progress: progress,
                      enabled: isFlowEnabled,
                      locked: isLockedByPayment,
                      onTap: !isFlowEnabled
                          ? null
                          : () async {
                              if (isLockedByPayment) {
                                final purchased = await Navigator.pushNamed(
                                  context,
                                  PaymentScreen.routeName,
                                  arguments: PaymentArgs(
                                    grade: config.grade,
                                    taskName: config.taskName,
                                  ),
                                );
                                if (!mounted) return;
                                if (purchased == true) {
                                  setState(() {
                                    _future = _loadData(args.grade);
                                    _statusFuture = MonetizationService.status();
                                  });
                                }
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                QuizScreen.routeName,
                                arguments: TaskArgs(
                                  grade: config.grade,
                                  taskKey: config.taskKey,
                                  taskName: config.taskName,
                                ),
                              );
                            },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_TaskSelectData> _loadData(int grade) async {
    final configs = await _rulesLoader.loadConfigsForGrade(grade);
    final progressByKey = await TaskProgressStore.getProgressForGrade(
      grade,
      configs.map((config) => config.taskKey),
    );
    final monetizationStatus = await MonetizationService.status();
    _scheduleFreeExpiryRefresh(monetizationStatus);
    return _TaskSelectData(
      configs: configs,
      progressByKey: progressByKey,
      monetizationStatus: monetizationStatus,
    );
  }

  void _scheduleFreeExpiryRefresh(MonetizationStatus status) {
    _freeExpiryTimer?.cancel();
    if (status.purchased || !status.inLaunchFreeWeek) return;
    final freeEnd = MonetizationService.launchDate.add(const Duration(days: 7));
    final delay = freeEnd.difference(DateTime.now());
    if (delay <= Duration.zero) return;
    _freeExpiryTimer = Timer(delay + const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  int _findLastSelectableIndex({
    required List<AssignmentConfig> configs,
    required Map<String, TaskProgressEntity> progressByKey,
    required MonetizationStatus status,
  }) {
    var prevPassed = true;
    var lastSelectable = 0;
    for (var index = 0; index < configs.length; index++) {
      final config = configs[index];
      final progress = progressByKey[config.taskKey];
      final isFlowEnabled = index == 0 || prevPassed;
      if (isFlowEnabled) {
        prevPassed = progress?.isPassed ?? false;
      }
      final isLockedByPayment = MonetizationService.isTaskLocked(
        taskIndex: index,
        status: status,
      );
      if (isFlowEnabled && !isLockedByPayment) {
        lastSelectable = index;
      }
    }
    return lastSelectable;
  }

  void _scheduleInitialAutoScroll(int index) {
    if (_didInitialAutoScroll) return;
    _didInitialAutoScroll = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) return;
      const itemExtent = 112.0; // tile(100) + separator(12)
      final target = (index * itemExtent).clamp(
        0.0,
        _listController.position.maxScrollExtent,
      ).toDouble();
      _listController.jumpTo(target);
    });
  }

}
class _FreeCountdownBanner extends StatefulWidget {
  const _FreeCountdownBanner({
    required this.status,
    required this.freeEnd,
    required this.onClose,
  });

  final MonetizationStatus status;
  final DateTime freeEnd;
  final VoidCallback onClose;

  @override
  State<_FreeCountdownBanner> createState() => _FreeCountdownBannerState();
}

class _FreeCountdownBannerState extends State<_FreeCountdownBanner> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _FreeCountdownBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status.inLaunchFreeWeek != widget.status.inLaunchFreeWeek ||
        oldWidget.status.purchased != widget.status.purchased) {
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (widget.status.purchased || !widget.status.inLaunchFreeWeek) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final Color bgColor;
    final IconData icon;
    final String text;
    final bool emphasizeDays;

    if (status.purchased) {
      bgColor = const Color(0xFFDFF4E6);
      icon = Icons.verified_rounded;
      emphasizeDays = status.freeDaysRemaining > 0;
      text = emphasizeDays
          ? 'ぜんコース りようできます のこり  '
          : 'ぜんコース りようできます';
    } else if (status.inLaunchFreeWeek) {
      final remaining = widget.freeEnd.difference(_now);
      bgColor = const Color(0xFFE8F3FF);
      icon = Icons.timer_outlined;
      text = 'むりょう のこり ${_formatRemaining(remaining)}';
      emphasizeDays = false;
    } else {
      bgColor = const Color(0xFFFFF1E0);
      icon = Icons.lock_outline_rounded;
      text = 'たいけん しゅうりょう。まえ 3つ の れんしゅう は むりょう です';
      emphasizeDays = false;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2A3B4D)),
          const SizedBox(width: 8),
          Expanded(
            child: emphasizeDays
                ? RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2A3B4D),
                      ),
                      children: [
                        TextSpan(text: text),
                        TextSpan(
                          text: '${status.freeDaysRemaining}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2A3B4D),
                          ),
                        ),
                        const TextSpan(text: '  にち'),
                      ],
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A3B4D),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: widget.onClose,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemaining(Duration duration) {
    final totalSeconds = duration.inSeconds < 0 ? 0 : duration.inSeconds;
    final days = totalSeconds ~/ 86400;
    final hours = (totalSeconds % 86400) ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hh = hours.toString().padLeft(2, '0');
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (days > 0) {
      return '$daysにち $hh:$mm:$ss';
    }
    return '$hh:$mm:$ss';
  }
}

class _WhiteImageActionButton extends StatelessWidget {
  const _WhiteImageActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD3DBE5), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 27, color: const Color(0xFF5D6B7A)),
                const SizedBox(height: 1),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D6B7A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskSelectData {
  const _TaskSelectData({
    required this.configs,
    required this.progressByKey,
    required this.monetizationStatus,
  });

  final List<AssignmentConfig> configs;
  final Map<String, TaskProgressEntity> progressByKey;
  final MonetizationStatus monetizationStatus;
}

class _TaskTypeTile extends StatelessWidget {
  const _TaskTypeTile({
    required this.config,
    required this.progress,
    required this.enabled,
    required this.locked,
    required this.onTap,
  });

  final AssignmentConfig config;
  final TaskProgressEntity? progress;
  final bool enabled;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isTestTask = config.isTestTask;
    final medalAsset = progress == null
        ? null
        : config.medalAssetFor(
            score: progress!.correct,
            isPassed: progress!.isPassed,
          );
    final bgGradient = isTestTask
        ? (enabled
              ? const LinearGradient(
                  colors: [Color(0xFF9E6BFF), Color(0xFF7E4DDE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFB7A2E3), Color(0xFF9C8AC8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ))
        : (enabled
              ? const LinearGradient(
                  colors: [Color(0xFF76C95F), Color(0xFF59B64E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFFC4CAD3), Color(0xFFA9B0BC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -12,
              right: -10,
              child: Opacity(
                opacity: enabled ? 0.14 : 0.08,
                child: const Icon(
                  Icons.auto_awesome,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isTestTask
                          ? Icons.assignment_turned_in_rounded
                          : Icons.menu_book_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                config.taskName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          progress == null
                              ? 'かいとう じかん やく ${(config.timeLimitSeconds / 60).ceil()} ふん'
                              : 'せいせき ${progress!.scoreLabel} / じかん ${config.timeLimitSeconds}s',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (medalAsset != null) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Image.asset(
                        medalAsset,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                  const SizedBox(width: 10),
                  if (locked)
                    const _LockBadge()
                  else
                    _StartActionButton(
                      label: progress == null ? 'はじめる' : 'ふくしゅう',
                      enabled: enabled,
                      onTap: onTap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartActionButton extends StatelessWidget {
  const _StartActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gradient = enabled
        ? const LinearGradient(
            colors: [Color(0xFFFFB23E), Color(0xFFFF8A00)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFFE2E2E2), Color(0xFFCFCFCF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFFFFF), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x2A7A3F00),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2CF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD675)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: Color(0xFFB17E00), size: 16),
          SizedBox(width: 4),
          Text(
            'ロック中',
            style: TextStyle(
              color: Color(0xFFB17E00),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

