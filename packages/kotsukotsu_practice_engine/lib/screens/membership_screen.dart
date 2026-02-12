import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/navigation_args.dart';
import '../models/student_profile.dart';
import '../models/task_progress.dart';
import '../services/app_user_service.dart';
import '../services/task_progress_store.dart';
import 'payment_screen.dart';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  static const String routeName = '/member';

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _memoController = TextEditingController();

  late Future<_MemberData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('会員ページ')),
      body: FutureBuilder<_MemberData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? _MemberData.empty();
          _bindProfile(data.profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ログイン: ${data.loginId ?? '未ログイン'}'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var g = 1; g <= 6; g++)
                      Chip(
                        label: Text('G$g ${data.unlockedGrades.contains(g) || data.allUnlocked ? '解锁' : '未解锁'}'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      PaymentScreen.routeName,
                      arguments: const PaymentArgs(grade: 1),
                    );
                    if (!mounted) return;
                    setState(() {
                      _dataFuture = _loadData();
                    });
                  },
                  child: const Text('課金ページへ'),
                ),
                const SizedBox(height: 20),
                const Text('学生情報', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: '名前')),
                TextField(controller: _schoolController, decoration: const InputDecoration(labelText: '学校')),
                TextField(controller: _classController, decoration: const InputDecoration(labelText: 'クラス')),
                TextField(controller: _memoController, decoration: const InputDecoration(labelText: 'メモ')),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: _saveProfile,
                  child: const Text('保存'),
                ),
                const SizedBox(height: 20),
                const Text('学習進捗 (Grade平均正答率)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 220, child: _buildBarChart(data.progress)),
                const SizedBox(height: 20),
                const Text('学習推移', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 220, child: _buildLineChart(data.progress)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<_MemberData> _loadData() async {
    final loginId = await AppUserService.currentLoginId();
    final profile = await AppUserService.loadProfile();
    final unlockedGrades = await AppUserService.unlockedGrades();
    final allUnlocked = await AppUserService.isAllUnlocked();
    final progress = await TaskProgressStore.getAllProgress();
    return _MemberData(
      loginId: loginId,
      profile: profile,
      unlockedGrades: unlockedGrades,
      allUnlocked: allUnlocked,
      progress: progress,
    );
  }

  void _bindProfile(StudentProfile profile) {
    if (_nameController.text != profile.displayName) {
      _nameController.text = profile.displayName;
    }
    if (_schoolController.text != profile.schoolName) {
      _schoolController.text = profile.schoolName;
    }
    if (_classController.text != profile.className) {
      _classController.text = profile.className;
    }
    if (_memoController.text != profile.memo) {
      _memoController.text = profile.memo;
    }
  }

  Future<void> _saveProfile() async {
    final profile = StudentProfile(
      displayName: _nameController.text.trim(),
      schoolName: _schoolController.text.trim(),
      className: _classController.text.trim(),
      memo: _memoController.text.trim(),
    );
    await AppUserService.saveProfile(profile);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
  }

  Widget _buildBarChart(List<TaskProgressEntity> progress) {
    if (progress.isEmpty) return const Center(child: Text('データなし'));
    final byGrade = <int, List<double>>{};
    for (final item in progress) {
      if (item.total <= 0) continue;
      byGrade.putIfAbsent(item.grade, () => <double>[]);
      byGrade[item.grade]!.add(item.correct / item.total);
    }
    final bars = <BarChartGroupData>[];
    for (var g = 1; g <= 6; g++) {
      final list = byGrade[g] ?? const <double>[];
      final avg = list.isEmpty ? 0.0 : list.reduce((a, b) => a + b) / list.length;
      bars.add(
        BarChartGroupData(
          x: g,
          barRods: [BarChartRodData(toY: avg * 100, width: 14)],
        ),
      );
    }
    return BarChart(
      BarChartData(
        maxY: 100,
        barGroups: bars,
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget _buildLineChart(List<TaskProgressEntity> progress) {
    if (progress.isEmpty) return const Center(child: Text('データなし'));
    final spots = <FlSpot>[];
    for (var i = 0; i < progress.length; i++) {
      final item = progress[i];
      final rate = item.total <= 0 ? 0.0 : (item.correct / item.total) * 100;
      spots.add(FlSpot(i.toDouble(), rate));
    }
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class _MemberData {
  const _MemberData({
    required this.loginId,
    required this.profile,
    required this.unlockedGrades,
    required this.allUnlocked,
    required this.progress,
  });

  final String? loginId;
  final StudentProfile profile;
  final Set<int> unlockedGrades;
  final bool allUnlocked;
  final List<TaskProgressEntity> progress;

  factory _MemberData.empty() {
    return _MemberData(
      loginId: null,
      profile: StudentProfile.empty(),
      unlockedGrades: const <int>{},
      allUnlocked: false,
      progress: const <TaskProgressEntity>[],
    );
  }
}
