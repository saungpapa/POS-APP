import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../models/sales_summary.dart';

class PdfService {
  static final PdfService instance = PdfService._init();
  PdfService._init();

  /// Generate PDF for receipt
  Future<pw.Document> generateReceiptPdf(Receipt receipt) async {
    final pdf = pw.Document();
    final numberFormat = NumberFormat('#,###');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Shop name
              pw.Center(
                child: pw.Text(
                  receipt.shopName,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // Receipt number
              pw.Center(
                child: pw.Text('ဘောက်ချာ #${receipt.receiptNumber}'),
              ),

              // Date and time
              pw.Center(
                child: pw.Text(
                  '${receipt.formattedDate} ${receipt.formattedTime}',
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),

              // Items header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('ပစ္စည်း', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('အရေအတွက်', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('ဈေး', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                  ),
                ],
              ),
              pw.Divider(),

              // Items
              ...receipt.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(item.product.name),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          numberFormat.format(item.totalPrice),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(),
              pw.SizedBox(height: 10),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'စုစုပေါင်း:',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${numberFormat.format(receipt.sale.totalAmount)} ကျပ်',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Thank you message
              pw.Center(
                child: pw.Text(
                  'ကျေးဇူးတင်ပါတယ်!',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Generate PDF for sales report
  Future<pw.Document> generateReportPdf(SalesSummary summary) async {
    final pdf = pw.Document();
    final numberFormat = NumberFormat('#,###');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Text(
                'အရောင်းစာရင်း',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Date range
              pw.Text(
                'ရက်စွဲ: ${DateFormat('dd/MM/yyyy').format(summary.startDate)} - ${DateFormat('dd/MM/yyyy').format(summary.endDate)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // Summary statistics
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('စုစုပေါင်း အချက်အလက်များ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    _buildSummaryRow('စုစုပေါင်း အရောင်းငွေ:', '${numberFormat.format(summary.totalRevenue)} ကျပ်'),
                    _buildSummaryRow('အရောင်းအကြိမ်ရေ:', '${summary.totalSalesCount} ကြိမ်'),
                    _buildSummaryRow('ပစ္စည်းအရေအတွက်:', '${summary.totalItemsSold} ခု'),
                    _buildSummaryRow('ပျမ်းမျှ အရောင်းငွေ:', '${numberFormat.format(summary.averageSaleAmount)} ကျပ်'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Top products
              pw.Text(
                'အရောင်းရဆုံး ပစ္စည်းများ (Top 10)',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      _buildTableCell('အမည်', isHeader: true),
                      _buildTableCell('အရေအတွက်', isHeader: true),
                      _buildTableCell('ဈေး', isHeader: true),
                    ],
                  ),
                  // Data
                  ...summary.topProducts.take(10).map((product) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(product.productName),
                        _buildTableCell('${product.quantitySold} ခု'),
                        _buildTableCell('${numberFormat.format(product.totalRevenue)} ကျပ်'),
                      ],
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Save PDF to file
  Future<File> savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await path_provider.getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Print PDF using system print dialog
  Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Share PDF
  Future<void> sharePdf(pw.Document pdf, String fileName) async {
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: fileName,
    );
  }
}
