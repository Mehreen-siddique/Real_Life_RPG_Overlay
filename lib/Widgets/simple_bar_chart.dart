import 'package:flutter/material.dart';
import 'package:real_life_rpg/Models/daily_health_data.dart';

class SimpleBarChart extends StatefulWidget {
  final List<DailyHealthData> data;
  final double Function(DailyHealthData) valueExtractor;
  final String Function(double) formatValue;
  final Color barColor;
  final String title;

  const SimpleBarChart({
    Key? key,
    required this.data,
    required this.valueExtractor,
    required this.formatValue,
    this.barColor = const Color(0xFF7C4DFF),
    this.title = '',
  }) : super(key: key);

  @override
  State<SimpleBarChart> createState() => _SimpleBarChartState();
}

class _SimpleBarChartState extends State<SimpleBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SimpleBarChart old) {
    super.didUpdateWidget(old);
    if (old.data != widget.data) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        SizedBox(
          height: 140,
          child: LayoutBuilder(builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => CustomPaint(
                size: constraints.biggest,
                painter: _BarPainter(
                  data: widget.data,
                  valueExtractor: widget.valueExtractor,
                  barColor: widget.barColor,
                  progress: _animation.value,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<DailyHealthData> data;
  final double Function(DailyHealthData) valueExtractor;
  final Color barColor;
  final double progress;

  _BarPainter({
    required this.data,
    required this.valueExtractor,
    required this.barColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barAreaTop = 8.0;
    final barAreaBottom = size.height - 22.0;
    final labelY = size.height - 8.0;
    final barHeight = barAreaBottom - barAreaTop;

    double maxVal = 0;
    for (final d in data) {
      final v = valueExtractor(d);
      if (v > maxVal) maxVal = v;
    }
    if (maxVal == 0) maxVal = 1;

    final barCount = data.length;
    final groupWidth = size.width / barCount;
    final barWidth = groupWidth * 0.5;
    final barRadius = Radius.circular(barWidth / 4);

    final paint = Paint()..color = barColor;
    final lightPaint = Paint()..color = barColor.withOpacity(0.15);

    for (int i = 0; i < barCount; i++) {
      final value = valueExtractor(data[i]);
      final ratio = value / maxVal;
      final barH = ratio * barHeight * progress;

      final cx = groupWidth * i + groupWidth / 2;
      final left = cx - barWidth / 2;
      final right = cx + barWidth / 2;
      final top = barAreaBottom - barH;

      // Background bar
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(left, barAreaTop, right, barAreaBottom),
          topLeft: barRadius, topRight: barRadius,
        ),
        lightPaint,
      );

      // Value bar with animation
      if (barH > 0) {
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(left, top, right, barAreaBottom),
            topLeft: barRadius, topRight: barRadius,
          ),
          paint,
        );
      }

      // Day label only
      final dayTp = TextPainter(
        text: TextSpan(text: data[i].dayLabel, style: TextStyle(
          color: Colors.grey[500], fontSize: 10,
        )),
        textDirection: TextDirection.ltr,
      )..layout();
      dayTp.paint(canvas, Offset(cx - dayTp.width / 2, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.progress != progress || old.data != data;
}
