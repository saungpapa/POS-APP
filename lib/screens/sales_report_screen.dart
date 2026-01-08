import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/models/sales_summary.dart';
import 'package:pos_app/services/database_service.dart';
import 'package:pos_app/services/report_service.dart';
import 'package:pos_app/services/pdf_service.dart';
import 'package:pos_app/widgets/sales_chart.dart';
import 'package:pos_app/widgets/top_products_list.dart';
import 'package:pos_app/widgets/report_summary_card.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  SalesSummary? _summary;
  bool _isLoading = true;
  String _selectedPeriod = 'today';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    final db = context.read<DatabaseService>();
    final reportService = ReportService(db);

    DateTime startDate;
    DateTime endDate;

    switch (_selectedPeriod) {
      case 'today':
        startDate = reportService.getToday();
        endDate = reportService.getTodayEnd();
        break;
      case 'week':
        startDate = reportService.getWeekStart();
        endDate = reportService.getTodayEnd();
        break;
      case 'month':
        startDate = reportService.getMonthStart();
        endDate = reportService.getMonthEnd();
        break;
      case 'custom':
        if (_customStartDate == null || _customEndDate == null) {
          setState(() => _isLoading = false);
          return;
        }
        startDate = _customStartDate!;
        endDate = _customEndDate!;
        break;
      default:
        startDate = reportService.getToday();
        endDate = reportService.getTodayEnd();
    }

    final summary = await reportService.generateSalesReport(startDate, endDate);

    setState(() {
      _summary = summary;
      _isLoading = false;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: _customStartDate ?? now.subtract(const Duration(days: 7)),
        end: _customEndDate ?? now,
      ),
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
        _selectedPeriod = 'custom';
      });
      _loadReport();
    }
  }

  Future<void> _exportPdf() async {
    if (_summary == null) return;

    try {
      final pdfService = PdfService();
      await pdfService.shareSalesReportPdf(_summary!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF ထုတ်ပြီးပါပြီ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('အမှား: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 အရောင်းစာရင်း'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
          if (_summary != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportPdf,
            ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Row(
              children: [
                _buildPeriodChip('ယနေ့', 'today'),
                const SizedBox(width: 8),
                _buildPeriodChip('ဒီအပတ်', 'week'),
                const SizedBox(width: 8),
                _buildPeriodChip('ဒီလ', 'month'),
                const SizedBox(width: 8),
                _buildCustomChip(),
              ],
            ),
          ),

          if (_summary != null && _selectedPeriod == 'custom')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${dateFormat.format(_summary!.startDate)} - ${dateFormat.format(_summary!.endDate)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _summary == null
                    ? const Center(child: Text('စာရင်းမရှိပါ'))
                    : RefreshIndicator(
                        onRefresh: _loadReport,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Summary cards
                              ReportSummaryCard(summary: _summary!),
                              const SizedBox(height: 24),

                              // Chart
                              const Text(
                                'အရောင်းဂရပ်',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SalesChart(dailySales: _summary!.dailySales),
                              const SizedBox(height: 24),

                              // Top products
                              const Text(
                                '🏆 အရောင်းရဆုံး ပစ္စည်းများ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TopProductsList(topProducts: _summary!.topProducts),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = value);
          _loadReport();
        }
      },
    );
  }

  Widget _buildCustomChip() {
    final isSelected = _selectedPeriod == 'custom';
    return ChoiceChip(
      label: const Text('Custom'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _selectCustomDateRange();
        }
      },
    );
  }
}
