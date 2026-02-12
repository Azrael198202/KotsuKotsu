import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../services/practice_history_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  static const String routeName = '/overview';

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Future<List<PracticeAttempt>> _future;

  @override
  void initState() {
    super.initState();
    _future = PracticeHistoryService.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学習総覧')),
      body: FutureBuilder<List<PracticeAttempt>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? const <PracticeAttempt>[];
          if (data.isEmpty) {
            return const Center(child: Text('記録がありません'));
          }

          final totalQuestions = data.fold<int>(0, (sum, e) => sum + e.total);
          final totalCorrect = data.fold<int>(0, (sum, e) => sum + e.correct);
          final avgErrorRate =
              totalQuestions <= 0 ? 0.0 : (totalQuestions - totalCorrect) / totalQuestions;
          final avgTime = data.fold<int>(0, (sum, e) => sum + e.durationSeconds) / data.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('総課題数: ${data.length}'),
                Text('総問題数: $totalQuestions'),
                Text('平均誤答率: ${(avgErrorRate * 100).toStringAsFixed(1)}%'),
                Text('平均所要時間: ${avgTime.toStringAsFixed(1)}s'),
                const SizedBox(height: 12),
                const Text('成績推移'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildLine(data),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('誤答率'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildErrorBar(data),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('履歴'),
                const SizedBox(height: 8),
                ...data.reversed.take(50).map(
                  (e) => Card(
                    child: ListTile(
                      title: Text('G${e.grade} ${e.taskName} ${e.correct}/${e.total}'),
                      subtitle: Text(
                        '${e.timestamp.toLocal()}  ${e.durationSeconds}s  誤答率 ${(e.errorRate * 100).toStringAsFixed(1)}%',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLine(List<PracticeAttempt> data) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      final score = item.total <= 0 ? 0.0 : (item.correct / item.total) * 100;
      spots.add(FlSpot(i.toDouble(), score));
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
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget _buildErrorBar(List<PracticeAttempt> data) {
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < data.length && i < 20; i++) {
      final item = data[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: item.errorRate * 100, width: 8)],
        ),
      );
    }
    return BarChart(
      BarChartData(
        maxY: 100,
        barGroups: groups,
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
