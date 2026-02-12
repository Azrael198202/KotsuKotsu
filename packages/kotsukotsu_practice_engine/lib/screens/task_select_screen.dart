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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GradeArgs;
    if (_grade != args.grade || _future == null) {
      _grade = args.grade;
      _future = _loadData(args.grade);
      _statusFuture = MonetizationService.status();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await AdPopupService.showLocalAdPopup(context);
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 92,
        titleSpacing: 12,
        title: Row(
          children: [
            const Text(
              'かだい　せんたく',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: SizedBox(
                  height: 102,
                  child: Image.asset(
                    'assets/bg/title.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Text(
                      'かだい　せんたく',
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
              tooltip: '会員',
            ),
          FutureBuilder<MonetizationStatus>(
            future: _statusFuture,
            builder: (context, snapshot) {
              final purchased = snapshot.data?.purchased ?? false;
              if (purchased) {
                return const SizedBox.shrink();
              }
              return _WhiteImageActionButton(
                icon: Icons.lock_open_rounded,
                label: '課金',
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
            return const Center(child: Text('かだい　データがみつかりません'));
          }

          var prevPassed = true;
          return ListView.separated(
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
                status: data.monetizationStatus,
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
    return _TaskSelectData(
      configs: configs,
      progressByKey: progressByKey,
      monetizationStatus: monetizationStatus,
    );
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
    final bgColor = enabled ? const Color(0xFF2E7D32) : const Color(0xFFB0B7C3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.taskName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '時限 ${config.timeLimitSeconds}s',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (locked)
                const Icon(Icons.lock, color: Colors.amberAccent, size: 26)
              else if (enabled)
                const Icon(Icons.chevron_right, color: Colors.white),
              const SizedBox(width: 8),
              _ScoreBadge(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.progress});

  final TaskProgressEntity? progress;

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      return const Text(
        '--',
        style: TextStyle(fontSize: 16, color: Colors.white),
      );
    }
    return Text(
      progress!.scoreLabel,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
