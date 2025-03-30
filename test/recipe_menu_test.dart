// test/recipe_menu_test.dart
// ---------------------------------------------------------------------------
// This widget test verifies that the RecipeMenu widget displays recipes and
// a category filter dropdown. A mock DatabaseHelper is injected via Provider
// to supply dummy recipe data.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:recipe/db_helper.dart';
import 'package:recipe/recipe_menu.dart';

// Create a mock class for DatabaseHelper using mocktail.
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RecipeMenu widget tests', () {
    late MockDatabaseHelper mockDbHelper;

    setUp(() {
      mockDbHelper = MockDatabaseHelper();

      // When allRecipeNames() is called, return dummy recipes.
      when(() => mockDbHelper.allRecipeNames()).thenAnswer((_) async => [
            {
              DatabaseHelper.columnName: 'Pancakes',
              DatabaseHelper.columnFavorite: 0,
              DatabaseHelper.columnCateagory: 'Breakfast, Vegan',
              DatabaseHelper.description: 'Mix ingredients\nCook on griddle',
              DatabaseHelper.groceryList: 'Flour\nEggs'
            },
            {
              DatabaseHelper.columnName: 'Spaghetti',
              DatabaseHelper.columnFavorite: 0,
              DatabaseHelper.columnCateagory: 'Italian',
              DatabaseHelper.description: 'Boil pasta\nAdd sauce',
              DatabaseHelper.groceryList: 'Pasta\nTomato sauce'
            }
          ]);
    });

    testWidgets('RecipeMenu displays recipes and filter dropdown',
        (WidgetTester tester) async {
      // Build RecipeMenu with our mockDbHelper injected via Provider.
      await tester.pumpWidget(
        Provider<DatabaseHelper>.value(
          value: mockDbHelper,
          child: const MaterialApp(
            home: RecipeMenu(),
          ),
        ),
      );

      // Allow asynchronous operations to complete.
      await tester.pumpAndSettle();

      // Verify that the dummy recipe names are displayed.
      expect(find.text('Pancakes'), findsOneWidget);
      expect(find.text('Spaghetti'), findsOneWidget);

      // Check that the filter label "Filter by Category: " is visible.
      expect(find.text('Filter by Category: '), findsOneWidget);

      // Open the dropdown menu.
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Verify that one of the category options, e.g. "Breakfast", is found.
      expect(find.text('Breakfast'), findsOneWidget);

      // Tap on the "Breakfast" option to filter recipes.
      await tester.tap(find.text('Breakfast').last);
      await tester.pumpAndSettle();

      // After filtering, "Pancakes" (tagged with Breakfast) should remain.
      expect(find.text('Pancakes'), findsOneWidget);
      // "Spaghetti" should be filtered out.
      expect(find.text('Spaghetti'), findsNothing);
    });
  });
}
