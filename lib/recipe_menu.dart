import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/favorite_menu.dart';
import 'package:recipe/recipe_details.dart';
import 'db_helper.dart';
import 'package:provider/provider.dart';
import 'package:recipe/recipe_menu.dart';

class RecipeMenu extends StatefulWidget {
  const RecipeMenu({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();
}

class _Recipe_Menu extends State<RecipeMenu> {
  List<Map<String, dynamic>> allRecipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  List<String> categories = ['All'];
  String selectedCategory = 'All';
  
  // Favorite recipe status
  Map<String, bool> favoriteSelectedRecipe = {};
  List<String> unchecked = [];
  List<String> checked = [];
  int? recipeId = 0;
  int favoriteStatus = 0;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<Map<String, dynamic>> data = await dbHelper.allRecipeNames();
    // Build a set of distinct categories (splitting comma-separated values)
    Set<String> catSet = {'All'};
    for (var recipe in data) {
      String catString = recipe[DatabaseHelper.columnCateagory];
      List<String> parsed = _parseCategories(catString);
      catSet.addAll(parsed);
    }
    setState(() {
      allRecipes = data;
      categories = catSet.toList()..sort();
      selectedCategory = 'All';
      _filterRecipes();
    });
  }

  // Helper: Split comma-separated category strings and trim them.
  List<String> _parseCategories(String categoryString) {
    return categoryString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  // Filter recipes based on the selected category.
  void _filterRecipes() {
    setState(() {
      if (selectedCategory == 'All') {
        filteredRecipes = List.from(allRecipes);
      } else {
        filteredRecipes = allRecipes.where((recipe) {
          String catString = recipe[DatabaseHelper.columnCateagory];
          List<String> cats = _parseCategories(catString);
          return cats.contains(selectedCategory);
        }).toList();
      }
      // Reinitialize favorite status maps based on filtered recipes.
      favoriteSelectedRecipe.clear();
      unchecked.clear();
      checked.clear();
      for (var recipe in filteredRecipes) {
        final name = recipe[DatabaseHelper.columnName];
        bool isFav = recipe[DatabaseHelper.columnFavorite] == 1;
        favoriteSelectedRecipe[name] = isFav;
        if (isFav) {
          checked.add(name);
        } else {
          unchecked.add(name);
        }
      }
    });
  }

  void _favoritSelection(String recipe, bool? value) async {
    setState(() async {
      favoriteSelectedRecipe[recipe] = value ?? false;
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      await _getRecipeId(recipe);
      if (value == true) {
        if (!checked.contains(recipe)) {
          favoriteStatus = 1;
          checked.add(recipe);
          unchecked.remove(recipe);
        }
      } else {
        if (!unchecked.contains(recipe)) {
          unchecked.add(recipe);
          checked.remove(recipe);
          favoriteStatus = 0;
        }
      }
      await _updateFavoriteRecipe(favoriteStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: allRecipes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Dropdown filter for categories
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                        _filterRecipes();
                      });
                    },
                    items: categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredRecipes.length,
                    itemBuilder: (context, index) {
                      String name = filteredRecipes[index][DatabaseHelper.columnName];
                      return ListTile(
                        leading: Checkbox(
                          value: favoriteSelectedRecipe[name] ?? false,
                          onChanged: (bool? value) {
                            _favoritSelection(name, value);
                          },
                        ),
                        title: ElevatedButton(
                          onPressed: () {},
                          child: Text(name, style: const TextStyle(color: Colors.blueAccent)),
                        ),
                        subtitle: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: filteredRecipes[index])),
                            );
                          },
                          child: const Text("Recipe Description"),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavoriteMenu()),
                      );
                    },
                    child: const Text("View Favorite List"),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _getRecipeId(String recipe) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    int? _id = await dbHelper.getRecipteNameById(recipe);
    setState(() {
      recipeId = _id;
    });
  }

  Future<void> _updateFavoriteRecipe(int _status) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: recipeId,
      DatabaseHelper.columnFavorite: _status,
    };
    final updatedRows = await dbHelper.updateFavoriteStatus(row);
    debugPrint("Updated $updatedRows row(s)");
  }
}
