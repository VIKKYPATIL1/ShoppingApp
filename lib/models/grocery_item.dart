import 'package:shopping_application/models/category.dart';

class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
  });
  final String name;
  final Category category;
  final int quantity;
  final String id;
}
