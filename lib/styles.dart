import 'package:flutter/material.dart';

// Pixel-style font for titles and buttons
const TextStyle pixelTitleTextStyle = TextStyle(
  fontFamily: 'PixelifySans',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const TextStyle pixelButtonTextStyle = TextStyle(
  fontFamily: 'PixelifySans',
  fontSize: 12,
  color: Colors.black,
);

final ButtonStyle pixelButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.grey[300],
  elevation: 4,
  shadowColor: Colors.grey[600],
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
    side: BorderSide(color: Colors.black, width: 2),
  ),
);
