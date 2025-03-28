import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'recipe_details.dart';
import 'recipe_menu.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'recipe_table';
  static const columnId = '_id';
  static const columnName = 'recipe_name';
  static const columnFavorite = 'favorite';
  static const columnCateagory = 'cateagory';
  static const date = 'date';
  static const groceryList = 'grocery_List';
  static const description = 'description';

  late Database _db;

  /* 
   * Initializes the database.
   * - Gets the application document directory.
   * - Opens the database with specified version, onCreate and onUpgrade callbacks.
   * - Resets the database (for development) to remove old data.
   * - Loads the Excel file and fills the database.
   * - Prints the database structure.
   */
  Future<Database> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    // Wipe the database each time (development only)
    await resetDatabase();

    // Load the Excel file and populate the database
    await loadAndStoreRecipes();
    await printDatabaseStructure();
    return _db;
  }

  /* 
   * onCreate: Called when the database is created for the first time.
   * Creates the recipe_table with the defined columns.
   */
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnFavorite INTEGER NOT NULL,
        $columnCateagory TEXT NOT NULL,
        $date INTEGER NOT NULL,
        $groceryList TEXT NOT NULL,
        $description TEXT NOT NULL
      )
    ''');
  }

  /* 
   * onUpgrade: Called when the database needs to be upgraded.
   * Add migration logic here if necessary.
   */
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Add migration logic if needed.
  }

  /* 
   * Reads the Excel file (Recipe_table.xlsx) and extracts recipe data.
   * - Loads the file as bytes and decodes it using the Excel package.
   * - For each sheet, finds a header row (normalizing keys to lowercase) and then processes each data row.
   * - Concatenates multiline fields for description and grocery list.
   * - Maps the normalized keys to the database column names.
   * Returns a list of recipe maps ready for insertion.
   */
  Future<List<Map<String, dynamic>>> readFromExcel() async {
    ByteData data = await rootBundle.load('assets/Recipe_table.xlsx');
    var bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> excelData = [];

    for (var sheet in excel.tables.keys) {
      var rows = excel.tables[sheet]!.rows;
      if (rows.isEmpty) {
        print("No data found in sheet: $sheet");
        continue;
      }

      // Find header row and normalize keys to lowercase.
      Map<int, String> headerIndexToColumnName = {};
      int headerRowIndex = -1;
      for (int i = 0; i < rows.length; i++) {
        var row = rows[i];
        if (row.isNotEmpty && row.any((cell) => cell?.value != null)) {
          headerRowIndex = i;
          for (int j = 0; j < row.length; j++) {
            String colName = row[j]?.value.toString().trim().toLowerCase() ?? '';
            if (colName.isNotEmpty) {
              headerIndexToColumnName[j] = colName;
            }
          }
          print("Identified Header Row ($headerRowIndex): $headerIndexToColumnName");
          break;
        }
      }

      if (headerRowIndex == -1) {
        print("No valid header row found!");
        return [];
      }

      // Process data rows (skip header row)
      for (int i = headerRowIndex + 1; i < rows.length; i++) {
        var row = rows[i];
        if (row.isEmpty || row.every((cell) => cell?.value == null)) {
          print("Skipping empty row: $i");
          continue;
        }

        Map<String, String> rowData = {};
        String multilineDescription = "";
        String multilineGroceryList = "";

        for (int j = 0; j < row.length; j++) {
          if (headerIndexToColumnName.containsKey(j)) {
            String headerName = headerIndexToColumnName[j]!; // already lowercase
            String value = row[j]?.value.toString().trim() ?? '';

            // Concatenate multiline fields.
            if (headerName == "description") {
              multilineDescription += value + "\n";
            } else if (headerName == "grocery list") {
              multilineGroceryList += value + "\n";
            } else {
              rowData[headerName] = value;
            }
          }
        }

        if (multilineDescription.isNotEmpty) {
          rowData["description"] = multilineDescription.trim();
        }
        if (multilineGroceryList.isNotEmpty) {
          rowData["grocery list"] = multilineGroceryList.trim();
        }

        print("Parsed Row Data: $rowData");

        // Map normalized keys to the database column names.
        var recipeToInsert = {
          columnName: rowData['recipe name'] ?? 'Unnamed Recipe',
          columnFavorite: rowData['favorite'] ?? 0,
          columnCateagory: rowData['category'] ?? 'Uncategorized',
          groceryList: rowData['grocery list'] ?? '',
          description: rowData['description'] ?? '',
          date: rowData['date'] ?? DateTime.now().millisecondsSinceEpoch,
        };

        print("Final Recipe Data for Insert: $recipeToInsert");
        excelData.add(recipeToInsert);
      }
    }

    return excelData;
  }

  /* 
   * Debug: Prints the database table structure using PRAGMA table_info.
   */
  Future<void> printDatabaseStructure() async {
    if (_db == null) {
      print("Database is not initialized.");
      return;
    }
    List<Map<String, dynamic>> tableInfo =
        await _db.rawQuery("PRAGMA table_info($table);");
    print("Database Table Structure:");
    for (var column in tableInfo) {
      print(column);
    }
  }

  /* 
   * Checks if a given recipe already exists in the database.
   * The duplicate check is based on recipe_name, cateagory, grocery_List, and description.
   */
  Future<bool> doesRecipeExist(Map<String, dynamic> recipe) async {
    final columnValue = recipe[columnName];
    final categorValue = recipe[columnCateagory];
    final groceryListValue = recipe[groceryList];
    final descriptionValue = recipe[description];

    final List<Map<String, dynamic>> isDuplicate = await _db.query(
      table,
      where:
          '$columnName = ? AND $columnCateagory = ? AND $groceryList = ? AND $description = ?',
      whereArgs: [columnValue, categorValue, groceryListValue, descriptionValue],
    );

    return isDuplicate.isNotEmpty;
  }

  /* 
   * Resets the database by deleting all rows from the recipe_table.
   */
  Future<void> resetDatabase() async {
    await _db.delete(table);
    print("Database reset successfully.");
  }

  /* 
   * Inserts a list of recipes into the database.
   * For each recipe, it checks if the recipe already exists (using doesRecipeExist).
   * If it does not exist, the recipe is inserted.
   */
  void insertExcel(List<Map<String, dynamic>> recipes) async {
    for (var recipe in recipes) {
      print("Checking recipe: ${recipe[columnName]}");
      bool duplicate = await doesRecipeExist(recipe);
      print("Duplicate check for ${recipe[columnName]}: $duplicate");
      if (!duplicate) {
        print("******* Inserting: $recipe");
        await _db.insert(table, recipe);
      } else {
        print("Recipe already exists: ${recipe[columnName]}");
      }
    }
  }

  /* 
   * Loads and stores recipes from the Excel file into the database.
   * It first checks if the table already contains recipes (by counting rows).
   * If there are existing recipes, it skips loading.
   * Otherwise, it reads from the Excel file and inserts the recipes.
   */
  Future<void> loadAndStoreRecipes() async {
    int? count =
        Sqflite.firstIntValue(await _db.rawQuery("SELECT COUNT(*) FROM $table"));
    if (count != null && count > 0) {
      print("Database already has recipes, skipping load.");
      return;
    }

    List<Map<String, dynamic>> excelSheet = await readFromExcel();
    insertExcel(excelSheet);
  }

  /* 
   * Retrieves all recipes (all columns) from the database.
   * Returns a list of maps, where each map represents a recipe.
   */
  Future<List<Map<String, dynamic>>> allRecipes() async {
    List<Map<String, dynamic>> result = await _db.query(table);
    print("All recipes: $result");
    return result;
  }

  /* 
   * Retrieves all favorite recipes (where favorite equals 1) from the database.
   * Returns a list of recipe names.
   */
  Future<List<String>> getFavoriteRecipeNames() async {
    List<Map<String, dynamic>> result = await _db.query(
      table,
      columns: [columnName],
      where: '$columnFavorite = ?',
      whereArgs: [1],
    );
    return result.map((e) => e[columnName] as String).toList();
  }


  /* 
   * Retrieves the recipe ID for a given recipe name.
   * Queries the database for the recipe using the recipe name and returns its ID.
   */
  Future<int?> getRecipteNameById(String recipeName) async {
    List<Map<String, dynamic>> result = await _db.query(
      table,
      columns: [columnId],
      where: '$columnName = ?',
      whereArgs: [recipeName],
    );
    if (result.isNotEmpty) {
      return result.first[columnId] as int;
    }
    return null;
  }

  /* 
   * Updates the favorite status of a recipe in the database.
   * Accepts a row map that must include the recipe ID and the new favorite status.
   * Returns the number of rows updated.
   */
  Future<int> updateFavoriteStatus(Map<String, dynamic> row) async {
    int id = row[columnId];
    return await _db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
}
