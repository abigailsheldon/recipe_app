import 'package:flutter/material.dart';
import 'package:recipe/recipe_menu.dart';
import 'db_helper.dart';
import 'package:provider/provider.dart'; // This is needed to use Provider


// Test comment
final dbHelper = DatabaseHelper();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dbHelper.init();
  runApp(Provider<DatabaseHelper>(
      create: (_) => dbHelper, // Providing DatabaseHelper here
      child: MyApp(),
    ),);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(
        
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
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>const RecipeMenu()),

                      );

                    },
                     child: Text(
                            'Recipe',
                            style: TextStyle(color:Colors.blueAccent),
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){ 
                      
                      

                    },
                     child: Text(
                            'Favorites',
                            style: TextStyle(color:Colors.blueAccent),
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){

                    },
                     child: Text(
                            'Meal Planner',
                            style: TextStyle(color:Colors.blueAccent),
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){

                    },
                     child: Text(
                            'Grocery List',
                            style: TextStyle(color:Colors.blueAccent),
                              

                            ),
                ),


              ],

            ),

            
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
