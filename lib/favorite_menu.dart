import 'package:flutter/material.dart';
import 'package:recipe/recipe_menu.dart';

class FavoriteMenu extends StatefulWidget{
  final List<String> recipe_Name;
  FavoriteMenu({super.key, required this.recipe_Name});
   @override
   _FavoriteMenuState createState() => _FavoriteMenuState();
}
class _FavoriteMenuState extends State<FavoriteMenu>{
  @override
  void initState() {
    super.initState();
  }
  
  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: Text("Favorite Menu",
                    style: TextStyle(color: Colors.blueAccent),),

      ),
      body: widget.recipe_Name.isEmpty? const Center(child: CircularProgressIndicator()):
      ListView.builder(
          itemCount: widget.recipe_Name.length,
          itemBuilder: (context,index){
            return ListTile(
              title: Text(widget.recipe_Name[index]),

            );
          }
      ),
    );
  }
}