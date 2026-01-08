class SalesSummary {
  final double totalRevenue;
  final int totalSalesCount;
  final int totalItemsSold;
  final List<TopProduct> topProducts;
  final List<DailySales> dailySales;
  final DateTime startDate;
  final DateTime endDate;

  SalesSummary({
    required this.totalRevenue,
    required this.totalSalesCount,
    required this.totalItemsSold,
    required this.topProducts,
    required this.dailySales,
    required this.startDate,
    required this.endDate,
  });

  double get averageSaleAmount {
    if (totalSalesCount == 0) return 0;
    return totalRevenue / totalSalesCount;
  }
}

class TopProduct {
  final int productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}

class DailySales {
  final DateTime date;
  final double revenue;
  final int salesCount;

  DailySales({
    required this.date,
    required this.revenue,
    required this.salesCount,
  });

  String get formattedDate {
    return '${date.day}/${date.month}';
  }
}
