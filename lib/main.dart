import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'favorite_menu.dart';
import 'meal_planner.dart';
import 'grocery_list_model.dart';
import 'collected_grocery_list.dart';
import 'recipe_menu.dart';
import 'styles.dart';

final dbHelper = DatabaseHelper();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dbHelper.init();
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => dbHelper),
        ChangeNotifierProvider<GroceryListModel>(
            create: (_) => GroceryListModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        fontFamily: 'PixelifySans',
      ),
      home: const MyHomePage(title: 'Recipe App Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: pixelTitleTextStyle.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0078D7),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(85.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              
              // Navigation buttons (positioned at the top)
              ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RecipeMenu()),
                  );
                },
                child: Text('Recipe', style: pixelButtonTextStyle),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MealPlanner()));
                },
                child: Text('Meal Planner', style: pixelButtonTextStyle),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CollectedGroceryListPage()),
                  );
                },
                child: Text('Grocery List', style: pixelButtonTextStyle),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () async {
                  final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
                  List<String> favs = await dbHelper.getFavoriteRecipeNames();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoriteMenu(),
                    ),
                  );
                },
                child: Text('Favorite Recipes', style: pixelButtonTextStyle),
              ),
              const SizedBox(height: 150), // Extra spacing before download buttons

              // Row containing the download buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: pixelButtonStyle,
                      onPressed: () async {
                        final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
                        File file = await dbHelper.downloadFavoriteRecipes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Favorite recipes downloaded to: ${file.path}")),
                        );
                      },
                      child: Text('Download Favorite Recipes', style: pixelButtonTextStyle),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: pixelButtonStyle,
                      onPressed: () async {
                        final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
                        File file = await dbHelper.downloadMealPlannerData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Meal planner data downloaded to: ${file.path}")),
                        );
                      },
                      child: Text('Download Meal Planner', style: pixelButtonTextStyle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
