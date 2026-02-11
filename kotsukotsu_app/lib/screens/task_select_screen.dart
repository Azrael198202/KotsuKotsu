import 'package:flutter/material.dart';

import '../config/app_engine_config.dart';
import '../models/assignment_config.dart';
import '../models/navigation_args.dart';
import '../models/task_progress.dart';
import '../services/assignment_rules_loader.dart';
import '../services/task_progress_store.dart';
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as GradeArgs;
    return Scaffold(
      appBar: AppBar(title: Text('課題（小学${args.grade}年）')),
      body: FutureBuilder<_TaskSelectData>(
        future: _loadData(args.grade),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.configs.isEmpty) {
            return const Center(child: Text('この学年にはトピックは割り当てられていません。'));
          }
          var prevPassed = true;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: data.configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final config = data.configs[index];
              final progress = data.progressByKey[config.taskKey];
              final isEnabled = index == 0 || prevPassed;
              if (isEnabled) {
                prevPassed = progress?.isPassed ?? false;
              }
              return _TaskTypeTile(
                config: config,
                progress: progress,
                enabled: isEnabled,
                onTap: isEnabled
                    ? () {
                        Navigator.pushNamed(
                          context,
                          QuizScreen.routeName,
                          arguments: TaskArgs(
                            grade: config.grade,
                            taskKey: config.taskKey,
                            taskName: config.taskName,
                          ),
                        );
                      }
                    : null,
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
    return _TaskSelectData(configs: configs, progressByKey: progressByKey);
  }
}

class _TaskSelectData {
  const _TaskSelectData({
    required this.configs,
    required this.progressByKey,
  });

  final List<AssignmentConfig> configs;
  final Map<String, TaskProgressEntity> progressByKey;
}

class _TaskTypeTile extends StatelessWidget {
  const _TaskTypeTile({
    required this.config,
    required this.progress,
    required this.enabled,
    required this.onTap,
  });

  final AssignmentConfig config;
  final TaskProgressEntity? progress;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = enabled ? const Color(0xFF2E7D32) : const Color(0xFFB0B7C3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(
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
                        ],
                      ),
                    ),
                    if (enabled)
                      const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ScoreBadge(progress: progress),
                  const SizedBox(height: 6),
                  _TaskMeta(
                    timeLimitSeconds: config.timeLimitSeconds,
                    actualSeconds: progress?.durationSeconds,
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

class _TaskMeta extends StatelessWidget {
  const _TaskMeta({
    required this.timeLimitSeconds,
    required this.actualSeconds,
  });

  final int timeLimitSeconds;
  final int? actualSeconds;

  @override
  Widget build(BuildContext context) {
    final actualText = actualSeconds == null ? '--' : '${actualSeconds}s';
    return Text(
      '規定:${timeLimitSeconds}s  実績:$actualText',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.white70,
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
    if (progress!.isPerfect) {
      return _DoubleRingBadge(label: progress!.scoreLabel);
    }
    if (progress!.isPassed) {
      return _SingleRingBadge(label: progress!.scoreLabel);
    }
    return Text(
      progress!.scoreLabel,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    );
  }
}

class _SingleRingBadge extends StatelessWidget {
  const _SingleRingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD32F2F), width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFD32F2F),
        ),
      ),
    );
  }
}

class _DoubleRingBadge extends StatelessWidget {
  const _DoubleRingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD32F2F), width: 3),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD32F2F), width: 3),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD32F2F),
            ),
          ),
        ),
      ],
    );
  }
}
