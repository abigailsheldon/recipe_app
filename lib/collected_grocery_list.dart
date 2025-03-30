import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grocery_list_model.dart';

/*
 * CollectedGroceryListPage
 *
 * Displays the aggregated grocery list.
 * It listens to GroceryListModel and shows all ingredients that have been added.
 */
class CollectedGroceryListPage extends StatelessWidget {
  const CollectedGroceryListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collected Grocery List"),
      ),
      body: Consumer<GroceryListModel>(
        builder: (context, groceryListModel, child) {
          if (groceryListModel.selectedIngredients.isEmpty) {
            return const Center(child: Text("No ingredients selected."));
          }
          return ListView.builder(
            itemCount: groceryListModel.selectedIngredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.check),
                title: Text(groceryListModel.selectedIngredients[index]),
              );
            },
          );
        },
      ),
    );
  }
}
