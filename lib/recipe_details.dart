import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'grocery_list.dart'; // Make sure this file is present

/* 
 * RecipeDetailPage
 *
 * Displays full details for a recipe, including category, grocery list,
 * description, and date. It also includes a button to navigate to the 
 * GroceryListPage which displays the grocery list as individual ingredients.
 */
class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the current timestamp if the recipe's date field is missing.
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
            Text(
              "Grocery List:\n${recipe[DatabaseHelper.groceryList]}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Description:\n${recipe[DatabaseHelper.description]}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Date: ${recipeDate.toLocal()}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroceryListPage(
                        groceryListText:
                            recipe[DatabaseHelper.groceryList] ?? '',
                      ),
                    ),
                  );
                },
                child: const Text("View Grocery List"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
