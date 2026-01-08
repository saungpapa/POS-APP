import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:pos_app/models/receipt.dart';
import 'package:pos_app/services/print_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  final Receipt receipt;

  const PrinterSettingsScreen({super.key, required this.receipt});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrintService _printService = PrintService();
  List<PrinterBluetooth> _devices = [];
  bool _isScanning = false;
  bool _isPrinting = false;
  PrinterBluetooth? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    try {
      final devices = await _printService.scanDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('အမှား: $e')),
        );
      }
    }
  }

  Future<void> _printToDevice(PrinterBluetooth printer) async {
    setState(() {
      _isPrinting = true;
      _selectedPrinter = printer;
    });

    try {
      final success = await _printService.printReceipt(widget.receipt, printer);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ပရင့်ထုတ်ပြီးပါပြီ')),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ပရင့်ထုတ်၍မရပါ')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('အမှား: $e')),
        );
      }
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ပရင်တာ ရွေးချယ်ရန်'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _scanDevices,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('ပရင်တာများ ရှာနေသည်...'),
                ],
              ),
            ),
          Expanded(
            child: _devices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.bluetooth_disabled,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ပရင်တာ မတွေ့ပါ',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Bluetooth ပရင်တာကို ဖွင့်ထားပါ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _scanDevices,
                          icon: const Icon(Icons.refresh),
                          label: const Text('ပြန်ရှာမယ်'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isSelected = _selectedPrinter == device;
                      final isPrintingThis = _isPrinting && isSelected;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.print,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                          title: Text(device.name ?? 'Unknown'),
                          subtitle: Text(device.address ?? ''),
                          trailing: isPrintingThis
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.chevron_right),
                          onTap: _isPrinting
                              ? null
                              : () => _printToDevice(device),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'မှတ်ချက်:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Bluetooth ပရင်တာကို ဖွင့်ထားရမည်'),
                Text('• ပရင်တာနဲ့ စက်ကို paired လုပ်ထားရမည်'),
                Text('• Thermal printer များကိုသာ အလုပ်လုပ်ပါမည်'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _printService.dispose();
    super.dispose();
  }
}
