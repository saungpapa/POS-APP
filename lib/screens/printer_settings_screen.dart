import 'package:flutter/material.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import '../services/print_service.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrintService _printService = PrintService.instance;
  List<PrinterBluetooth> _printers = [];
  bool _isScanning = false;
  PrinterBluetooth? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _selectedPrinter = _printService.selectedPrinter;
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _printers.clear();
    });

    try {
      await _printService.startScan();
      _printService.scanPrinters().listen((printers) {
        if (mounted) {
          setState(() {
            _printers = printers;
          });
        }
      });

      // Auto-stop scanning after 4 seconds
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
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

  void _selectPrinter(PrinterBluetooth printer) {
    setState(() {
      _selectedPrinter = printer;
    });
    _printService.selectPrinter(printer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${printer.name} ကို ရွေးချယ်ပြီးပါပြီ'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer ချိတ်ဆက်မှု'),
      ),
      body: Column(
        children: [
          // Current printer status
          if (_selectedPrinter != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ချိတ်ဆက်ထားသော Printer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          _selectedPrinter!.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPrinter = null;
                      });
                      _printService.disconnect();
                    },
                    child: const Text('ဖြုတ်မည်'),
                  ),
                ],
              ),
            ),

          // Scan button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _startScan,
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(_isScanning ? 'ရှာနေသည်...' : 'Printer ရှာမည်'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),

          // Printers list
          Expanded(
            child: _printers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_disabled,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isScanning
                              ? 'Bluetooth printer များ ရှာနေသည်...'
                              : 'Printer ရှာရန် အပေါ်က ခလုတ်ကို နှိပ်ပါ',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _printers.length,
                    itemBuilder: (context, index) {
                      final printer = _printers[index];
                      final isSelected = _selectedPrinter?.address == printer.address;

                      return ListTile(
                        leading: Icon(
                          Icons.print,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        title: Text(
                          printer.name ?? 'Unknown Device',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(printer.address ?? ''),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () => _selectPrinter(printer),
                      );
                    },
                  ),
          ),

          // Info message
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bluetooth printer ကို ဖွင့်ထားပြီး ချိတ်ဆက်နိုင်အောင် လုပ်ထားပါ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _printService.stopScan();
    super.dispose();
  }
}
