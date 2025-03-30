import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grocery_list_model.dart';

/*
 * CollectedGroceryListPage
 *
 * Displays an accumulated grocery list with pixel-art style.
 * It listens to GroceryListModel and shows all ingredients that have been added.
 */
class CollectedGroceryListPage extends StatelessWidget {
  const CollectedGroceryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const TextStyle pixelStyle = TextStyle(
      fontFamily: 'PixelifySans',
      fontSize: 14,
      color: Colors.black,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collected Grocery List", style: TextStyle(fontFamily: 'PixelifySans')),
      ),
      body: Consumer<GroceryListModel>(
        builder: (context, groceryListModel, child) {
          if (groceryListModel.selectedIngredients.isEmpty) {
            return const Center(
              child: Text(
                "No ingredients selected.",
                style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: groceryListModel.selectedIngredients.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          groceryListModel.selectedIngredients[index],
                          style: pixelStyle,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
