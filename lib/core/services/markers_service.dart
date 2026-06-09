import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../shared/data/places_data.dart';

class MarkersService {
  static Set<Marker> buildMarkers(
    Function(LatLng destino, String id) onSelect,
    String? selectedId,
  ) {
    return places.map((place) {
      final isSelected = place.id == selectedId;

      return Marker(
        markerId: MarkerId(place.id),
        position: place.position,
        infoWindow: InfoWindow(
          title: place.title,
          snippet: place.snippet,
        ),

        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected
              ? BitmapDescriptor.hueBlue
              : BitmapDescriptor.hueRed,
        ),

        onTap: () => onSelect(place.position, place.id),
      );
    }).toSet();
  }
}