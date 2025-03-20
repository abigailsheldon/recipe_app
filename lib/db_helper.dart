import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper{

  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;
  static const table = 'recipe_table';
  static const columnId = '_id';
  static const columnName = 'recipe_name';
  static const columnFavorite= 'favorite';
  static const columnCateagory= 'cateagory';
  static const date ='date';
  late Database _db;
  Future<void> init()async{
    final DocumentBoundary =  await getApplicationDocumentsDirectory();
    final path = join(DocumentBoundary.path,_databaseName);
    await openDatabase(path,version: _databaseVersion,onCreate: _onCreate);



  }
  Future _onCreate (Database db, int version ) async{
    await db.execute('''
                    Create Table $table(
                    $columnName TEXT NOT NULL,
                    $columnId Integer Primary Key AUTOINCREMENT,
                    $columnFavorite BOOL NOT NULL,
                    $columnCateagory TEXT NOT NULL,
                    $date INTEGER NOT NULL
                    )''');
  }



}