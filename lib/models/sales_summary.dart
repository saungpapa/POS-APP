class SalesSummary {
  final double totalSales;
  final int transactionCount;
  final int totalItems;
  final DateTime startDate;
  final DateTime endDate;
  final List<TopProduct> topProducts;
  final Map<String, double> dailySales;

  SalesSummary({
    required this.totalSales,
    required this.transactionCount,
    required this.totalItems,
    required this.startDate,
    required this.endDate,
    required this.topProducts,
    required this.dailySales,
  });
}

class TopProduct {
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  TopProduct({
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });
}
