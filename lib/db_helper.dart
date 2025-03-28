import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
class DatabaseHelper{

  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'recipe_table';
  static const columnId = '_id';
  static const columnName = 'recipe_name';
  static const columnFavorite= 'favorite';
  static const columnCateagory= 'cateagory';
  static const date ='date';
  static const groceryList = 'grocery_List';
  static const description= 'description';
  late Database _db;
  Future<Database> init()async{
    final DocumentBoundary =  await getApplicationDocumentsDirectory();
    final path = join(DocumentBoundary.path,_databaseName);
    _db =await openDatabase(path,version: _databaseVersion,onCreate: _onCreate);
    loadAndStoreRecipes();
    await printDatabaseStructure();

    return _db;

  }
  Future _onCreate (Database db, int version ) async{
    await db.execute('''
                    Create Table $table(
                    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
                    $columnName TEXT NOT NULL,
                    $columnFavorite INTEGER NOT NULL, -- Using INTEGER for boolean (0 or 1)
                    $columnCateagory TEXT NOT NULL,
                    $date INTEGER NOT NULL,
                    $groceryList TEXT NOT NULL,
                    $description TEXT NOT NULL
                    )''');
  }
  // Future<List<Map<String,String>>> readFromExcel() async{
  //   //loading excel file from assets
  //   ByteData data =await rootBundle.load('assets/Recipe_table.xlsx');
  //     //Read the excel file 
  //     var bytes = data.buffer.asUint8List();

  //      print("Loaded bytes: ${bytes.sublist(0, 100)}");
  //     var excel = Excel.decodeBytes(bytes);//loads excel worksheet
  //       print("Excel file loaded successfully!");

  //     List <Map<String,String>> _excel_data = [];

  //     for(var table in excel.tables.keys){//iterating over  each worksheet in excel file
  //       print("Sheet Name: $table");
  //       var rows =excel.tables[table]!.rows;//The worksheet object
  //       print("Total Rows Found: ${rows.length}");
  //       if (rows.isEmpty) {
  //     print("No data found in sheet: $table");
  //     continue;
      
  //   }
  //    // Step 1: Find first non-empty row to use as column headers
  //   Map<int, String> columnIndexToName = {};
  //   int headerRowIndex = -1;


  //       //skip the first row (header)
  //       for(int i =0;i <rows.length;i++){
  //         var cellData = rows[i]; //iterating over the excel worksheet object
  //           print("Raw row data at index $i: ${cellData.map((cell) => cell?.value).toList()}");
  //         if(cellData.isNotEmpty && cellData.any((cell)=> cell?.value != null)){

  //         }
  //         if(cellData.isEmpty || cellData[2] == null){
  //           print("Skipping empty row: $i");
  //           continue;// skips empty rows
  //         }
  //         print("Processing row $i: ${cellData.map((cell) => cell?.value.toString()).toList()}");


  //         _excel_data.add({
  //           columnName:  cellData[0]?.value.toString() ?? '',
  //           columnCateagory: cellData[1]?.value.toString() ?? '',
  //           groceryList: cellData[2]?.value.toString() ?? '',
  //           description: cellData[3]?.value.toString() ?? '',
            
  //         });
  //         print("Excel Row: $_excel_data");

  //       }


  //       // for(var row in excel.tables[table]!.rows){
  //       //         List<String> filteredRow = row.
  //       //         where((cell)=>cell!=null)
  //       //         .map((cell)=> cell!.value.toString())
  //       //         .toList();
  //       //         if (filteredRow.isNotEmpty){
  //       //           _excel_data.add(filteredRow);
  //       //         }
  //       // }
  //       // break;
        
  //     }
  //     print("Total Recipes Read: ${_excel_data.length}");
  //     return _excel_data;
    


