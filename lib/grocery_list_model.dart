import 'package:flutter/material.dart';

/*
 * GroceryListModel
 *
 * A ChangeNotifier model that maintains a list of selected grocery ingredients.
 * Methods to add or remove ingredients and notifies listeners when the list changes.
 */
class GroceryListModel extends ChangeNotifier {
  final List<String> _selectedIngredients = [];

  List<String> get selectedIngredients => _selectedIngredients;

  void addIngredient(String ingredient) {
    if (!_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.add(ingredient);
      notifyListeners();
    }
  }

  void removeIngredient(String ingredient) {
    if (_selectedIngredients.contains(ingredient)) {
      _selectedIngredients.remove(ingredient);
      notifyListeners();
    }
  }
}
