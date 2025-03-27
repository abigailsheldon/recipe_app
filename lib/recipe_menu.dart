import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_details.dart';

class RecipeMenu extends StatefulWidget {
  const RecipeMenu({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();
}

class _Recipe_Menu extends State<RecipeMenu> {
  List<Map<String, dynamic>> recipeNames = [];

  @override
  void initState() {
    super.initState();
    _getAllRecipeData();
  }

  @override
  Widget build(BuildContext context) {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Recipes")),
      body: recipeNames.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipeNames.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailPage(recipe: recipeNames[index]),
                      ),
                    );
                  },
                  child: Text(recipeNames[index][DatabaseHelper.columnName]),
                );
              },
            ),
    );
  }

  void _getAllRecipeData() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<Map<String, dynamic>> allRecipes = await dbHelper.allRecipes();

    setState(() {
      recipeNames = allRecipes;
    });

    print("*****recipe count from db **********: ${recipeNames.length}");
    print("Recipes: $recipeNames");
  }
}
