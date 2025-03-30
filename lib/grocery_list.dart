import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grocery_list_model.dart';

/* 
 * GroceryListPage
 * 
 * Displays the grocery list (ingredients) for a specific recipe.
 * Splits the provided groceryListText by newline characters,
 * cleans each ingredient by removing leading measurement information,
 * and displays each ingredient with a checkbox.
 * The "Add All" button marks every ingredient as selected and adds them
 * to the global GroceryListModel (which prevents duplicates).
 */
class GroceryListPage extends StatefulWidget {
  final String groceryListText;

  const GroceryListPage({Key? key, required this.groceryListText})
      : super(key: key);

  @override
  _GroceryListPageState createState() => _GroceryListPageState();
}

class _GroceryListPageState extends State<GroceryListPage> {
  late List<String> ingredients;
  // Local map to track checkbox states for each ingredient.
  Map<String, bool> localSelection = {};

  @override
  void initState() {
    super.initState();
    // Split text by newline, remove empty lines, and clean each ingredient.
    ingredients = widget.groceryListText
        .split('\n')
        .where((item) => item.trim().isNotEmpty)
        .map((ingredient) => cleanIngredient(ingredient))
        .toList();
    // Initialize all selections to false.
    for (var ingredient in ingredients) {
      localSelection[ingredient] = false;
    }
  }

  /* 
   * cleanIngredient:
   * Uses a regular expression to remove measurement information from the start
   * of an ingredient string (e.g. "1/4 tsp", "1/2 cup").
   */
  String cleanIngredient(String ingredient) {
    final pattern = RegExp(
      r'^\s*\d+([\/\.\d]+)?\s*(cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|ounce|ounces|oz|pound|lb|lbs)\s+',
      caseSensitive: false,
    );
    return ingredient.replaceFirst(pattern, '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery List"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ingredients.length,
              itemBuilder: (context, index) {
                String ingredient = ingredients[index];
                return CheckboxListTile(
                  title: Text(ingredient),
                  value: localSelection[ingredient],
                  onChanged: (bool? value) {
                    setState(() {
                      localSelection[ingredient] = value ?? false;
                    });
                    var groceryListModel =
                        Provider.of<GroceryListModel>(context, listen: false);
                    if (value == true) {
                      groceryListModel.addIngredient(ingredient);
                    } else {
                      groceryListModel.removeIngredient(ingredient);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                var groceryListModel =
                    Provider.of<GroceryListModel>(context, listen: false);
                setState(() {
                  // Mark all ingredients as selected and add to the global model.
                  for (var ingredient in ingredients) {
                    localSelection[ingredient] = true;
                    groceryListModel.addIngredient(ingredient);
                  }
                });
              },
              child: const Text("Add All"),
            ),
          ),
        ],
      ),
    );
  }
}
