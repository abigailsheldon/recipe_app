// test/grocery_list_model_test.dart
// ---------------------------------------------------------------------------
// Unit tests for the GroceryListModel class.
// The tests verify that ingredients can be added, duplicates are ignored,
// and ingredients can be removed. 
// ---------------------------------------------------------------------------

import 'package:flutter_test/flutter_test.dart';
import 'package:recipe/grocery_list_model.dart'; //

void main() {
  // Group tests for GroceryListModel.
  group('GroceryListModel Tests', () {
    late GroceryListModel model;

    // Initialize a fresh instance of GroceryListModel.
    setUp(() {
      model = GroceryListModel();
    });

    // Verify that the initial ingredient list is empty.
    test('Initial list is empty', () {
      // Check that the selectedIngredients list has no entries.
      expect(model.selectedIngredients, isEmpty);
    });

    // Adding an ingredient.
    test('Adding an ingredient', () {
      // Add "Tomato" to the grocery list.
      model.addIngredient('Tomato');
      // Verify that "Tomato" is now in the list.
      expect(model.selectedIngredients.contains('Tomato'), isTrue);
      // The list length should be exactly 1.
      expect(model.selectedIngredients.length, equals(1));
    });

    // Test: Adding a duplicate ingredient should not increase the list length.
    test('Adding duplicate ingredient does not increase list length', () {
      // Add "Tomato" twice.
      model.addIngredient('Tomato');
      model.addIngredient('Tomato');
      // List should still contain only one instance of "Tomato".
      expect(model.selectedIngredients.length, equals(1));
    });

    // Removing an ingredient.
    test('Removing an ingredient', () {
      // Add "Tomato" and then remove it.
      model.addIngredient('Tomato');
      model.removeIngredient('Tomato');
      // List should be empty.
      expect(model.selectedIngredients, isEmpty);
    });
  });
}
