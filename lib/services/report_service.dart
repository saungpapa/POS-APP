import '../models/sales_summary.dart';
import '../models/sale.dart';
import '../models/sale_item.dart';
import '../models/product.dart';
import 'database_service.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  custom,
}

class ReportService {
  static final ReportService instance = ReportService._init();
  ReportService._init();

  /// Get sales summary for a specific period
  Future<SalesSummary> getSalesSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await DatabaseService.instance.database;

    // Get all sales in the date range
    final salesMaps = await db.query(
      'sales',
      where: 'sale_date >= ? AND sale_date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'sale_date ASC',
    );

    final sales = salesMaps.map((map) => Sale.fromMap(map)).toList();

    // Calculate total revenue and sales count
    double totalRevenue = 0;
    int totalItemsSold = 0;

    for (var sale in sales) {
      totalRevenue += sale.totalAmount;
      final items = await DatabaseService.instance.getSaleItems(sale.id!);
      totalItemsSold += items.fold(0, (sum, item) => sum + item.quantity);
    }

    // Get top products
    final topProducts = await _getTopProducts(startDate, endDate);

    // Get daily sales
    final dailySales = await _getDailySales(startDate, endDate);

    return SalesSummary(
      totalRevenue: totalRevenue,
      totalSalesCount: sales.length,
      totalItemsSold: totalItemsSold,
      topProducts: topProducts,
      dailySales: dailySales,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Get top selling products
  Future<List<TopProduct>> _getTopProducts(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DatabaseService.instance.database;

    final result = await db.rawQuery('''
      SELECT 
        p.id,
        p.name,
        SUM(si.quantity) as total_quantity,
        SUM(si.quantity * si.unit_price) as total_revenue
      FROM sale_items si
      JOIN products p ON si.product_id = p.id
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date >= ? AND s.sale_date <= ?
      GROUP BY p.id, p.name
      ORDER BY total_quantity DESC
      LIMIT 10
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result.map((row) {
      return TopProduct(
        productId: row['id'] as int,
        productName: row['name'] as String,
        quantitySold: row['total_quantity'] as int,
        totalRevenue: row['total_revenue'] as double,
      );
    }).toList();
  }

  /// Get daily sales breakdown
  Future<List<DailySales>> _getDailySales(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await DatabaseService.instance.database;

    // Get all sales in range
    final salesMaps = await db.query(
      'sales',
      where: 'sale_date >= ? AND sale_date <= ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'sale_date ASC',
    );

    final sales = salesMaps.map((map) => Sale.fromMap(map)).toList();

    // Group by date
    final Map<String, DailySales> dailyMap = {};

    for (var sale in sales) {
      final dateKey = DateTime(
        sale.saleDate.year,
        sale.saleDate.month,
        sale.saleDate.day,
      ).toIso8601String();

      if (dailyMap.containsKey(dateKey)) {
        final existing = dailyMap[dateKey]!;
        dailyMap[dateKey] = DailySales(
          date: existing.date,
          revenue: existing.revenue + sale.totalAmount,
          salesCount: existing.salesCount + 1,
        );
      } else {
        dailyMap[dateKey] = DailySales(
          date: DateTime(
            sale.saleDate.year,
            sale.saleDate.month,
            sale.saleDate.day,
          ),
          revenue: sale.totalAmount,
          salesCount: 1,
        );
      }
    }

    // Fill in missing dates with zero values
    final List<DailySales> result = [];
    DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final dateKey = current.toIso8601String();
      if (dailyMap.containsKey(dateKey)) {
        result.add(dailyMap[dateKey]!);
      } else {
        result.add(DailySales(
          date: current,
          revenue: 0,
          salesCount: 0,
        ));
      }
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  /// Get date range for a specific period
  DateRange getDateRange(ReportPeriod period, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (period) {
      case ReportPeriod.today:
        return DateRange(
          start: today,
          end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
        );

      case ReportPeriod.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
        return DateRange(start: weekStart, end: weekEnd);

      case ReportPeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        return DateRange(start: monthStart, end: monthEnd);

      case ReportPeriod.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError('Custom period requires start and end dates');
        }
        return DateRange(start: customStart, end: customEnd);
    }
  }
}

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}
