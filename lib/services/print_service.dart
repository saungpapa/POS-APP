import 'package:flutter/services.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/receipt.dart';
import 'package:intl/intl.dart';

class PrintService {
  static final PrintService instance = PrintService._init();
  PrintService._init();

  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  PrinterBluetooth? _selectedPrinter;

  PrinterBluetooth? get selectedPrinter => _selectedPrinter;

  /// Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      return true;
    }
    return false;
  }

  /// Scan for available Bluetooth printers
  Stream<List<PrinterBluetooth>> scanPrinters() {
    return _printerManager.scanResults;
  }

  /// Start scanning for printers
  Future<void> startScan() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Bluetooth permissions not granted');
    }
    await _printerManager.startScan(const Duration(seconds: 4));
  }

  /// Stop scanning
  void stopScan() {
    _printerManager.stopScan();
  }

  /// Select a printer for printing
  void selectPrinter(PrinterBluetooth printer) {
    _selectedPrinter = printer;
  }

  /// Print receipt to selected Bluetooth printer
  Future<bool> printReceipt(Receipt receipt) async {
    if (_selectedPrinter == null) {
      throw Exception('No printer selected');
    }

    try {
      // Generate ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Header - Shop name (centered, bold)
      bytes += generator.text(
        receipt.shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      bytes += generator.emptyLines(1);

      // Receipt number
      bytes += generator.text(
        'ဘောက်ချာ #${receipt.receiptNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Date and time
      bytes += generator.text(
        '${receipt.formattedDate} ${receipt.formattedTime}',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.hr();

      // Items header
      bytes += generator.row([
        PosColumn(
          text: 'ပစ္စည်း',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'အရေအတွက်',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.center),
        ),
        PosColumn(
          text: 'ဈေး',
          width: 3,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);
      bytes += generator.hr();

      // Items
      final numberFormat = NumberFormat('#,###');
      for (var item in receipt.items) {
        bytes += generator.row([
          PosColumn(
            text: item.product.name,
            width: 6,
          ),
          PosColumn(
            text: '${item.quantity}',
            width: 3,
            styles: const PosStyles(align: PosAlign.center),
          ),
          PosColumn(
            text: numberFormat.format(item.totalPrice),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
      }

      bytes += generator.hr();

      // Total
      bytes += generator.row([
        PosColumn(
          text: 'စုစုပေါင်း:',
          width: 9,
          styles: const PosStyles(
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text: '${numberFormat.format(receipt.sale.totalAmount)} ကျပ်',
          width: 3,
          styles: const PosStyles(
            bold: true,
            align: PosAlign.right,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        ),
      ]);

      bytes += generator.emptyLines(1);
      bytes += generator.text(
        'ကျေးဇူးတင်ပါတယ်!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.emptyLines(2);
      bytes += generator.cut();

      // Print to Bluetooth printer
      await _printerManager.printTicket(bytes, _selectedPrinter!);
      return true;
    } catch (e) {
      throw Exception('Print failed: $e');
    }
  }

  /// Check if printer is connected
  bool get isConnected => _selectedPrinter != null;

  /// Disconnect from printer
  void disconnect() {
    _selectedPrinter = null;
  }
}
