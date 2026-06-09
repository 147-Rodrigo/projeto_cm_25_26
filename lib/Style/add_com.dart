import 'package:flutter/material.dart';

class AddComStyles {
  static const EdgeInsets pagePadding = EdgeInsets.only(
    left: 16,
    right: 16,
    top: 20,
    bottom: 20,
  );

  static InputDecoration textFieldDecoration = InputDecoration(
    hintText: "Escreve algo...",
    filled: true,
    fillColor: Colors.grey.shade100,
    contentPadding: const EdgeInsets.all(12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  // botão consistente com tema
  static ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );
}