import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/main.dart';
import 'db_helper.dart';
import 'package:provider/provider.dart';


class RecipeMenu extends StatefulWidget {

  const RecipeMenu ({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();


}
class _Recipe_Menu extends State<RecipeMenu>{
  late int recipeNumber = 0 ;
  late int? recipeId = 0;
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
      setState(() {
        favoriteSelectedRecipe[recipe] = value ?? false;
        if(value == true){
          if(!checked.contains(recipe)){
            _getRecipeId(recipe);
            checked.add(recipe);
            
            unchecked.remove(recipe);

          }
          else{
            if(!unchecked.contains(recipe)){
              unchecked.add(recipe);
              checked.remove(recipe);
            }
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
      
     
       print("*****recipe count from db **********: ${recipeNames.length}");
       print("Recipes: $recipeNames");
  }
  void _getRecipeId(String recipe) async{
    int? _id = await dbHelper.getRecipteNameById(recipe);
    setState(() {
      recipeId = _id;

      
    });
    
  }
  // void _getAllRecipes () async{
  //   await db_helper.allRecipeNames();
  //   print(await db_helper.allRecipeNames());

  // }
}