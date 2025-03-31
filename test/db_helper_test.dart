// test/db_helper_test.dart
// ---------------------------------------------------------------------------
// This file contains unit tests for the DatabaseHelper class.
// It verifies that the database initializes properly and that duplicate
// detection and insertion logic work as expected.
// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe/db_helper.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// A fake path provider that correctly extends the platform interface.
class FakePathProvider extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    // Return a temporary directory path.
    return Directory.systemTemp.path;
  }
}

void main() {
  // Ensure the test binding is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();
  // Initialize sqflite ffi so that databaseFactory is set.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // Override the platform implementation for path_provider.
  setUpAll(() {
    PathProviderPlatform.instance = FakePathProvider();
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    // Initialize a new instance of DatabaseHelper before each test.
    setUp(() async {
      dbHelper = DatabaseHelper();
      // Initialize the database; this will also reset and load recipes.
      await dbHelper.init();
    });

    test('Database initialization and recipe retrieval', () async {
      // Retrieve all recipes from the database.
      List<Map<String, dynamic>> recipes = await dbHelper.allRecipeNames();
      // Expect that the recipes list is not null and is a List.
      expect(recipes, isNotNull);
      expect(recipes, isA<List<Map<String, dynamic>>>());
    });

    test('Duplicate recipe check and insertion', () async {
      // Create a dummy recipe map.
      Map<String, dynamic> dummyRecipe = {
        DatabaseHelper.columnName: 'Test Recipe',
        DatabaseHelper.columnFavorite: 0,
        DatabaseHelper.columnCateagory: 'Test',
        DatabaseHelper.groceryList: 'Ingredient1\nIngredient2',
        DatabaseHelper.description: 'Test description',
        DatabaseHelper.date: DateTime.now().millisecondsSinceEpoch,
      };

      // Before insertion, the duplicate check should return false.
      bool existsBefore = await dbHelper.doesRecipeExist(dummyRecipe);
      expect(existsBefore, isFalse);

      // Insert the dummy recipe.
      await dbHelper.insertExcel([dummyRecipe]);

      // After insertion, the duplicate check should return true.
      bool existsAfter = await dbHelper.doesRecipeExist(dummyRecipe);
      expect(existsAfter, isTrue);
    });
  });
}
