// pixel_recipe_card.dart
import 'package:flutter/material.dart';

/// A custom pixel-art style recipe card.
/// This widget displays the recipe title in a header area using the Pixelify Sans font,
/// a description, and a button that triggers a callback (e.g., to navigate to a details page).
class PixelRecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onDetailsPressed;

  const PixelRecipeCard({
    Key? key,
    required this.title,
    required this.description,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        // Pixel art style: no rounded corners.
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with recipe title.
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[300],
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'PixelifySans', // Using Pixelify Sans
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // Recipe description.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              description,
              style: const TextStyle(
                fontFamily: 'PixelifySans', // Using Pixelify Sans
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ),
          // "Recipe Details" button.
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: onDetailsPressed,
              child: const Text(
                "Recipe Details",
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
