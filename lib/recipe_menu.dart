import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_details.dart';
import 'favorite_menu.dart';
import 'styles.dart';
import 'pixel_recipe_card.dart';

/* 
 * RecipeMenu Page
 * 
 * Displays a list of recipes fetched from the database.
 * Each recipe is shown using PixelRecipeCard for consistent pixel-art styling.
 * Provides a dropdown filter for recipe categories (unique, no repeats).
 * Supports multiple category tags per recipe (e.g., "keto, paleo").
 * A recipe tagged as "keto, paleo" will appear when filtering for either "keto" or "paleo".
 * The favorite toggle is handled separately.
 * 
 * The recipe card shows only a preview (first line) of the recipe directions.
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
  
  // Selected category filter; null means no filter.
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _getAllRecipeData();
  }

  // Helper function to parse categories from a comma-separated string.
  List<String> parseCategories(String categoryString) {
    return categoryString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Compute unique categories from the recipes.
    Set<String> uniqueCategoriesSet = {};
    for (var recipe in recipeNames) {
      String categoryStr = recipe[DatabaseHelper.columnCateagory] as String;
      uniqueCategoriesSet.addAll(parseCategories(categoryStr));
    }
    List<String> uniqueCategories = uniqueCategoriesSet.toList()..sort();
    
    // Filter recipes based on the selected category.
    List<Map<String, dynamic>> filteredRecipes = selectedCategory == null
        ? recipeNames
        : recipeNames.where((recipe) {
            String categoryStr = recipe[DatabaseHelper.columnCateagory] as String;
            List<String> tags = parseCategories(categoryStr);
            return tags.contains(selectedCategory);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipes", style: pixelTitleTextStyle),
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
                // Category Filter Dropdown
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Filter by Category: ", style: pixelButtonTextStyle),
                      DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text("All", style: pixelButtonTextStyle),
                        items: uniqueCategories
                            .map((cat) => DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(cat, style: pixelButtonTextStyle),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      if (selectedCategory != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              selectedCategory = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      String name = recipe[DatabaseHelper.columnName];
                      // Extract a preview (first line) of the recipe directions.
                      String fullDescription = recipe[DatabaseHelper.description] ?? "";
                      List<String> lines = fullDescription.split('\n');
                      String preview = lines.isNotEmpty ? lines[0] : "";
                      if (lines.length > 1) {
                        preview += " ...";
                      }
                      return Stack(
                        children: [
                          // Use PixelRecipeCard for consistent styling, passing the preview.
                          PixelRecipeCard(
                            title: name,
                            description: preview,
                            onDetailsPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailPage(recipe: recipe),
                                ),
                              );
                              _getAllRecipeData();
                            },
                          ),
                          // Favorite toggle positioned at the top-right of the card.
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                favoriteSelectedRecipe[name] ?? false
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteSelectedRecipe[name] ?? false
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                bool newVal = !(favoriteSelectedRecipe[name] ?? false);
                                _favoriteSelection(name, newVal);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
      // Button at the bottom to view favorite recipes.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: pixelButtonStyle,
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
          child: Text("View Favorite List", style: pixelButtonTextStyle),
        ),
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
    });
  }

  /* 
   * _favoriteSelection:
   * Handles toggling a recipe's favorite status when the heart icon is tapped.
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
  }

  /* 
   * _getRecipeId:
   * Retrieves the database ID for a given recipe name using DatabaseHelper.getRecipteNameById.
   */
  Future<int?> _getRecipeId(String recipe) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    return await dbHelper.getRecipteNameById(recipe);
  }
}
