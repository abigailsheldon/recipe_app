import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'db_helper.dart';
import 'recipe_menu.dart';
import 'styles.dart';

/* 
 * FavoriteMenu Page
 * 
 * Displays a list of favorite recipe names using consistent pixel-art styling.
 * If no favorites exist, a message is shown using the pixel font.
 */
class FavoriteMenu extends StatefulWidget {
  final List<String> recipe_Name;
  const FavoriteMenu({super.key, required this.recipe_Name});

  @override
  _FavoriteMenuState createState() => _FavoriteMenuState();
}

class _FavoriteMenuState extends State<FavoriteMenu> {
  // Define a common pixel-art decoration for list items.
  final BoxDecoration pixelDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black, width: 2),
    borderRadius: BorderRadius.zero,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Menu", style: pixelTitleTextStyle),
      ),
      body: widget.recipe_Name.isEmpty
          ? const Center(
              child: Text(
                "No favorites saved.",
                style: pixelTitleTextStyle,
              ),
            )
          : ListView.builder(
              itemCount: widget.recipe_Name.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: pixelDecoration,
                  child: Text(
                    widget.recipe_Name[index],
                    style: pixelButtonTextStyle,
                  ),
                );
              },
            ),
    );
  }
}
