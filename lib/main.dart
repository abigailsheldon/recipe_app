import 'package:flutter/material.dart';

// Test comment

void main() {
  runApp(const MyApp());
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

                    },
                     child: Text(
                            'Recipe',
                            selectionColor: Colors.blueAccent,
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){

                    },
                     child: Text(
                            'Favorites',
                            selectionColor: Colors.blueAccent,
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){

                    },
                     child: Text(
                            'Meal Planner',
                            selectionColor: Colors.blueAccent,
                              

                            ),
                ),
                ElevatedButton(
                    onPressed: (){

                    },
                     child: Text(
                            'Grocery List',
                            selectionColor: Colors.blueAccent,
                              

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
