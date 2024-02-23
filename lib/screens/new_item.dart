import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_application/data/categories.dart';
import 'package:shopping_application/models/category.dart';
import 'package:shopping_application/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItems extends StatefulWidget {
  const NewItems({super.key});

  @override
  State<NewItems> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItems> {
  var _grocceryName = "";
  var _quantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;

  void _saveItem(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      //realtime database link                      /collection name /json for firebase
      final url = Uri.https('shoppingapp-6ca94-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'name': _grocceryName,
            'categories': _selectedCategory.category,
            'quantity': _quantity,
          },
        ),
      );
      //we are getting id from firebase here itself so we are using it here and
      // also poping with new data
      //to avoid unecessay request to firebase

      //decoding json data to map

      final Map<String, dynamic> newid = json.decode(response.body);

      //if we are using post or future references
      //at that time we are sending request to server
      //and that time no widget is part of screen
      // thats why context become outdated
      //so we are using
      if (!context.mounted) {
        return;
      }
      _isSending = true;
      Navigator.of(context).pop(GroceryItem(
          id: newid['name'],
          name: _grocceryName,
          category: _selectedCategory,
          quantity: _quantity));
      /*Navigator.of(context).pop(
        GroceryItem(
            id: DateTime.now().toString(),
            name: _grocceryName,
            category: _selectedCategory,
            quantity: _quantity),
      );*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _grocceryName,
                onSaved: (value) => _grocceryName = value!,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Either Data is entered wrong";
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _quantity = int.parse(value!),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return "Input Field Must Be Positive number";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final cat in categories.entries)
                          DropdownMenuItem(
                              value: cat.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    color: cat.value.color,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(cat.value.category),
                                ],
                              ))
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator())
                        : const Text('Reset'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => _isSending ? null : _saveItem(context),
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator())
                        : const Text("Add"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
