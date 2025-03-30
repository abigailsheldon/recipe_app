import 'package:flutter/material.dart';

class MealPlanner extends StatefulWidget {
  MealPlanner({super.key});
  @override 
  _Meal_PlannerState createState () => _Meal_PlannerState();

}
class _Meal_PlannerState extends State<MealPlanner> {
  List<Map<String,dynamic>> recipeNames = [];
  @override 

@override
Widget build(BuildContext context){
  return Scaffold(
    appBar: AppBar(
      title: Text("Meal Planner"),
    ),
    body: SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  itemBuilder: (context,index){
                    
                  }
              )
              ),

          ],
        ),
        
      ),
        
      
    ),
  );
}
}