  // }
  Future<List<Map<String, dynamic>>> readFromExcel() async {
  ByteData data = await rootBundle.load('assets/Recipe_table.xlsx');
  var bytes = data.buffer.asUint8List();
  print("size of excel worksheet***** $bytes");
  var excel = Excel.decodeBytes(bytes);

  List<Map<String, dynamic>> _excelData = [];

  for (var sheet in excel.tables.keys) {
    var rows = excel.tables[sheet]!.rows;//this is a single worksheet object

    if (rows.isEmpty) {
      print("No data found in sheet: $sheet");
      continue;
    }

    // Step 1: Find first non-empty row to use as column headers
    Map<int, String> headerIndexToColumnName = {};//take in the index of each column in the header 
    int headerRowIndex = -1;

    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      if (row.isNotEmpty && row.any((cell) => cell?.value != null)) { //checking to see if current row is not empty and checking each cell in the row to see if any cell isn't null
        headerRowIndex = i; // marks the header index
        for (int j = 0; j < row.length; j++) {
          String columnName = row[j]?.value.toString().trim() ?? '';
          if (columnName.isNotEmpty) {
            headerIndexToColumnName[j] = columnName; // Map column index to header name
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

    // Step 2: Read Data Rows (Skipping the header row)
    for (int i = headerRowIndex + 1; i < rows.length; i++) {
      var row = rows[i];
      if (row.isEmpty || row.every((cell) => cell?.value == null)) {
        print("Skipping empty row: $i");
        continue;
      }

      Map<String, String> rowData = {};
      String _description = "";
      String _groceryList ="";

      for (int j = 0; j < row.length; j++) {
        if (headerIndexToColumnName.containsKey(j)) {
          String headerName = headerIndexToColumnName[j]!; // Get header column name
          String value = row[j]?.value.toString().trim() ?? ''; //gettign the data from each row after the header

          // Check for multiline fields (concatenate data)
          if (headerName.trim().toLowerCase() == "description") {
            _description += value + "\n";
          } else if (headerName.trim().toLowerCase() == "grocery list" ){
               _groceryList += value + "\n";
          } else {
            rowData[headerName] = value;
          }
        }
      }

      // Add multi-line fields (after trimming excess newline)
      if (_description.isNotEmpty) {
        rowData["Description"] = _description.trim();
      }
      if(_groceryList.isNotEmpty){
         rowData["Grocery List"] = _groceryList.trim();
      }

      print("Parsed Row Data: $rowData");

      // Create the properly formatted recipe object with defaults
      var recipeToInsert = {
        columnName: rowData['Recipe Name'] ?? 'Unnamed Recipe',  // Default if missing
        columnFavorite: rowData['favorite'] ?? 0,  // Default to 0 if favorite is not provided
        columnCateagory: rowData['Category'] ?? 'Uncategorized',  // Default if not provided
        groceryList: rowData['Grocery List'] ?? '',  // Default empty string if missing
        description: rowData['Description'] ?? '',  // Default empty string if missing
        date: rowData['date'] ?? DateTime.now().millisecondsSinceEpoch,  // Default to current timestamp
      };

      print("Final Recipe Data for Insert: $recipeToInsert");
      _excelData.add(recipeToInsert);
    }
  }

  return _excelData;
}




Future<void> printDatabaseStructure() async {
  if (_db == null) {
      print("Database is not initialized.");
      return;
    }

  // Get the table structure
  List<Map<String, dynamic>> tableInfo = await _db.rawQuery("PRAGMA table_info($table);");

  print("Database Table Structure:");
  for (var column in tableInfo) {
    print(column);
  }
}
//check if recipe has been inserted already 
Future<bool> doesRecipeExist(Map<String, dynamic> recipe) async {
  
  
  final columnValue = recipe[columnName];
  final categorValue = recipe[columnCateagory];
  final decriptionValue = recipe[description];
  final dateValue = recipe[date];
  final groceryListValue = recipe[groceryList];
  
  print("Checking recipe with values:");
  print("  Name: $columnValue");
  print("  Category: $categorValue");
  print("  Description: $decriptionValue");
  print("  Date: $dateValue");
  print("  Grocery List: $groceryListValue");

  final List<Map<String, dynamic>> isduplicate = await _db.query(
    table,
    where: '$columnName = ? AND $columnCateagory = ? AND $groceryList= ? AND $description = ?',
    whereArgs: [
      columnValue,
      categorValue,
      groceryListValue,
      decriptionValue,
    ],
  );

  print("Query Result: $isduplicate");

  if (isduplicate.isNotEmpty) {
    print("Recipe already exists: $columnValue");
    return true;
  }

  print("No duplicate found.");
  
  return false;
}

Future<void> resetDatabase() async {
  // Delete all the records in the table
  await _db.delete(table);

  print("Database reset successfully.");
}


//update method to update the database the favorite column in db
Future<int> updateFavoriteStatus(Map<String,dynamic> row) async {
    int id = row[columnId];
    
    // for(var singrow in test){
    //   print("status query: ${singrow[columnId]}***");
    int result = await _db.update(table, row,where: '$columnId = ?', whereArgs: [id]);
    List<Map<String,dynamic>> test = await _db.query(table,columns: [columnFavorite],where: '$columnId = ?', whereArgs:[id] );
    print("testing query to see favorite status : $test****");
    return result;



}
//method to get recipe id 
Future<int?> getRecipteNameById (String _recipeName) async{
  List<Map<String,dynamic>> id = await _db.query(table,columns: [columnId] ,where: '$columnName = ?', whereArgs: [_recipeName]);
  print("this is the id number for  $_recipeName *** :   ${id.first[columnId] as int}");
  if(id.isNotEmpty){
    return id.first[columnId] as int;
  }
  return null;
}

  void insertExcel(List<Map<String, dynamic>> _recipe) async {
  //await resetDatabase();

  for (var recipe in _recipe) {
    // Print the recipe being checked
    print("Checking recipe: ${recipe['recipe_name']}");
    
    bool duplicate = await doesRecipeExist(recipe); // This is where the duplicate check happens

    // Debug print after calling the duplicate check
    print("Duplicate check for ${recipe['recipe_name']}: $duplicate");

    if (!duplicate) {
      print("*******Inserting****: $recipe"); 
      await _db.insert(table, recipe);
    } else {
      print('Recipe already exists: ${recipe['recipe_name']}');
    }
  }
}

  Future<void> loadAndStoreRecipes() async{
    List<Map<String, dynamic>> _excel_sheet = await readFromExcel();
     insertExcel(_excel_sheet);
  }
  // Future<int> numberOfRecipeName () async{
  //    var number =Sqflite.firstIntValue( await _db.rawQuery('SELECT COUNT (*) FROM $table WHERE $columnName = ?', [columnName]));
  //    print("there are $number recipes!!!");
  //    return number??0;


  // }
  Future<List<Map<String,dynamic>>> allRecipeNames () async{
     List<Map<String,dynamic>> result = await _db.query(table,columns:[columnName]);
     print("this is the allrecipenames query $result");
     List<Map<String, dynamic>> testQuery = await _db.rawQuery('SELECT recipe_name FROM $table');
print("Recipe Names: $testQuery");

    return result;
  }
  
  



}