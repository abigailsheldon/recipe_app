import 'package:flutter/material.dart';
import 'package:recipe/main.dart';
import 'db_helper.dart';


class RecipeMenu extends StatefulWidget {

  const RecipeMenu ({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();


}
class _Recipe_Menu extends State<RecipeMenu>{
  late int recipeNumber = 0 ;
  // late DatabaseHelper db_helper;
  List<Map<String,dynamic>> recipeNames = [];
  @override
  void initState(){
    super.initState();
    // db_helper = DatabaseHelper();
    _getAllRecipeData();
  

  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold (
      appBar: AppBar(title: const Text ("Recipes")),
      body: recipeNames.isEmpty
        ?const Center(child: CircularProgressIndicator()):
      ListView.builder(
      itemCount: recipeNames.length,
      itemBuilder: (context,index){
        return ElevatedButton(onPressed: (){

        }, child: Text(recipeNames[index][DatabaseHelper.columnName]));

      })

    );
  }
 void _getAllRecipeData() async{
  // int count =  await dbHelper.numberOfRecipeName();
    List<Map<String,dynamic>> allNames = await dbHelper.allRecipeNames();

  setState(() {
    
    //recipeNumber = count;
    recipeNames = allNames;
  });
      
     
       print("recipe count from db : $recipeNumber");
       print("Recipes: $recipeNames");
  }
  // void _getAllRecipes () async{
  //   await db_helper.allRecipeNames();
  //   print(await db_helper.allRecipeNames());

  // }
}