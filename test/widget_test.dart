import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe/db_helper.dart';
import 'package:recipe/recipe_menu.dart';
import 'package:recipe/main.dart';
import 'package:sqflite/sqlite_api.dart' show Database;
import 'package:mocktail/mocktail.dart';

// Mock class for Database (Mocktail)
class MockDatabase extends Mock implements Database {}

// Mock class for DatabaseHelper
class MockDatabaseHelper extends Mock implements DatabaseHelper {
  late Database _db;

  @override
  Future<Database> init() async {
    _db = MockDatabase(); // Return a mock database instance
    return _db;
  }

  // Mock the `query` method to simulate data returned from the database
  @override
  Future<List<Map<String, dynamic>>> query(String table, {List<String>? columns}) async {
    // Mock data for testing
    return [
      {'recipe_name': 'pancakes'},
      {'recipe_name': 'spaghetti'}
    ];
  }
}

void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  // Register the fallback value for mocktail
  setUpAll(() {
    registerFallbackValue(MockDatabase()); // Mocktail fallback for Database type
  });

  setUp(() {
    // Initialize mock instances
    mockDatabaseHelper = MockDatabaseHelper(); // Use MockDatabaseHelper here
    mockDatabase = MockDatabase();

    // Mock methods from DatabaseHelper and Database
    when(() => mockDatabase.transaction(any())).thenAnswer((_) async => {});
    when(() => mockDatabase.query(any(), columns: any(named: 'columns'))).thenAnswer((_) async => [
      {'recipe_name': 'pancakes'},
      {'recipe_name': 'spaghetti'}
    ]);
    // Mock the init method to return a mock database instance
    when(() => mockDatabaseHelper.init()).thenAnswer((_) async => mockDatabase);
  });

  group('Main Menu test', () {
    test('Check Database initialized', () async {
      // Test if the database helper is correctly initialized
      final db = await mockDatabaseHelper.init();
      expect(db, isA<Database>());
    });

    testWidgets('Main Menu buttons exist', (WidgetTester tester) async {
      // Build the app and trigger a frame
      await tester.pumpWidget(const MyApp());

      // Test to find the buttons for Recipes, Favorites, Meal Planner, Grocery List
      expect(find.widgetWithText(ElevatedButton, 'Recipe'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Favorites'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Meal Planner'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Grocery List'), findsOneWidget);

      // Wait for the widgets to settle after any changes
      await tester.pumpAndSettle();
    });

    testWidgets('on tap recipe button brings recipe menu up', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Tap the 'Recipe' button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Recipe'));
      await tester.pumpAndSettle();

      // Verify that the RecipeMenu widget is displayed after the tap
      expect(find.byType(RecipeMenu), findsOneWidget);
    });
  });
}
