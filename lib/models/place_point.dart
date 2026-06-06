import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class PlacePoint {
  final String id;
  final String title;
  final String snippet;
  final LatLng position;
  final Color color;

  const PlacePoint({
    required this.id,
    required this.title,
    required this.snippet,
    required this.position,
    this.color = Colors.red,
  });
}