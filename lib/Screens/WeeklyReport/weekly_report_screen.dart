import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:real_life_rpg/Models/daily_health_data.dart';
import 'package:real_life_rpg/Services/Health/health_connect_service.dart';
import 'package:real_life_rpg/utils/constants.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  final HealthConnectService _healthService = HealthConnectService();
  List<DailyHealthData> _weekData = [];
  bool _isLoading = true;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyData();
  }

  Future<void> _fetchWeeklyData() async {
    setState(() => _isLoading = true);
    try {
      await _healthService.initialize();
      final data = await _healthService.getWeeklyHealthData();
      if (mounted) setState(() => _weekData = data);
    } catch (e) {
      debugPrint('[WeeklyReport] Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Computed helpers ──
  int get _totalSteps => _weekData.fold(0, (s, d) => s + d.steps);
  double get _totalDist => _weekData.fold(0.0, (s, d) => s + d.distanceKm);
  double get _totalCal => _weekData.fold(0.0, (s, d) => s + d.calories);
  int get _totalActive => _weekData.fold(0, (s, d) => s + d.activeMinutes);
  int get _days => _weekData.isNotEmpty ? _weekData.length : 1;
  double get _avgSteps => _totalSteps / _days;
  double get _avgCal => _totalCal / _days;
  double get _avgDist => _totalDist / _days;
  double get _avgActive => _totalActive / _days;

  int _maxSteps() => _weekData.fold(0, (m, d) => d.steps > m ? d.steps : m);
  double _maxCal() => _weekData.fold(0.0, (m, d) => d.calories > m ? d.calories : m);
  double _maxDist() => _weekData.fold(0.0, (m, d) => d.distanceKm > m ? d.distanceKm : m);
  int _maxActive() => _weekData.fold(0, (m, d) => d.activeMinutes > m ? d.activeMinutes : m);

  String _trend(List<double> vals) {
    if (vals.length < 2) return '→';
    final firstHalf = vals.sublist(0, vals.length ~/ 2);
    final secondHalf = vals.sublist(vals.length ~/ 2);
    final avg1 = firstHalf.reduce((a, b) => a + b) / firstHalf.length;
    final avg2 = secondHalf.reduce((a, b) => a + b) / secondHalf.length;
    if (avg2 > avg1 * 1.05) return '↑';
    if (avg2 < avg1 * 0.95) return '↓';
    return '→';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textDark;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Weekly Report'),
        backgroundColor: AppColors.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : RefreshIndicator(
              onRefresh: _fetchWeeklyData,
              color: AppColors.primaryPurple,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  Row(children: [
                    _summaryCard('Steps', '$_totalSteps', '~${_avgSteps.round()}/day ${_trend(_weekData.map((d) => d.steps.toDouble()).toList())}', Icons.directions_walk),
                    const SizedBox(width: 8),
                    _summaryCard('Distance', '${_totalDist.toStringAsFixed(1)} km', '~${_avgDist.toStringAsFixed(1)}/day ${_trend(_weekData.map((d) => d.distanceKm).toList())}', Icons.map),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _summaryCard('Calories', '${_totalCal.toStringAsFixed(0)}', '~${_avgCal.toStringAsFixed(0)}/day ${_trend(_weekData.map((d) => d.calories).toList())}', Icons.local_fire_department),
                    const SizedBox(width: 8),
                    _summaryCard('Active', '$_totalActive min', '~${_avgActive.round()} min/day ${_trend(_weekData.map((d) => d.activeMinutes.toDouble()).toList())}', Icons.timer),
                  ]),
                  const SizedBox(height: 24),

                  // Steps → Bar Chart
                  _chartCard(
                    title: 'Steps',
                    accent: AppColors.primaryPurple,
                    insight: 'Avg ${_avgSteps.round()}/day · Max ${_maxSteps()}',
                    child: _buildStepsBarChart(),
                  ),
                  const SizedBox(height: 16),

                  // Calories → Line Chart
                  _chartCard(
                    title: 'Calories (kcal)',
                    accent: Colors.orange,
                    insight: 'Avg ${_avgCal.toStringAsFixed(0)}/day · Max ${_maxCal().toStringAsFixed(0)}',
                    child: _buildCaloriesLineChart(),
                  ),
                  const SizedBox(height: 16),

                  // Distance → Area Chart
                  _chartCard(
                    title: 'Distance (km)',
                    accent: Colors.blue,
                    insight: 'Avg ${_avgDist.toStringAsFixed(1)}/day · Max ${_maxDist().toStringAsFixed(1)}',
                    child: _buildDistanceAreaChart(),
                  ),
                  const SizedBox(height: 16),

                  // Active Minutes → Combo Chart (bars + line)
                  _chartCard(
                    title: 'Active Minutes',
                    accent: Colors.green,
                    insight: 'Avg ${_avgActive.round()} min/day · Max ${_maxActive()}',
                    child: _buildActiveComboChart(),
                  ),
                  const SizedBox(height: 24),

                  // Daily breakdown
                  Text('Daily Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 12),
                  ..._weekData.reversed.map((d) => _dailyRow(d)),
                ],
              ),
            ),
    );
  }

  Widget _summaryCard(String label, String value, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPurple.withOpacity(0.12), AppColors.primaryPurple.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryPurple.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(
              color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: TextStyle(color: AppColors.textDark.withOpacity(0.6), fontSize: 11)),
            Text(subtitle, style: TextStyle(color: AppColors.primaryPurple.withOpacity(0.6), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _chartCard({required String title, required Color accent, required String insight, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.08), accent.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: accent)),
            const Spacer(),
            Text(insight, style: TextStyle(fontSize: 10, color: accent.withOpacity(0.7))),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 180, child: child),
        ],
      ),
    );
  }

  Widget _dailyRow(DailyHealthData d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 70,
              child: Text('${d.dayLabel} ${d.dateLabel}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textDark)),
            ),
            _miniStat('${d.steps}', Icons.directions_walk),
            _miniStat('${d.distanceKm.toStringAsFixed(1)}km', Icons.map),
            _miniStat('${d.calories.toStringAsFixed(0)}', Icons.local_fire_department),
            _miniStat('${d.activeMinutes}m', Icons.timer),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primaryPurple),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── CHART BUILDERS ──────────────────────────────────────────────────────

  List<String> get _dayLabels => _weekData.map((d) => d.dayLabel).toList();

  /// Steps → Bar Chart
  Widget _buildStepsBarChart() {
    if (_weekData.isEmpty) return const SizedBox.shrink();
    final maxY = (_maxSteps() * 1.2).toDouble().clamp(1.0, double.infinity);
    return BarChart(
      BarChartData(
        maxY: maxY as double,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.round()} steps',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= _dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dayLabels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.round().toString(), style: TextStyle(fontSize: 9, color: Colors.grey[400])),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 0.5),
        ),
        barGroups: _weekData.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(
            toY: e.value.steps.toDouble(),
            width: 18,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.primaryPurple.withOpacity(0.6), AppColors.primaryPurple],
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY as double,
              color: AppColors.primaryPurple.withOpacity(0.08),
            ),
          )],
        )).toList(),
      ),
    );
  }

  /// Calories → Line Chart
  Widget _buildCaloriesLineChart() {
    if (_weekData.isEmpty) return const SizedBox.shrink();
    final spots = _weekData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.calories)).toList();
    final maxY = (_maxCal() * 1.2).clamp(1.0, double.infinity);
    return LineChart(
      LineChartData(
        maxY: maxY as double,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(0)} kcal',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            )).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= _dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dayLabels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.round().toString(), style: TextStyle(fontSize: 9, color: Colors.grey[400])),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 0.5),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: Colors.orange,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: Colors.orange,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange.withOpacity(0.25), Colors.orange.withOpacity(0.02)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Distance → Area Chart
  Widget _buildDistanceAreaChart() {
    if (_weekData.isEmpty) return const SizedBox.shrink();
    final spots = _weekData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.distanceKm)).toList();
    final maxY = (_maxDist() * 1.3).clamp(0.1, double.infinity);
    return LineChart(
      LineChartData(
        maxY: maxY as double,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
              '${s.y.toStringAsFixed(1)} km',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            )).toList(),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= _dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dayLabels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: TextStyle(fontSize: 9, color: Colors.grey[400])),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 0.5),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: true,
            color: Colors.blue,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3.5,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.withOpacity(0.35), Colors.blue.withOpacity(0.03)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Active Minutes → Combo Chart (bars + trend line)
  Widget _buildActiveComboChart() {
    if (_weekData.isEmpty) return const SizedBox.shrink();
    final maxY = (_maxActive() * 1.3).toDouble().clamp(1.0, double.infinity);
    return BarChart(
      BarChartData(
        maxY: maxY as double,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, _, rod, __) => BarTooltipItem(
              '${rod.toY.round()} min',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= _dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_dayLabels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (v, _) => Text(v.round().toString(), style: TextStyle(fontSize: 9, color: Colors.grey[400])),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey[200]!, strokeWidth: 0.5),
        ),
        barGroups: _weekData.asMap().entries.map((e) => BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(
            toY: e.value.activeMinutes.toDouble(),
            width: 14,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.green.withOpacity(0.5), Colors.green],
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY as double,
              color: Colors.green.withOpacity(0.06),
            ),
          )],
        )).toList(),
        // Average reference line
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: _avgActive,
              color: Colors.orange.withOpacity(0.6),
              strokeWidth: 2,
              dashArray: [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(bottom: 4),
                style: TextStyle(fontSize: 9, color: Colors.orange.withOpacity(0.8), fontWeight: FontWeight.bold),
                resolutionResolver: (_, __) => 'Avg ${_avgActive.round()}m',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
