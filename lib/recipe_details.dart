import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'grocery_list.dart';
import 'pixel_recipe_card.dart';


/*
 * RecipeDetailPage
 *
 * Displays full details for a recipe (category, grocery list, description, date).
 * Includes a button to navigate to GroceryListPage, where the user can check ingredients.
 */



/// RecipeDetailPage displays full details for a recipe using a pixel-art style.
/// Each section (e.g. title, details, button) is wrapped in a container with a hard-edged border
/// and uses a pixel font for a retro vibe.
class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the recipe's timestamp and convert it to DateTime.
    final int dateValue =
        recipe[DatabaseHelper.date] ?? DateTime.now().millisecondsSinceEpoch;
    final DateTime recipeDate = DateTime.fromMillisecondsSinceEpoch(dateValue);

    // Define a common pixel style for containers.
    BoxDecoration pixelDecoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.zero,
    );

    TextStyle headerTextStyle = const TextStyle(
      fontFamily: 'PixelifySans', // Ensure this font is added in your pubspec.yaml.
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );

    TextStyle detailTextStyle = const TextStyle(
      fontFamily: 'PixelifySans',
      fontSize: 14,
      color: Colors.black,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe[DatabaseHelper.columnName]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Title in a pixel art card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                recipe[DatabaseHelper.columnName],
                textAlign: TextAlign.center,
                style: headerTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe Category in its own pixel card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Category: ${recipe[DatabaseHelper.columnCateagory]}",
                style: detailTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Grocery List (raw text) in a pixel card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Grocery List:\n${recipe[DatabaseHelper.groceryList]}",
                style: detailTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Recipe Description in a pixel card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Description:\n${recipe[DatabaseHelper.description]}",
                style: detailTextStyle,
              ),
            ),
            const SizedBox(height: 16),
            // Date in a pixel card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: pixelDecoration,
              child: Text(
                "Date: ${recipeDate.toLocal()}",
                style: detailTextStyle,
              ),
            ),
            const SizedBox(height: 24),
            // Button to navigate to the Grocery List page (for the recipe)
            Center(
              child: Container(
                // This container adds a hard drop shadow
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[600]!, // Darker color for a hard shadow.
                      offset: const Offset(0, 2), // Shadow appears 2 pixels below.
                      blurRadius: 1, // No fuzziness.
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    elevation: 0, // Disable default elevation so our shadow shows.
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: const BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
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
                  child: const Text(
                    "View Recipe Grocery List",
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
