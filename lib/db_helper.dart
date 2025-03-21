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
  Future<void> init()async{
    final DocumentBoundary =  await getApplicationDocumentsDirectory();
    final path = join(DocumentBoundary.path,_databaseName);
    _db =await openDatabase(path,version: _databaseVersion,onCreate: _onCreate);
    loadAndStoreRecipes();
    await printDatabaseStructure();



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
  Future<List<Map<String,String>>> readFromExcel() async{
    //loading excel file from assets
    ByteData data =await rootBundle.load('assets/Recipe_table.xlsx');
      //Read the excel file 
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);//loads excel worksheet

      List <Map<String,String>> _excel_data = [];

      for(var table in excel.tables.keys){//iterating over  each worksheet in excel file

        var rows =excel.tables[table]!.rows;//The worksheet object

        //skip the first row (header)
        for(int i =1;i <rows.length;i++){
          var cellData = rows[i]; //iterating over the excel worksheet object
          if(cellData.isEmpty || cellData[0] == null)continue;// skips empty rows


          _excel_data.add({
            columnName:  cellData[0]?.value.toString() ?? '',
            columnCateagory: cellData[1]?.value.toString() ?? '',
            groceryList: cellData[2]?.value.toString() ?? '',
            description: cellData[3]?.value.toString() ?? '',
            
          });

        }


        // for(var row in excel.tables[table]!.rows){
        //         List<String> filteredRow = row.
        //         where((cell)=>cell!=null)
        //         .map((cell)=> cell!.value.toString())
        //         .toList();
        //         if (filteredRow.isNotEmpty){
        //           _excel_data.add(filteredRow);
        //         }
        // }
        // break;
        
      }
      return _excel_data;
    


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



  void insertExcel(List<Map<String,dynamic>> _recipe) async{
    for(var recipe in _recipe){
      await _db.insert(table, recipe);
    }
    //return await _db.insert(table, row);
  }
  Future<void> loadAndStoreRecipes() async{
    List<Map<String,String>> _excel_sheet = await readFromExcel();
     insertExcel(_excel_sheet);
  }
  



}