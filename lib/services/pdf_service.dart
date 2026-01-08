import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:pos_app/models/sales_summary.dart';
import 'package:intl/intl.dart';

class PdfService {
  Future<void> shareReceiptPdf(Receipt receipt) async {
    final pdf = await _generateReceiptPdf(receipt);
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${receipt.receiptNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'ဘောက်ချာ ${receipt.receiptNumber}',
    );
  }

  Future<void> printReceiptPdf(Receipt receipt) async {
    final pdf = await _generateReceiptPdf(receipt);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<pw.Document> _generateReceiptPdf(Receipt receipt) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
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
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Date and receipt number
              pw.Center(
                child: pw.Text('ရက်စွဲ: ${dateFormat.format(receipt.dateTime)}'),
              ),
              pw.Center(
                child: pw.Text('ဘောက်ချာ: ${receipt.receiptNumber}'),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              
              // Items header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(flex: 5, child: pw.Text('ပစ္စည်း')),
                  pw.Expanded(flex: 2, child: pw.Text('အရေအတွက်', textAlign: pw.TextAlign.center)),
                  pw.Expanded(flex: 3, child: pw.Text('ဈေး', textAlign: pw.TextAlign.right)),
                ],
              ),
              pw.Divider(),
              
              // Items
              ...receipt.items.map((item) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(flex: 5, child: pw.Text(item.productName)),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        item.quantity.toString(),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        numberFormat.format(item.totalPrice),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
              
              pw.Divider(),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('စုစုပေါင်း', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    '${numberFormat.format(receipt.totalAmount)} ကျပ်',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'ကျေးဇူးတင်ပါသည်',
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

  Future<void> shareSalesReportPdf(SalesSummary summary) async {
    final pdf = await _generateSalesReportPdf(summary);
    
    final output = await getTemporaryDirectory();
    final dateFormat = DateFormat('yyyyMMdd');
    final fileName = 'sales_report_${dateFormat.format(summary.startDate)}_${dateFormat.format(summary.endDate)}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'အရောင်းစာရင်း',
    );
  }

  Future<pw.Document> _generateSalesReportPdf(SalesSummary summary) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numberFormat = NumberFormat('#,###');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Title
              pw.Center(
                child: pw.Text(
                  'အရောင်းစာရင်း',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              
              // Date range
              pw.Center(
                child: pw.Text(
                  '${dateFormat.format(summary.startDate)} - ${dateFormat.format(summary.endDate)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Summary cards
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('စုစုပေါင်း', '${numberFormat.format(summary.totalSales)} ကျပ်'),
                  _buildSummaryCard('အရောင်း', '${summary.transactionCount} ကြိမ်'),
                  _buildSummaryCard('ပစ္စည်း', '${summary.totalItems} ခု'),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Top products
              pw.Text(
                'အရောင်းရဆုံး ပစ္စည်းများ',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('အမည်', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('အရေအတွက်', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('ရငွေ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...summary.topProducts.map((product) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(product.productName),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(product.quantitySold.toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(numberFormat.format(product.totalRevenue)),
                      ),
                    ],
                  )),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _buildSummaryCard(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
