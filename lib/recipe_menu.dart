import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/favorite_menu.dart';
import 'package:recipe/main.dart';
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
  //favorite recipe status
  late int favoriteStatus = 0;
  //favoriteRecipe
  Map<String,bool> favoriteSelectedRecipe= {};
  // late DatabaseHelper db_helper;
  List<Map<String,dynamic>> recipeNames = [];
  // List contains recipe names that are unchecked
  List<String> unchecked =[];
  List<String> checked=[];
  @override
  void initState(){
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
            _getRecipeId(recipe);//grab id of the recipe that was checked
            print("After RecipeIdcall***");
            checked.add(recipe); //add selected recipe to checked list
            
            unchecked.remove(recipe); // remove checked recipe from unchecked recipe list
            // update the recipe in db to update favorite status for the selected recipe
            
            _updateFavoriteRecipe(favoriteStatus);

          }
          }else{
            if(!unchecked.contains(recipe)){
              print("check****");
              unchecked.add(recipe);
              // update recipe favorite status
            
                

                favoriteStatus = 0;
              print("before getRecipeId call**** unchecked");
              _getRecipeId(recipe);
              _updateFavoriteRecipe(favoriteStatus);
              print("After RecipeIdcall*** unchecked");

              checked.remove(recipe);
            }
          }

        
        
      });

  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold (
      appBar: AppBar(title: const Text ("Recipes")),
      body: recipeNames.isEmpty
        ?const Center(child: CircularProgressIndicator()):
      Column(
        // mainAxisAlignment: MainAxisAlignment.center,
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
                //method to handle selected checkbox
                _favoritSelection(name, value);
                

               }
          ),
          title: ElevatedButton(
          
          onPressed: (){

        }, 
          child: Text(name, 
                      style: TextStyle(color: Colors.blueAccent))
        )
        );
          
      })),
      Padding(padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoriteMenu(recipe_Name: checked),)
            );
          }, child: Text("view favorite list")),)
        
        ]
       
      ),
        
      
      

    );
  }
 void _getAllRecipeData() async{
  // int count =  await dbHelper.numberOfRecipeName();
    List<Map<String,dynamic>> allNames = await dbHelper.allRecipeNames();

  setState(() {
    
    //recipeNumber = count;
    recipeNames = allNames;
  });
      
     
       print("*****recipe count from db **********: ${recipeNames.length}");
       print("Recipes: $recipeNames");
  }
  void _getRecipeId(String recipe) async{
    int? _id = await dbHelper.getRecipteNameById(recipe);
    setState(() {
      recipeId = _id;

      
    });
    
  }
  void _updateFavoriteRecipe(int _status) async{
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