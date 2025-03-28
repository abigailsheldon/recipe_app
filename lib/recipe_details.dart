import 'package:flutter/material.dart';
import 'db_helper.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the current timestamp if recipe[DatabaseHelper.date] is null.
    final int dateValue =
        recipe[DatabaseHelper.date] ?? DateTime.now().millisecondsSinceEpoch;
    final DateTime recipeDate = DateTime.fromMillisecondsSinceEpoch(dateValue);

    return Scaffold(
      appBar: AppBar(title: Text(recipe[DatabaseHelper.columnName])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Category: ${recipe[DatabaseHelper.columnCateagory]}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Grocery List (Ingredients) appears first now.
            Text(
              "Grocery List:\n${recipe[DatabaseHelper.groceryList]}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            // Description appears after the Grocery List.
            Text(
              "Description:\n${recipe[DatabaseHelper.description]}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Date: ${recipeDate.toLocal()}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
