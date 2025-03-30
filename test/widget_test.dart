import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe/db_helper.dart';
import 'package:recipe/recipe_menu.dart';
import 'package:recipe/main.dart';
import 'package:sqflite/sqlite_api.dart' show Database;
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mock class for Database using Mocktail. Simulates
// interactions with an sqflite Database.
// ---------------------------------------------------------------------------
class MockDatabase extends Mock implements Database {}

// ---------------------------------------------------------------------------
// Mock class for DatabaseHelper.
// ---------------------------------------------------------------------------
class MockDatabaseHelper extends Mock implements DatabaseHelper {
  late Database _db;

  @override
  Future<Database> init() async {
    // Create and return a mock Database instance.
    _db = MockDatabase();
    return _db;
  }

  // Overriding the query method to simulate data from the database.
  @override
  Future<List<Map<String, dynamic>>> query(String table, {List<String>? columns}) async {
    // Return a fixed set of mock recipes.
    return [
      {'recipe_name': 'pancakes', DatabaseHelper.columnFavorite: 0, DatabaseHelper.columnCateagory: 'Breakfast', DatabaseHelper.description: 'Mix ingredients\nCook on griddle', DatabaseHelper.groceryList: 'Flour\nEggs'},
      {'recipe_name': 'spaghetti', DatabaseHelper.columnFavorite: 0, DatabaseHelper.columnCateagory: 'Italian', DatabaseHelper.description: 'Boil pasta\nAdd sauce', DatabaseHelper.groceryList: 'Pasta\nTomato sauce'}
    ];
  }
}

void main() {
  // ---------------------------------------------------------------------------
  // Declare mock variables.
  // ---------------------------------------------------------------------------
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  // ---------------------------------------------------------------------------
  // Set up a fallback for any Database values needed by mocktail.
  // ---------------------------------------------------------------------------
  setUpAll(() {
    registerFallbackValue(MockDatabase());
  });

  // ---------------------------------------------------------------------------
  // Before each test, initialize mock objects and set up behavior.
  // ---------------------------------------------------------------------------
  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();

    // Simulate a transaction call on the mock database.
    when(() => mockDatabase.transaction(any())).thenAnswer((_) async => {});

    // When query is called on the mock database, return mock recipes.
    when(() => mockDatabase.query(any(), columns: any(named: 'columns'))).thenAnswer((_) async => [
      {'recipe_name': 'pancakes', DatabaseHelper.columnFavorite: 0, DatabaseHelper.columnCateagory: 'Breakfast', DatabaseHelper.description: 'Mix ingredients\nCook on griddle', DatabaseHelper.groceryList: 'Flour\nEggs'},
      {'recipe_name': 'spaghetti', DatabaseHelper.columnFavorite: 0, DatabaseHelper.columnCateagory: 'Italian', DatabaseHelper.description: 'Boil pasta\nAdd sauce', DatabaseHelper.groceryList: 'Pasta\nTomato sauce'}
    ]);

    // When init is called on the DatabaseHelper, return mockDatabase.
    when(() => mockDatabaseHelper.init()).thenAnswer((_) async => mockDatabase);
  });

  group('Main Menu test', () {
    // -------------------------------------------------------------------------
    // Test: Check that the database helper initializes a Database.
    // -------------------------------------------------------------------------
    test('Check Database initialized', () async {
      final db = await mockDatabaseHelper.init();
      expect(db, isA<Database>());
    });

    // -------------------------------------------------------------------------
    // Widget Test: Verify that the main menu contains all required buttons.
    // -------------------------------------------------------------------------
    testWidgets('Main Menu buttons exist', (WidgetTester tester) async {
      // Build the MyApp widget.
      await tester.pumpWidget(const MyApp());

      // Verify that the Recipe button is present.
      expect(find.widgetWithText(ElevatedButton, 'Recipe'), findsOneWidget);
      // Verify that the Favorite Recipes button is present.
      expect(find.widgetWithText(ElevatedButton, 'Favorite Recipes'), findsOneWidget);
      // Verify that the Meal Planner button is present.
      expect(find.widgetWithText(ElevatedButton, 'Meal Planner'), findsOneWidget);
      // Verify that the Grocery List button is present.
      expect(find.widgetWithText(ElevatedButton, 'Grocery List'), findsOneWidget);

      // Allow the UI to settle.
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // Widget Test: Verify that tapping the Recipe button navigates to RecipeMenu.
    // -------------------------------------------------------------------------
    testWidgets('on tap recipe button brings recipe menu up', (WidgetTester tester) async {
      // Build the MyApp widget.
      await tester.pumpWidget(const MyApp());

      // Tap the 'Recipe' button.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Recipe'));
      await tester.pumpAndSettle();

      // Verify that the RecipeMenu widget is now displayed.
      expect(find.byType(RecipeMenu), findsOneWidget);
    });
  });
}
