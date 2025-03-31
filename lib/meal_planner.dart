import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Provider;
import 'package:recipe/db_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MealPlanner extends StatefulWidget {
  MealPlanner({super.key});

  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  List<Map<String, dynamic>> recipeNames = [];
  Map<DateTime, List<String>> mealPlan = {};
  Map<String, bool> favoriteSelectedRecipe = {};
  late DateTime _selectedDay = DateTime.now();
  List<String> checked = [];
  late int recipeId;
  var _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getAllRecipeData();
  }

  void _favoritSelection(String recipe, bool? value) {
    setState(() {
      favoriteSelectedRecipe[recipe] = value ?? false;
      if (value == true && !checked.contains(recipe)) {
        checked.add(recipe);
      } else if (value == false) {
        checked.remove(recipe);
      }
    });
  }

  void _clearSelection() {
  setState(() {
    checked.clear();
    favoriteSelectedRecipe.clear();
  });
}

  void _getAllRecipeData() async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    List<Map<String, dynamic>> allNames = await dbHelper.allRecipeNames();
    setState(() {
      recipeNames = allNames;
    });
  }

  Future<void> _getRecipeId(String recipe) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    int? id = await dbHelper.getRecipteNameById(recipe);
    if (id != null) {
      setState(() {
        recipeId = id;
      });
    }
  }

  Future<void> _updateRecipeDate(DateTime _status) async {
    final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: recipeId,
      DatabaseHelper.date: _status.millisecondsSinceEpoch
    };
    final updatedRows = await dbHelper.updateFavoriteStatus(row);
    print("Updated $updatedRows row(s)");
  }

  Future<void> _submit_Meal_Planner_Days()async{
    // Get the selected day and checked recipes
    if(checked.isNotEmpty){
        for(var checked_recipe in checked){
          await _getRecipeId(checked_recipe);
         await  _updateRecipeDate(_selectedDay);
           ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Assigned $checked_recipe to  $_selectedDay'),
        ),
        );
        }
        _clearSelection(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    CalendarFormat _calendarFormat = CalendarFormat.month;
    return Scaffold(
      appBar: AppBar(
        title: Text("Meal Planner"),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                            _selectedDay = DateTime(selectedDay.year,selectedDay.month,selectedDay.day);
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                      ),
                      Text(
                        "Meals for ${_selectedDay.toLocal()}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        children: mealPlan[_selectedDay]?.map((recipe) {
                              return Chip(label: Text(recipe));
                            }).toList() ??
                            [],
                      ),
                    ],
                  ),
                )
          ),

          Expanded(
            child: ListView.builder(
              itemCount: recipeNames.length,
              itemBuilder: (context, index) {
                String name = recipeNames[index][DatabaseHelper.columnName];
                bool value = favoriteSelectedRecipe[name] ?? false;

                return ListTile(
                    title: Text(name),
                    leading: Checkbox(
                      value: value,
                      onChanged: (bool? newValue) {
                        _favoritSelection(name, newValue);
                      },
                    ),
                  );
              },
            ),
          ),
          
          Row(
              children: [
                ElevatedButton(onPressed: (){
                  _submit_Meal_Planner_Days();
                }, 
                child: Text("Submit"))
              ],
            )
        ],
      ),
    );
  }
}