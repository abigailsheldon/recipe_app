import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/favorite_menu.dart';
import 'package:recipe/main.dart';
import 'package:recipe/recipe_details.dart';
import 'db_helper.dart';
import 'package:provider/provider.dart';
import 'package:recipe/recipe_menu.dart';


class RecipeMenu extends StatefulWidget {

  const RecipeMenu ({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();


}
class _Recipe_Menu extends State<RecipeMenu>{
  late int recipeNumber = 0 ;
  late int? recipeId = 0;
  // Favorite recipe status
  late int favoriteStatus = 0;
  // FavoriteRecipe
  Map<String,bool> favoriteSelectedRecipe= {};
  // late DatabaseHelper db_helper;
  List<Map<String,dynamic>> recipeNames = [];
  // List contains recipe names that are unchecked
  List<String> unchecked =[];
  List<String> checked=[];
  @override
  void initState() {
    super.initState();
    final dbhelper = Provider.of<DatabaseHelper>(context, listen: false);
    _getAllRecipeData();
    unchecked = List.from(recipeNames);
    for(var _recipe in List.from(recipeNames)){
        favoriteSelectedRecipe[_recipe] = false;
    }
  }
  void _favoritSelection(String recipe, bool? value) async{
      setState(()  async {
        favoriteSelectedRecipe[recipe] = value ?? false;
        if(value == true){
          if(!checked.contains(recipe)){
            favoriteStatus = 1;
            print("before getRecipeId call****");
            await _getRecipeId(recipe);// Grab id of the recipe that was checked
            print("After RecipeIdcall***");
            checked.add(recipe); // Add selected recipe to checked list
            
            unchecked.remove(recipe); // Remove checked recipe from unchecked recipe list
            // Update the recipe in db to update favorite status for the selected recipe
            
            await _updateFavoriteRecipe(favoriteStatus);

          }
          }else{
            if(!unchecked.contains(recipe)){
              print("check****");
              unchecked.add(recipe);
              // Update recipe favorite status
                favoriteStatus = 0;
              print("before getRecipeId call**** unchecked");
              await _getRecipeId(recipe);
              await _updateFavoriteRecipe(favoriteStatus);
              print("After RecipeIdcall*** unchecked");
              checked.remove(recipe);
            }
          }
      });

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: const Text ("Recipes")),
      body: recipeNames.isEmpty
        ?const Center(child: CircularProgressIndicator()):
      Column(
        children: [
          Expanded(child: 
           ListView.builder(
          
      itemCount: recipeNames.length,
      itemBuilder: (context,index){
        String name = recipeNames[index][DatabaseHelper.columnName];
        return ListTile(
          leading: Checkbox(
              value: favoriteSelectedRecipe[name] ??false , 
              onChanged: (bool?value){
                // Method to handle selected checkbox
                _favoritSelection(name, value);
               }
          ),
          title: ElevatedButton(
          onPressed: (){
        }, 
          child: Text(name, 
                      style: TextStyle(color: Colors.blueAccent))
        ),
        subtitle: ElevatedButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RecipeDetailPage(recipe: recipeNames[index])));
          }, child: Text("Recipe Description")),
        );
          
      })),
      Padding(padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoriteMenu(),)
            );
          }, child: Text("view favorite list")),)
        ]
      ),

    );
  }
 
  Future<void> _getAllRecipeData() async{
  // int count =  await dbHelper.numberOfRecipeName();
    List<Map<String,dynamic>> allNames = await dbHelper.allRecipeNames();
    setState(() {
    //recipeNumber = count;
    recipeNames = allNames;
  });
     
       print("*****recipe count from db **********: ${recipeNames.length}");
       print("Recipes: $recipeNames");
  }

  Future<void> _getRecipeId(String recipe) async{
    int? _id = await dbHelper.getRecipteNameById(recipe);
    setState(() {
      recipeId = _id;
    });
  }

  Future<void> _updateFavoriteRecipe(int _status) async{
    Map<String,dynamic> row = {
              DatabaseHelper.columnId: recipeId,
              DatabaseHelper.columnFavorite: favoriteStatus
            };
            final updatedRows =await dbHelper.updateFavoriteStatus(row);
            print("Updated $updatedRows row(s****)");
  }

  // void _getAllRecipes () async{
  //   await db_helper.allRecipeNames();
  //   print(await db_helper.allRecipeNames());
  // }
  
}