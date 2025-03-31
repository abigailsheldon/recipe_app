import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grocery_list_model.dart';
import 'styles.dart';


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
  Map<String, bool> localSelection = {};

  @override
  void initState() {
    super.initState();
    ingredients = widget.groceryListText
        .split('\n')
        .where((item) => item.trim().isNotEmpty)
        .map((ingredient) => cleanIngredient(ingredient))
        .toList();
    for (var ingredient in ingredients) {
      localSelection[ingredient] = false;
    }
  }

  String cleanIngredient(String ingredient) {
    final pattern = RegExp(
      r'^\s*(\d+(?:\s+\d+\/\d+)?|\d*\/\d+|\d+(\.\d+)?)\s*(cup|cups|tsp|teaspoon|teaspoons|tbsp|tablespoon|tablespoons|ounce|ounces|oz|pound|lb|lbs)?\s+',
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
                  title: Text(
                    ingredient,
                    style: const TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 14,
                    ),
                  ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                elevation: 4,
                shadowColor: Colors.grey[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              onPressed: () {
                var groceryListModel =
                    Provider.of<GroceryListModel>(context, listen: false);
                setState(() {
                  for (var ingredient in ingredients) {
                    localSelection[ingredient] = true;
                    groceryListModel.addIngredient(ingredient);
                  }
                });
              },
              child: const Text(
                "Add All",
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
