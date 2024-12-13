import 'package:flutter/material.dart';
import 'database_helper.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemQuantityController = TextEditingController();
  List<Map<String, dynamic>> _inventory = [];

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    final items = await DatabaseHelper.instance.fetchAllItems();
    setState(() {
      _inventory = items;
    });
  }

  Future<void> addItem() async {
    if (itemNameController.text.isNotEmpty &&
        itemQuantityController.text.isNotEmpty) {
      await DatabaseHelper.instance.insertItem(
        itemNameController.text,
        int.tryParse(itemQuantityController.text) ?? 0,
      );
      itemNameController.clear();
      itemQuantityController.clear();
      _fetchInventory();
    }
  }

  Future<void> editItem(int id) async {
    itemNameController.text =
        _inventory.firstWhere((item) => item['id'] == id)['name'];
    itemQuantityController.text = _inventory
        .firstWhere((item) => item['id'] == id)['quantity']
        .toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: itemQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DatabaseHelper.instance.updateItem(
                id,
                itemNameController.text,
                int.tryParse(itemQuantityController.text) ?? 0,
              );
              Navigator.pop(context);
              _fetchInventory();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteItem(int id) async {
    await DatabaseHelper.instance.deleteItem(id);
    _fetchInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red, // Set AppBar background color to black
        foregroundColor: Colors.black, // Set AppBar text color to white
        title: const Text('Simple Inventory Manager'),
      ),
      body: Container(
        color: Colors.white, // Set background color to red
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: itemNameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: itemQuantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: addItem,
              child: const Text('Add Item'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  final item = _inventory[index];
                  return ListTile(
                    title: Text('${item['name']}'),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editItem(item['id']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteItem(item['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
