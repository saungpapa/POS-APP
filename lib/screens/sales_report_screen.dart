import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sales_summary.dart';
import '../services/report_service.dart';
import '../services/pdf_service.dart';
import '../widgets/sales_chart.dart';
import '../widgets/top_products_list.dart';
import '../widgets/report_summary_card.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  final ReportService _reportService = ReportService.instance;
  final PdfService _pdfService = PdfService.instance;

  ReportPeriod _selectedPeriod = ReportPeriod.today;
  SalesSummary? _summary;
  bool _isLoading = false;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _showRevenueChart = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateRange = _reportService.getDateRange(
        _selectedPeriod,
        customStart: _customStartDate,
        customEnd: _customEndDate,
      );

      final summary = await _reportService.getSalesSummary(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );

      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('အမှား: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedPeriod = ReportPeriod.custom;
      });
      _loadReport();
    }
  }

  Future<void> _exportPdf() async {
    if (_summary == null) return;

    try {
      final pdf = await _pdfService.generateReportPdf(_summary!);
      await _pdfService.printPdf(pdf);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF ဖန်တီးပြီးပါပြီ'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF မဖန်တီးနိုင်ပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_summary == null) return;

    try {
      final pdf = await _pdfService.generateReportPdf(_summary!);
      await _pdfService.sharePdf(
        pdf,
        'sales_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('မျှဝေ၍ မရပါ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 အရောင်းစာရင်း'),
        actions: [
          if (_summary != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'export') {
                  _exportPdf();
                } else if (value == 'share') {
                  _sharePdf();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('PDF Export'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('မျှဝေမည်'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PeriodButton(
                        label: 'ယနေ့',
                        isSelected: _selectedPeriod == ReportPeriod.today,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ReportPeriod.today;
                          });
                          _loadReport();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PeriodButton(
                        label: 'ဒီအပတ်',
                        isSelected: _selectedPeriod == ReportPeriod.thisWeek,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ReportPeriod.thisWeek;
                          });
                          _loadReport();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PeriodButton(
                        label: 'ဒီလ',
                        isSelected: _selectedPeriod == ReportPeriod.thisMonth,
                        onTap: () {
                          setState(() {
                            _selectedPeriod = ReportPeriod.thisMonth;
                          });
                          _loadReport();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PeriodButton(
                        label: 'Custom',
                        isSelected: _selectedPeriod == ReportPeriod.custom,
                        onTap: _selectCustomDateRange,
                      ),
                    ),
                  ],
                ),
                if (_selectedPeriod == ReportPeriod.custom &&
                    _customStartDate != null &&
                    _customEndDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${DateFormat('dd/MM/yyyy').format(_customStartDate!)} - ${DateFormat('dd/MM/yyyy').format(_customEndDate!)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _summary == null
                    ? const Center(child: Text('ဒေတာ မတွေ့ပါ'))
                    : RefreshIndicator(
                        onRefresh: _loadReport,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              // Summary cards
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ReportSummaryCard(
                                        title: 'စုစုပေါင်း',
                                        value: '${numberFormat.format(_summary!.totalRevenue)} ကျပ်',
                                        icon: Icons.attach_money,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ReportSummaryCard(
                                        title: 'အရောင်း',
                                        value: '${_summary!.totalSalesCount} ကြိမ်',
                                        icon: Icons.receipt_long,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: ReportSummaryCard(
                                  title: 'ပစ္စည်း',
                                  value: '${_summary!.totalItemsSold} ခု',
                                  icon: Icons.inventory_2,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Chart section
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '📈 အရောင်းဂရပ်',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SegmentedButton<bool>(
                                      segments: const [
                                        ButtonSegment(
                                          value: true,
                                          label: Text('ငွေ'),
                                        ),
                                        ButtonSegment(
                                          value: false,
                                          label: Text('အရေအတွက်'),
                                        ),
                                      ],
                                      selected: {_showRevenueChart},
                                      onSelectionChanged: (Set<bool> newSelection) {
                                        setState(() {
                                          _showRevenueChart = newSelection.first;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              SalesChart(
                                dailySales: _summary!.dailySales,
                                showRevenue: _showRevenueChart,
                              ),
                              const SizedBox(height: 24),

                              // Top products
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '🏆 အရောင်းရဆုံး ပစ္စည်းများ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              TopProductsList(products: _summary!.topProducts),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
