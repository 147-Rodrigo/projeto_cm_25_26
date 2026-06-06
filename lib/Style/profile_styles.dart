import 'package:flutter/material.dart';

class ProfileStyles {
  // cores
  static const Color cardColor = Color.fromRGBO(171, 255, 156, 1);
  static const Color primaryButtonColor = Colors.green;

  // text styles
  static const TextStyle labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle valueStyle = TextStyle(
    fontSize: 16,
    color: Colors.black,
  );

  // decoration (tipo CSS class)
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(15),
  );

  static ButtonStyle logoutButton = ElevatedButton.styleFrom(
    backgroundColor: primaryButtonColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}