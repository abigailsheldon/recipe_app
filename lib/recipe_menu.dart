import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_details.dart';
import 'favorite_menu.dart';

/* 
 * RecipeMenu Page
 * 
 * Displays a list of recipes fetched from the database.
 * Each recipe is shown in a Card that contains:
 *  - A rectangular container at the top displaying the recipe title.
 *  - A heart icon in the top-right corner for toggling the favorite status.
 *  - A "Recipe Details" button that navigates to the RecipeDetailPage.
 * At the bottom, there's a button to view the saved favorite recipes.
 */
class RecipeMenu extends StatefulWidget {
  const RecipeMenu({super.key});

  @override
  State<RecipeMenu> createState() => _RecipeMenuState();
}

class _RecipeMenuState extends State<RecipeMenu> {
  List<Map<String, dynamic>> recipeNames = [];
  // Map to track the favorite selection status for each recipe.
  Map<String, bool> favoriteSelectedRecipe = {};
  // Lists to track favorite recipes.
  List<String> checked = [];
  List<String> unchecked = [];

  @override
  void initState() {
    super.initState();
    _getAllRecipeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes"),
        actions: [
          /* 
           * Favorites Button:
           * When tapped, retrieves the favorite recipe names from the database
           * and navigates to the FavoriteMenu page.
           */
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              final dbHelper =
                  Provider.of<DatabaseHelper>(context, listen: false);
              List<String> favs = await dbHelper.getFavoriteRecipeNames();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMenu(recipe_Name: favs),
                ),
              );
              _getAllRecipeData();
            },
          ),
        ],
      ),
      body: recipeNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: recipeNames.length,
                    itemBuilder: (context, index) {
                      String name =
                          recipeNames[index][DatabaseHelper.columnName];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      favoriteSelectedRecipe[name] ?? false
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: favoriteSelectedRecipe[name] ?? false
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Toggle favorite status when heart icon is tapped.
                                      bool newVal =
                                          !(favoriteSelectedRecipe[name] ?? false);
                                      _favoriteSelection(name, newVal);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Button to navigate to Recipe Details page.
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailPage(
                                          recipe: recipeNames[index]),
                                    ),
                                  );
                                  _getAllRecipeData();
                                },
                                child: const Text("Recipe Details"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Button at the bottom to view favorites.
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final dbHelper =
                          Provider.of<DatabaseHelper>(context, listen: false);
                      List<String> favs = await dbHelper.getFavoriteRecipeNames();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FavoriteMenu(recipe_Name: favs),
                        ),
                      );
                      _getAllRecipeData();
                    },
                    child: const Text("View Favorite List"),
                  ),
                ),
              ],
            ),
    );
  }

  /* 
   * _getAllRecipeData:
   * Retrieves all recipes from the database using DatabaseHelper.allRecipeNames().
   * Updates the local recipeNames list and initializes the favoriteSelectedRecipe map
   * based on the stored favorite value (1 means true).
   */
  void _getAllRecipeData() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<Map<String, dynamic>> allRecipes = await dbHelper.allRecipeNames();
    setState(() {
      recipeNames = allRecipes;
      for (var recipe in recipeNames) {
        String name = recipe[DatabaseHelper.columnName];
        favoriteSelectedRecipe[name] =
            recipe[DatabaseHelper.columnFavorite] == 1;
      }
      unchecked = recipeNames
          .map((recipe) => recipe[DatabaseHelper.columnName] as String)
          .toList();
      checked = recipeNames
          .where((recipe) => recipe[DatabaseHelper.columnFavorite] == 1)
          .map((recipe) => recipe[DatabaseHelper.columnName] as String)
          .toList();
    });
    print("***** Recipe count from DB: ${recipeNames.length}");
    print("Recipes: $recipeNames");
  }

  /* 
   * _favoriteSelection:
   * Handles the toggling of a recipe's favorite status when the heart icon is tapped.
   * - Updates the local favoriteSelectedRecipe map.
   * - Retrieves the recipe's ID.
   * - Persists the new favorite status (1 for favorite, 0 for not favorite) in the database.
   * - Updates the local checked/unchecked lists.
   */
  void _favoriteSelection(String recipe, bool? value) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    setState(() {
      favoriteSelectedRecipe[recipe] = value ?? false;
    });
    int newFavoriteStatus = (value == true) ? 1 : 0;
    int? recId = await _getRecipeId(recipe);
    if (recId != null) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnId: recId,
        DatabaseHelper.columnFavorite: newFavoriteStatus,
      };
      await dbHelper.updateFavoriteStatus(row);
    }
    setState(() {
      if (value == true) {
        if (!checked.contains(recipe)) {
          checked.add(recipe);
          unchecked.remove(recipe);
        }
      } else {
        if (!unchecked.contains(recipe)) {
          unchecked.add(recipe);
          checked.remove(recipe);
        }
      }
    });
  }

  /* 
   * _getRecipeId:
   * Retrieves the database ID for a given recipe name using DatabaseHelper.getRecipteNameById.
   * Returns the ID as an integer, or null if not found.
   */
  Future<int?> _getRecipeId(String recipe) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    int? id = await dbHelper.getRecipteNameById(recipe);
    return id;
  }
}
