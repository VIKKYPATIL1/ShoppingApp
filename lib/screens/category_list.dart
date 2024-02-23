import 'dart:convert';
import 'package:shopping_application/data/categories.dart';
import 'package:flutter/material.dart';
import 'package:shopping_application/models/grocery_item.dart';
import 'package:shopping_application/screens/new_item.dart';
import 'package:http/http.dart' as http;

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});
  @override
  State<CategoryListScreen> createState() {
    return _CategoryListScreen();
  }
}

class _CategoryListScreen extends State<CategoryListScreen> {
  List<GroceryItem> groceryItems = [];
  bool _isloading = true;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'shoppingapp-6ca94-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);
    final Map<String, dynamic> listdata = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listdata.entries) {
      final category = categories.entries
          .firstWhere(
              (itemdata) => itemdata.value.category == item.value['categories'])
          .value;
      loadedItems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            category: category,
            quantity: item.value['quantity']),
      );
    }
    setState(() {
      groceryItems = loadedItems;
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("Add New Grocery Items"),
    );

    if (_isloading) {
      content = const Center(
        child: CircularProgressIndicator(
            color: Color.fromRGBO(255, 0, 0, 0.494),
            backgroundColor: Color.fromARGB(112, 0, 0, 0)),
      );
    }

    if (groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(groceryItems[index].id),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            setState(() {
              groceryItems.remove(groceryItems[index]);
            });
          },
          child: ListTile(
            leading: Container(
              width: 15,
              height: 15,
              color: groceryItems[index].category.color,
            ),
            title: Text(groceryItems[index].name.toString()),
            trailing: Text(groceryItems[index].quantity.toString()),
            splashColor: groceryItems[index].category.color,
            contentPadding: const EdgeInsets.all(10),
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
          ),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(title: const Text("Your Groceries"), actions: [
          IconButton(
              onPressed: () async {
                final newItem = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NewItems(),
                  ),
                );
                if (newItem == null) {
                  return;
                }
                setState(() {
                  groceryItems.add(newItem);
                });
              },
              icon: const Icon(Icons.add))
        ]),
        body: content);
  }
}
