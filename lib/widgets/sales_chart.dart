import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/sales_summary.dart';

class SalesChart extends StatelessWidget {
  final List<DailySales> dailySales;
  final bool showRevenue;

  const SalesChart({
    super.key,
    required this.dailySales,
    this.showRevenue = true,
  });

  @override
  Widget build(BuildContext context) {
    if (dailySales.isEmpty) {
      return const Center(
        child: Text('ရောင်းချမှု မရှိသေးပါ'),
      );
    }

    final maxValue = showRevenue
        ? dailySales.map((e) => e.revenue).reduce((a, b) => a > b ? a : b)
        : dailySales.map((e) => e.salesCount.toDouble()).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final sales = dailySales[groupIndex];
                final value = showRevenue
                    ? NumberFormat('#,###').format(sales.revenue)
                    : sales.salesCount.toString();
                return BarTooltipItem(
                  '${sales.formattedDate}\n$value',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= dailySales.length) {
                    return const Text('');
                  }
                  final sales = dailySales[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      sales.formattedDate,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (showRevenue) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  } else {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),
          barGroups: dailySales.asMap().entries.map((entry) {
            final index = entry.key;
            final sales = entry.value;
            final value = showRevenue ? sales.revenue : sales.salesCount.toDouble();

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: Colors.blue,
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }
}
