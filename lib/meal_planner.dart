import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/db_helper.dart';
import 'package:recipe/main.dart';
import 'package:recipe/recipe_menu.dart';
import 'package:table_calendar/table_calendar.dart';
class MealPlanner extends StatefulWidget {
  MealPlanner({super.key});
  @override 
  _Meal_PlannerState createState () => _Meal_PlannerState();

}
class _Meal_PlannerState extends State<MealPlanner> {
  List<Map<String,dynamic>> recipeNames = [];
  late DateTime _selectedDay = DateTime.now();
  var _focusedDay = DateTime.now();
  //late DatabaseHelper dbhelper ;
  @override 
void initState(){
    super.initState();
    final dbhelper = Provider.of<DatabaseHelper>(context, listen: false);
    _getAllRecipeData();
    

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


@override
Widget build(BuildContext context){
  CalendarFormat _calendarFormat = CalendarFormat.month;
  return Scaffold(
    appBar: AppBar(
      title: Text("Meal Planner"),
    ),
    body: SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
             TableCalendar(
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay; // update `_focusedDay` here as well
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                      ),
                    
            Flexible(
              child: ListView.builder(
                  itemCount: recipeNames.length,
                  itemBuilder: (context,index){
                    return DragTarget<Map<String,dynamic>>(
                      onAcceptWithDetails: (details) {
                    setState(() {
                      recipeNames[index][DatabaseHelper.date] = details.data["task"];
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assigned ${details.data["task"]} to $_selectedDay'),
                      ),
                    );
                    
                  },
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                     
                      child: ListTile(
                        title: Text(
                          recipeNames[index][DatabaseHelper.columnName],
                          selectionColor: Colors.red,)
                          ,
                      )
                    );
              
                  }
              );
                  }
              ),
            )
              

          ],
        ),
        
      ),
        
      
    ),
  );
}
}