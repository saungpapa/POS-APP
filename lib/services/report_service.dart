import 'package:pos_app/models/sales_summary.dart';
import 'package:pos_app/services/database_service.dart';

class ReportService {
  final DatabaseService _databaseService;

  ReportService(this._databaseService);

  Future<SalesSummary> generateSalesReport(DateTime startDate, DateTime endDate) async {
    final stats = await _databaseService.getSalesStats(startDate, endDate);
    
    // Parse top products
    final topProductsList = (stats['top_products'] as List<Map<String, dynamic>>)
        .map((p) => TopProduct(
              productName: p['product_name'] as String,
              quantitySold: p['quantity_sold'] as int,
              totalRevenue: (p['total_revenue'] as num).toDouble(),
            ))
        .toList();

    // Parse daily sales
    final dailySalesMap = <String, double>{};
    for (var row in stats['daily_sales'] as List<Map<String, dynamic>>) {
      final date = row['date'] as String;
      final amount = (row['amount'] as num).toDouble();
      dailySalesMap[date] = amount;
    }

    return SalesSummary(
      totalSales: (stats['total_sales'] as num).toDouble(),
      transactionCount: stats['transaction_count'] as int,
      totalItems: stats['total_items'] as int,
      startDate: startDate,
      endDate: endDate,
      topProducts: topProductsList,
      dailySales: dailySalesMap,
    );
  }

  DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime getTodayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  DateTime getWeekStart() {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day - (weekday - 1));
  }

  DateTime getMonthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime getMonthEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }
}
