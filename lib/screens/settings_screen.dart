import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'printer_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final shopName = prefs.getString('shop_name') ?? 'ကျွန်ုပ်တို့၏ ဆိုင်';
    
    if (mounted) {
      setState(() {
        _shopNameController.text = shopName;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopNameController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('သိမ်းဆည်းပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ ဆက်တင်များ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Shop Information Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'ဆိုင်အချက်အလက်များ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ဆိုင်အမည်',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _shopNameController,
                            decoration: const InputDecoration(
                              hintText: 'ဆိုင်အမည် ရိုက်ထည့်ပါ',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.store),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              child: const Text('သိမ်းဆည်းမည်'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Printer Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Printer ဆက်တင်များ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text('Bluetooth Printer'),
                  subtitle: const Text('Printer ချိတ်ဆက်မှု စီမံခန့်ခွဲမှု'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrinterSettingsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),

                // About Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'အကြောင်း',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                ),
                const ListTile(
                  leading: Icon(Icons.description),
                  title: Text('POS App'),
                  subtitle: Text('Mobile POS Application for Myanmar Shops'),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    super.dispose();
  }
}
