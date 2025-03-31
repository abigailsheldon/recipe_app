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
  late int? recipeId = 0;

  
  // Selected category filter; null means no filter.
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _getAllRecipeData();
  }

  void _favoritSelection(String recipe, bool? value) async{
      setState(()  async {
        favoriteSelectedRecipe[recipe] = value ?? false;
        if(value == true){
          if(!checked.contains(recipe)){
            favoriteStatus = 1;
            print("before getRecipeId call****");
            await _getRecipeId(recipe);//grab id of the recipe that was checked
            print("After RecipeIdcall***");
            checked.add(recipe); //add selected recipe to checked list
            
            unchecked.remove(recipe); // remove checked recipe from unchecked recipe list
            // update the recipe in db to update favorite status for the selected recipe
            
            await _updateFavoriteRecipe(favoriteStatus);

          }
          }else{
            if(!unchecked.contains(recipe)){
              print("check****");
              unchecked.add(recipe);
              // update recipe favorite status
            
                

                favoriteStatus = 0;
              print("before getRecipeId call**** unchecked");
              await _getRecipeId(recipe);
             await _updateFavoriteRecipe(favoriteStatus);
              print("After RecipeIdcall*** unchecked");

              checked.remove(recipe);
            }
          }

        
        
      });



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

 Future<void> _getAllRecipeData() async{
  // int count =  await dbHelper.numberOfRecipeName();
    List<Map<String,dynamic>> allNames = await dbHelper.allRecipeNames();

  setState(() {
    
    //recipeNumber = count;
    recipeNames = allNames;
  });
      
     
       print("*****recipe count from db **********: ${recipeNames.length}");
       print("Recipes: $recipeNames");
  }
  Future<void> _getRecipeId(String recipe) async{
    int? _id = await dbHelper.getRecipteNameById(recipe);
     setState(() {
      recipeId = _id;

      
    });


  /* 
   * _getAllRecipeData:
   * Retrieves all recipes from the database using DatabaseHelper.allRecipeNames().
   * Updates the local recipeNames list and initializes the favoriteSelectedRecipe map
   * based on the stored favorite value (1 means true).
   */
  
  }

  Future<void> _updateFavoriteRecipe(int _status) async{
    Map<String,dynamic> row = {
              DatabaseHelper.columnId: recipeId,
              DatabaseHelper.columnFavorite: favoriteStatus
            };
            final updatedRows =await dbHelper.updateFavoriteStatus(row);
            print("Updated $updatedRows row(s****)");

  }

  /* 
   * _getRecipeId:
   * Retrieves the database ID for a given recipe name using DatabaseHelper.getRecipteNameById.
   */
 
}
