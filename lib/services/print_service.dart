import 'dart:typed_data';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:intl/intl.dart';

class PrintService {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<PrinterBluetooth>> scanDevices() async {
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('ခွင့်ပြုချက်များ လိုအပ်ပါသည်');
    }

    final devices = <PrinterBluetooth>[];
    
    _printerManager.scanResults.listen((printers) {
      devices.addAll(printers);
    });

    await _printerManager.startScan(timeout: const Duration(seconds: 4));
    
    return devices;
  }

  Future<bool> printReceipt(Receipt receipt, PrinterBluetooth printer) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Shop name (centered, bold)
      bytes += generator.text(
        receipt.shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );

      bytes += generator.feed(1);

      // Date and time
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
      bytes += generator.text(
        'ရက်စွဲ: ${dateFormat.format(receipt.dateTime)}',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Receipt number
      bytes += generator.text(
        'ဘောက်ချာ: ${receipt.receiptNumber}',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.hr();

      // Column headers
      bytes += generator.row([
        PosColumn(text: 'ပစ္စည်း', width: 6),
        PosColumn(text: 'အရေအတွက်', width: 3, styles: const PosStyles(align: PosAlign.center)),
        PosColumn(text: 'ဈေး', width: 3, styles: const PosStyles(align: PosAlign.right)),
      ]);

      bytes += generator.hr();

      // Items
      final numberFormat = NumberFormat('#,###');
      for (var item in receipt.items) {
        bytes += generator.row([
          PosColumn(text: item.productName, width: 6),
          PosColumn(
            text: item.quantity.toString(),
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
        PosColumn(text: 'စုစုပေါင်း', width: 9, styles: const PosStyles(bold: true)),
        PosColumn(
          text: '${numberFormat.format(receipt.totalAmount)} ကျပ်',
          width: 3,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);

      bytes += generator.feed(1);

      // Thank you message
      bytes += generator.text(
        'ကျေးဇူးတင်ပါသည်',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.feed(2);
      bytes += generator.cut();

      // Print
      final result = await _printerManager.writeBytes(printer, bytes);
      return result == PosPrintResult.success;
    } catch (e) {
      throw Exception('ပရင့်ထုတ်ရာတွင် အမှားတစ်ခု ဖြစ်ပေါ်ခ့ဲသည်: $e');
    }
  }

  void dispose() {
    _printerManager.stopScan();
  }
}
