import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'grocery_list.dart';
import 'styles.dart';
import 'pixel_recipe_card.dart'; // If you wish to wrap some parts in a pixel card

/*
 * RecipeDetailPage
 *
 * Displays full details for a recipe (category, grocery list, description, date).
 * Includes a button to navigate to GroceryListPage.
 */
class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the stored timestamp to a DateTime.
    final int dateValue =
        recipe[DatabaseHelper.date] ?? DateTime.now().millisecondsSinceEpoch;
    final DateTime recipeDate = DateTime.fromMillisecondsSinceEpoch(dateValue);

    // Instead of defining styles here, we could move the decoration to styles.dart.
    final BoxDecoration pixelDecoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.zero,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe[DatabaseHelper.columnName], style: pixelTitleTextStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Title using shared pixel style.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                recipe[DatabaseHelper.columnName],
                textAlign: TextAlign.center,
                style: pixelTitleTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe Category
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Category: ${recipe[DatabaseHelper.columnCateagory]}",
                style: pixelButtonTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Grocery List
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Grocery List:\n${recipe[DatabaseHelper.groceryList]}",
                style: pixelButtonTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Description:\n${recipe[DatabaseHelper.description]}",
                style: pixelButtonTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe Date
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Date: ${recipeDate.toLocal()}",
                style: pixelButtonTextStyle,
              ),
            ),
            const SizedBox(height: 24),
            // Button to view Grocery List for the recipe.
            Center(
              child: ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroceryListPage(
                        groceryListText: recipe[DatabaseHelper.groceryList] ?? '',
                      ),
                    ),
                  );
                },
                child: Text(
                  "View Recipe Grocery List",
                  style: pixelButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
