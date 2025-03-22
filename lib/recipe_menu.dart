import 'package:flutter/material.dart';
import 'db_helper.dart';


class RecipeMenu extends StatefulWidget {

  const RecipeMenu ({super.key});

  @override
  State<RecipeMenu> createState() => _Recipe_Menu();


}
class _Recipe_Menu extends State<RecipeMenu>{
  late DatabaseHelper db_helper;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context,index){

      });
  }
}