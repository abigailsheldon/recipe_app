import 'package:flutter/material.dart';

/* 
 * GroceryListPage
 * 
 * Displays the grocery list (ingredients) for a recipe.
 * It takes a single String parameter (groceryListText), splits it by newline characters,
 * and displays each non-empty line as a list item.
 */
class GroceryListPage extends StatelessWidget {
  final String groceryListText;

  const GroceryListPage({Key? key, required this.groceryListText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split the grocery list text into individual ingredients.
    List<String> ingredients = groceryListText
        .split('\n')
        .where((item) => item.trim().isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery List"),
      ),
      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: Text(ingredients[index]),
          );
        },
      ),
    );
  }
}
