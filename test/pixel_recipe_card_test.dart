// test/pixel_recipe_card_test.dart
// ---------------------------------------------------------------------------
// This file contains a widget test for the PixelRecipeCard widget.
// It verifies that the widget displays the title, description,
// and that tapping the "Recipe Details" button correctly triggers the callback.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe/pixel_recipe_card.dart';

void main() {
  testWidgets('PixelRecipeCard displays title, description, and button callback',
      (WidgetTester tester) async {
    // Define a boolean to track if the details button callback is executed.
    bool buttonPressed = false;

    // Build the PixelRecipeCard widget inside a MaterialApp.
    await tester.pumpWidget(MaterialApp(
      home: PixelRecipeCard(
        title: 'Test Recipe',
        description: 'Test Description',
        // When the button is pressed, set buttonPressed to true.
        onDetailsPressed: () {
          buttonPressed = true;
        },
      ),
    ));

    // Verify that title text is displayed.
    expect(find.text('Test Recipe'), findsOneWidget);
    // Verify that description text is displayed.
    expect(find.text('Test Description'), findsOneWidget);

    // Find "Recipe Details" button by looking for its text.
    final detailsButtonFinder = find.text('Recipe Details');
    expect(detailsButtonFinder, findsOneWidget);

    // Tap the "Recipe Details" button.
    await tester.tap(detailsButtonFinder);
    // Rebuild the widget after the state change.
    await tester.pumpAndSettle();

    // Check if the callback was executed by verifying that buttonPressed is now true.
    expect(buttonPressed, isTrue);
  });
}
