import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/assignment_config.dart';
import '../services/assignment_rules_loader.dart';
import '../services/practice_history_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  static const String routeName = '/overview';

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  late Future<_OverviewData> _future;
  bool _detailSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_OverviewData> _loadData() async {
    final attempts = await PracticeHistoryService.loadAll();
    final configs = await AssignmentRulesLoader().loadConfigs();
    final configByKey = <String, AssignmentConfig>{};
    for (final config in configs) {
      configByKey[_key(config.grade, config.taskKey)] = config;
    }
    return _OverviewData(attempts: attempts, configByKey: configByKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FB),
      appBar: AppBar(
        title: const Text('がくしゅう そうらん'),
      ),
      body: FutureBuilder<_OverviewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null || data.attempts.isEmpty) {
            return const Center(child: Text('きろくが ありません'));
          }

          final series = _buildSeries(data);
          final practiceSeries =
              series.where((e) => !e.config.isTestTask).toList();
          final testSeries = series.where((e) => e.config.isTestTask).toList();

          final totalQuestions =
              data.attempts.fold<int>(0, (sum, e) => sum + e.total);
          final totalCorrect =
              data.attempts.fold<int>(0, (sum, e) => sum + e.correct);
          final avgAccuracy =
              totalQuestions == 0 ? 0.0 : (totalCorrect / totalQuestions) * 100;
          final avgTime =
              data.attempts.fold<int>(0, (sum, e) => sum + e.durationSeconds) /
                  data.attempts.length;

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _summaryCard(
                    attempts: data.attempts.length,
                    avgAccuracy: avgAccuracy,
                    avgTime: avgTime,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      labelColor: const Color(0xFF2F3A46),
                      unselectedLabelColor: const Color(0xFF5D6B7A),
                      indicatorColor: const Color(0xFF59B64E),
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      dividerColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor:
                          WidgetStateProperty.all(Colors.transparent),
                      labelStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      isScrollable: false,
                      tabs: const [
                        Tab(text: 'れんしゅう'),
                        Tab(text: 'しけん'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      _practiceTab(practiceSeries),
                      _testTab(testSeries),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard({
    required int attempts,
    required double avgAccuracy,
    required double avgTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7EC8F8), Color(0xFF59AFE5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'まとめ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'ちょうせん  $attempts かい',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'せいかいりつ  ${avgAccuracy.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'へいきんじかん  ${avgTime.toStringAsFixed(0)}びょう',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 300,
              height: 200,
              child: Image.asset(
                'assets/bg/best.png',
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) =>
                    const SizedBox(width: 300, height: 200),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _practiceTab(List<_TaskSeries> seriesList) {
    if (seriesList.isEmpty) {
      return const Center(child: Text('れんしゅうの きろくが ありません'));
    }

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < seriesList.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: seriesList[i].passCount.toDouble(),
              width: 15,
              color: const Color(0xFF43A047),
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    final maxY =
        (seriesList.map((e) => e.passCount).fold<int>(0, (a, b) => a > b ? a : b) + 1)
            .toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _sectionCard(
          title: 'れんしゅう',
          gradient: const [Color(0xFF7EC8F8), Color(0xFF59AFE5)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Text('ごうかく かいすう ぐらふ'),
              ),
              SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0x553A4A5A),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xFF8BA0B3)),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= seriesList.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: barGroups,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (event, response) {
                          if (event is! FlTapUpEvent) return;
                          final touched = response?.spot?.touchedBarGroupIndex;
                          if (touched == null ||
                              touched < 0 ||
                              touched >= seriesList.length) {
                            return;
                          }
                          _showDetail(seriesList[touched], isTest: false);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: seriesList
                      .map(
                        (e) => ActionChip(
                          avatar: const Icon(Icons.menu_book_rounded, size: 18),
                          label: Text('${e.displayName} (${e.passCount})'),
                          onPressed: () => _showDetail(e, isTest: false),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _testTab(List<_TaskSeries> seriesList) {
    if (seriesList.isEmpty) {
      return const Center(child: Text('しけんの きろくが ありません'));
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < seriesList.length; i++) {
      final latest = seriesList[i].latest;
      final score = latest.total == 0 ? 0.0 : (latest.correct / latest.total) * 100;
      spots.add(FlSpot(i.toDouble(), score));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _sectionCard(
          title: 'しけん',
          gradient: const [Color(0xFF9E6BFF), Color(0xFF7E4DDE)],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Text('さいしん せいせき ぐらふ(%)'),
              ),
              SizedBox(
                height: 220,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0x553A4A5A),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                        ),
                        drawVerticalLine: false,
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xFF8BA0B3)),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= seriesList.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          barWidth: 3,
                          color: const Color(0xFF00BCD4),
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchCallback: (event, response) {
                          if (event is! FlTapUpEvent) return;
                          final lineSpots = response?.lineBarSpots;
                          if (lineSpots == null || lineSpots.isEmpty) return;
                          final i = lineSpots.first.x.toInt();
                          if (i < 0 || i >= seriesList.length) return;
                          _showDetail(seriesList[i], isTest: true);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ...seriesList.map((e) {
                final latest = e.latest;
                final medal = _medalAsset(e, latest);
                return ListTile(
                  leading: const Icon(Icons.assignment_turned_in_rounded),
                  title: Text(e.displayName),
                  subtitle: Text(
                    'てんすう ${latest.correct}/${latest.total}  じかん ${latest.durationSeconds}s',
                  ),
                  trailing: medal == null
                      ? const Icon(Icons.chevron_right_rounded)
                      : SizedBox(width: 30, height: 30, child: Image.asset(medal)),
                  onTap: () => _showDetail(e, isTest: true),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Color> gradient,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  List<_TaskSeries> _buildSeries(_OverviewData data) {
    final grouped = <String, List<PracticeAttempt>>{};
    for (final attempt in data.attempts) {
      grouped
          .putIfAbsent(_key(attempt.grade, attempt.taskKey), () => <PracticeAttempt>[])
          .add(attempt);
    }

    final out = <_TaskSeries>[];
    for (final entry in grouped.entries) {
      final attempts = entry.value..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final first = attempts.first;
      final config = data.configByKey[entry.key] ??
          AssignmentConfig(
            grade: first.grade,
            taskKey: first.taskKey,
            taskName: first.taskName,
            passScore: 0,
            timeLimitSeconds: 0,
          );
      final passCount = attempts.where((a) => _isPassed(a, config)).length;
      out.add(
        _TaskSeries(
          grade: first.grade,
          taskKey: first.taskKey,
          displayName: first.taskName,
          attempts: attempts,
          config: config,
          passCount: passCount,
        ),
      );
    }

    out.sort((a, b) {
      if (a.grade != b.grade) return a.grade.compareTo(b.grade);
      return a.displayName.compareTo(b.displayName);
    });
    return out;
  }

  bool _isPassed(PracticeAttempt attempt, AssignmentConfig config) {
    final passScore = config.passScore > 0 ? config.passScore : attempt.total;
    final inTime = config.timeLimitSeconds <= 0 ||
        attempt.durationSeconds <= config.timeLimitSeconds;
    return attempt.correct >= passScore && inTime;
  }

  String? _medalAsset(_TaskSeries series, PracticeAttempt attempt) {
    return series.config.medalAssetFor(
      score: attempt.correct,
      isPassed: _isPassed(attempt, series.config),
    );
  }

  Future<void> _showDetail(_TaskSeries series, {required bool isTest}) async {
    if (_detailSheetOpen) return;
    _detailSheetOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          final media = MediaQuery.of(context);
          final availableHeight =
              media.size.height - media.padding.top - media.padding.bottom;
          const topGap = 42.0;
          const bottomGap = 14.0;
          final sheetHeight = (availableHeight - topGap - bottomGap).clamp(
            380.0,
            availableHeight - (topGap + bottomGap),
          );

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: topGap, bottom: bottomGap),
              child: Material(
                color: const Color(0xFFF7FAFF),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: sheetHeight,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text(
                        isTest
                            ? 'しけんのしょうさい: ${series.displayName}'
                            : 'れんしゅうのしょうさい: ${series.displayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('かいすう: ${series.attempts.length}'),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.separated(
                        itemCount: series.attempts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final attempt = series.attempts[index];
                          final medal = isTest ? _medalAsset(series, attempt) : null;
                          return ListTile(
                            leading: medal == null
                                ? CircleAvatar(
                                    radius: 16,
                                    backgroundColor: _isPassed(attempt, series.config)
                                        ? const Color(0xFF43A047)
                                        : const Color(0xFF90A4AE),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(medal),
                                  ),
                            title: Text(
                              'てんすう ${attempt.correct}/${attempt.total}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              'じかん ${attempt.durationSeconds}s  ひづけ ${_fmt(attempt.timestamp)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: _isPassed(attempt, series.config)
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2E7D32),
                                  )
                                : const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFC62828),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _detailSheetOpen = false;
    }
  }

  String _fmt(DateTime dt) {
    final t = dt.toLocal();
    final m = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final h = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '${t.year}-$m-$d $h:$mm';
  }
}

class _OverviewData {
  const _OverviewData({
    required this.attempts,
    required this.configByKey,
  });

  final List<PracticeAttempt> attempts;
  final Map<String, AssignmentConfig> configByKey;
}

class _TaskSeries {
  const _TaskSeries({
    required this.grade,
    required this.taskKey,
    required this.displayName,
    required this.attempts,
    required this.config,
    required this.passCount,
  });

  final int grade;
  final String taskKey;
  final String displayName;
  final List<PracticeAttempt> attempts;
  final AssignmentConfig config;
  final int passCount;

  PracticeAttempt get latest => attempts.last;
}

String _key(int grade, String taskKey) => 'g$grade/$taskKey';
