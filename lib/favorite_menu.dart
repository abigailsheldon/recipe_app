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
 * 
 * Updated to persist favorites by re-fetching them from the database.
 */
class FavoriteMenu extends StatefulWidget {
  // Removed the passed-in recipe list to allow fetching fresh data.
  const FavoriteMenu({super.key});

  @override
  _FavoriteMenuState createState() => _FavoriteMenuState();
}

class _FavoriteMenuState extends State<FavoriteMenu> {
  // Local state variable to store favorite recipe names.
  List<String> _favorites = [];

  // Define a common pixel-art decoration for list items.
  final BoxDecoration pixelDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black, width: 2),
    borderRadius: BorderRadius.zero,
  );

  @override
  void initState() {
    super.initState();
    _refreshFavorites();
  }

  /// Retrieves the favorite recipe names from the database and updates local state.
  Future<void> _refreshFavorites() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<String> favs = await dbHelper.getFavoriteRecipeNames();
    setState(() {
      _favorites = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Menu", style: pixelTitleTextStyle),
      ),
      body: _favorites.isEmpty
          ? const Center(
              child: Text(
                "No favorites selected",
                style: pixelTitleTextStyle,
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final String recipeTitle = _favorites[index];
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
                        ).then((_) {
                          // Optionally, refresh the favorites when returning.
                          _refreshFavorites();
                        });
                      } catch (e) {
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
