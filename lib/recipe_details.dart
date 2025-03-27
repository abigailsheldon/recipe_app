import 'package:flutter/material.dart';
import 'db_helper.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely retrieve the timestamp; use the current timestamp if it's null.
    final int timestamp = recipe[DatabaseHelper.date] ?? DateTime.now().millisecondsSinceEpoch;
    final DateTime recipeDate = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe[DatabaseHelper.columnName] ?? 'Recipe Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Name: ${recipe[DatabaseHelper.columnName]}",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text("Category: ${recipe[DatabaseHelper.columnCateagory]}"),
            const SizedBox(height: 10),
            Text("Description: ${recipe[DatabaseHelper.description]}"),
            const SizedBox(height: 10),
            Text("Grocery List: ${recipe[DatabaseHelper.groceryList]}"),
            const SizedBox(height: 10),
            Text("Date: ${recipeDate.toLocal()}"),
          ],
        ),
      ),
    );
  }
}
