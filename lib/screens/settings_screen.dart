import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_app/services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _shopName = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = context.read<DatabaseService>();
    final shopName = await db.getSetting('shop_name', defaultValue: 'ကျွန်တော့်ဆိုင်');
    
    setState(() {
      _shopName = shopName;
      _isLoading = false;
    });
  }

  Future<void> _editShopName() async {
    final controller = TextEditingController(text: _shopName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ဆိုင်အမည် ပြင်ရန်'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ဆိုင်အမည်',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('မလုပ်တော့'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('သိမ်းမည်'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final db = context.read<DatabaseService>();
      await db.setSetting('shop_name', result);
      
      setState(() => _shopName = result);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('သိမ်းပြီးပါပြီ')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ ဆက်တင်'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'ဆိုင်အချက်အလက်',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.store),
                  title: const Text('ဆိုင်အမည်'),
                  subtitle: Text(_shopName),
                  trailing: const Icon(Icons.edit),
                  onTap: _editShopName,
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'အကြောင်း',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.info),
                  title: Text('App Version'),
                  subtitle: Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Features'),
                  subtitle: const Text('Barcode Scanner, Receipt Print, Sales Report'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'POS App',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.point_of_sale, size: 48),
                      children: const [
                        Text('ဈေးဆိုင်အတွက် Mobile POS App'),
                        SizedBox(height: 8),
                        Text('Features:'),
                        Text('• 📷 Barcode Scanner'),
                        Text('• 🛒 Shopping Cart'),
                        Text('• 🧾 Receipt Print'),
                        Text('• 📊 Sales Report'),
                        Text('• 💾 Local Database'),
                      ],
                    );
                  },
                ),
              ],
            ),
    );
  }
}
