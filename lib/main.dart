import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'favorite_menu.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
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
        title: Text(widget.title, style: pixelTitleTextStyle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[ 
              // Navigate to Recipe Menu Page
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
              // Placeholder for future Meal Planner feature
              ElevatedButton(
                style: pixelButtonStyle,
                onPressed: () {
                  // Add functionality for Meal Planner here.
                },
                child: Text('Meal Planner', style: pixelButtonTextStyle),
              ),
              const SizedBox(height: 16),
              // Navigate to Collected Grocery List Page
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
            ],
          ),
        ),
      ),
    );
  }
}
