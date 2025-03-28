import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_details.dart';
import 'favorite_menu.dart';

/* 
 * RecipeMenu Page
 * 
 * Displays a list of recipes fetched from the database.
 * Each recipe is shown with a checkbox for marking as a favorite and a button to view details.
 * The AppBar includes a Favorites button that navigates to the FavoriteMenu page, 
 * which displays all recipes marked as favorite (persisted in the database).
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
  // Lists to track favorite recipes locally.
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
           * When tapped, it retrieves the list of favorite recipe names from the database
           * (if needed) and then navigates to the FavoriteMenu page.
           */
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              final dbHelper =
                  Provider.of<DatabaseHelper>(context, listen: false);
              // Retrieve favorite recipes from the database.
              List<String> favs = await dbHelper.getFavoriteRecipeNames();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoriteMenu(recipe_Name: favs),
                ),
              );
            },
          ),
        ],
      ),
      body: recipeNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipeNames.length,
              itemBuilder: (context, index) {
                String name =
                    recipeNames[index][DatabaseHelper.columnName];
                return ListTile(
                  leading: Checkbox(
                    value: favoriteSelectedRecipe[name] ?? false,
                    onChanged: (bool? value) {
                      _favoriteSelection(name, value);
                    },
                  ),
                  title: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailPage(recipe: recipeNames[index]),
                        ),
                      );
                    },
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /* 
   * _getAllRecipeData:
   * Retrieves all recipes from the database using DatabaseHelper.allRecipes().
   * Initializes the favoriteSelectedRecipe map based on the database’s favorite field,
   * and sets up the local checked and unchecked lists.
   */
  void _getAllRecipeData() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<Map<String, dynamic>> allRecipes = await dbHelper.allRecipes();

    setState(() {
      recipeNames = allRecipes;
      for (var recipe in recipeNames) {
        String name = recipe[DatabaseHelper.columnName];
        // Initialize the favorite status based on the database (1 means true)
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
   * Handles selection/deselection of a recipe as a favorite.
   * - Updates the favoriteSelectedRecipe map in local state.
   * - Retrieves the recipe ID from the database.
   * - Persists the new favorite status (1 for favorite, 0 for not favorite) in the database.
   * - Updates the local checked and unchecked lists.
   */
  void _favoriteSelection(String recipe, bool? value) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    setState(() {
      favoriteSelectedRecipe[recipe] = value ?? false;
    });
    int newFavoriteStatus = (value == true) ? 1 : 0;
    // Retrieve the recipe ID.
    int? recId = await _getRecipeId(recipe);
    if (recId != null) {
      // Update the recipe in the database.
      Map<String, dynamic> row = {
        DatabaseHelper.columnId: recId,
        DatabaseHelper.columnFavorite: newFavoriteStatus,
      };
      await dbHelper.updateFavoriteStatus(row);
    }
    // Update the local checked/unchecked lists.
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
   * Retrieves the database ID for a given recipe name.
   * Returns the ID as an integer, or null if not found.
   */
  Future<int?> _getRecipeId(String recipe) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    int? id = await dbHelper.getRecipteNameById(recipe);
    return id;
  }
}
