import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_details.dart';
import 'styles.dart';

/* 
 * FavoriteMenu Page
 * 
 * Displays a list of favorite recipe names using consistent pixel-art styling.
 * If no favorites exist, a message is shown using the pixel font.
 * When a recipe title is tapped, the app navigates to the recipe's details page.
 */
class FavoriteMenu extends StatefulWidget {
  final List<String> recipe_Name;
  const FavoriteMenu({super.key, required this.recipe_Name});

  @override
  _FavoriteMenuState createState() => _FavoriteMenuState();
}

class _FavoriteMenuState extends State<FavoriteMenu> {
  // Define a common pixel-art decoration for list items.
  final BoxDecoration pixelDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black, width: 2),
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Menu", style: pixelTitleTextStyle),
      ),
      body: widget.recipe_Name.isEmpty
          ? const Center(
              child: Text(
                "No favorites selected",
                style: pixelTitleTextStyle,
              ),
            )
          : ListView.builder(
              itemCount: widget.recipe_Name.length,
              itemBuilder: (context, index) {
                final String recipeTitle = widget.recipe_Name[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: pixelDecoration,
                  child: TextButton(
                    onPressed: () async {
                      // Retrieve all recipes from the database.
                      final dbHelper =
                          Provider.of<DatabaseHelper>(context, listen: false);
                      List<Map<String, dynamic>> allRecipes =
                          await dbHelper.allRecipeNames();
                      // Find the recipe details matching the tapped title.
                      try {
                        final recipe = allRecipes.firstWhere((r) =>
                            r[DatabaseHelper.columnName] == recipeTitle);
                        // Navigate to the RecipeDetailPage with the found recipe.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailPage(recipe: recipe)),
                        );
                      } catch (e) {
                        // Handle the case when the recipe is not found.
                        debugPrint("Recipe not found: $recipeTitle");
                      }
                    },
                    child: Text(
                      recipeTitle,
                      style: pixelButtonTextStyle,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
