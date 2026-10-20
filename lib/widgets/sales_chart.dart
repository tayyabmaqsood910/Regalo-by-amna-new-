import 'package:flutter/material.dart';
import 'package:regalo_by_amna/models/invoice.dart';
import 'package:regalo_by_amna/models/payment_status.dart';
import 'package:regalo_by_amna/theme/app_colors.dart';
import 'package:regalo_by_amna/widgets/app_card.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key, required this.bills});

  final List<Invoice> bills;

  @override
  Widget build(BuildContext context) {
    final ordered = List<Invoice>.of(bills)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final shown = ordered.length <= 8
        ? ordered
        : ordered.sublist(ordered.length - 8);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sales', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _LegendDot(color: AppColors.sageDeep, label: 'Paid'),
              _LegendDot(color: AppColors.blushDeep, label: 'Partial'),
              _LegendDot(color: Color(0xFF6B2A3A), label: 'Unpaid'),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            key: const Key('dashboard-sales-chart'),
            height: 160,
            width: double.infinity,
            child: shown.isEmpty
                ? const Center(child: Text('No sales to chart yet'))
                : CustomPaint(
                    painter: _SalesChartPainter(shown),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox(width: 8, height: 8),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SalesChartPainter extends CustomPainter {
  _SalesChartPainter(this.bills);

  final List<Invoice> bills;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 42.0;
    const right = 12.0;
    const top = 16.0;
    const bottom = 32.0;
    final plot = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) {
      return;
    }

    final peak = bills.fold<double>(0, (max, bill) {
      return bill.grandTotal > max ? bill.grandTotal : max;
    });
    final ceiling = _ceiling(peak);

    final grid = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var step = 0; step <= 4; step++) {
      final t = step / 4;
      final y = plot.bottom - (plot.height * t);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _label(
        canvas,
        _compact(ceiling * t),
        Offset(0, y - 7),
        width: left - 6,
        align: TextAlign.right,
        color: AppColors.muted,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < bills.length; i++) {
      final x = bills.length == 1
          ? plot.center.dx
          : plot.left + (plot.width * i / (bills.length - 1));
      final y = plot.bottom - (plot.height * (bills[i].grandTotal / ceiling));
      points.add(Offset(x, y));
    }

    final area = Path()..moveTo(points.first.dx, plot.bottom);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(points.last.dx, plot.bottom)
      ..close();
    canvas.drawPath(
      area,
      Paint()..color = AppColors.sageLight.withValues(alpha: 0.9),
    );

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < points.length; i++) {
      final color = switch (bills[i].paymentStatus) {
        PaymentStatus.paid => AppColors.sageDeep,
        PaymentStatus.partial => AppColors.blushDeep,
        PaymentStatus.unpaid => const Color(0xFF6B2A3A),
      };
      canvas.drawCircle(points[i], 6, Paint()..color = Colors.white);
      canvas.drawCircle(points[i], 4.5, Paint()..color = color);
      final number = bills[i].number.replaceFirst(RegExp(r'^[A-Za-z]+-'), '');
      _label(
        canvas,
        number,
        Offset(points[i].dx - 28, plot.bottom + 8),
        width: 56,
        align: TextAlign.center,
        color: AppColors.ink,
      );
    }
  }

  double _ceiling(double peak) {
    if (peak <= 0) {
      return 1;
    }
    final magnitude = _pow10(peak);
    final step = magnitude / 2;
    return (peak / step).ceil() * step;
  }

  double _pow10(double value) {
    var magnitude = 1.0;
    while (magnitude * 10 <= value) {
      magnitude *= 10;
    }
    return magnitude;
  }

  String _compact(double value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      final text = thousands == thousands.roundToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${text}k';
    }
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  void _label(
    Canvas canvas,
    String text,
    Offset offset, {
    required double width,
    required TextAlign align,
    required Color color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11, height: 1),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
    painter.dispose();
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) {
    return oldDelegate.bills != bills;
  }
}
