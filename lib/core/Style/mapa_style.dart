import 'package:flutter/material.dart';

class MapaStyle {
  // Info Box
  static BoxDecoration infoBox = BoxDecoration(
    color: Colors.yellowAccent,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const TextStyle infoText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const EdgeInsets infoPadding =
      EdgeInsets.symmetric(vertical: 6, horizontal: 12);

  // Botão Origem
  static final ButtonStyle originButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: const TextStyle(fontSize: 12),
  );

  // Botão Destino
  static final ButtonStyle destinationButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: const TextStyle(fontSize: 12),
  );
}