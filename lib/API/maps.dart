import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:projeto/services/directions_model.dart';
import 'package:projeto/services/directions_repository.dart';
import 'package:projeto/services/markers_service.dart';

import 'package:projeto/Style/mapa_style.dart';

class Maps extends StatefulWidget {
  const Maps({super.key});

  @override
  State<Maps> createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  GoogleMapController? _googleMapController;

  LatLng? _origin;
  Marker? _originMarker;

  Marker? _destination;
  Directions? _info;

  String? _selectedMarkerId;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(38.523111, -8.839333),
    zoom: 11.5,
  );

  Future<void> _setOrigin(LatLng pos) async {
    setState(() {
      _origin = pos;

      _originMarker = Marker(
        markerId: const MarkerId('origin'),
        position: pos,
        infoWindow: const InfoWindow(title: 'Origem'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );

      _destination = null;
      _info = null;
      _selectedMarkerId = null;
    });
  }

  Future<void> _selectDestination(LatLng pos) async {
    if (_origin == null) return;

    setState(() {
      _destination = Marker(
        markerId: const MarkerId('destination'),
        position: pos,
        infoWindow: const InfoWindow(title: 'Destino'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueBlue,
        ),
      );

      _info = null;
    });

    try {
      final directions = await DirectionsRepository().getDirections(
        origin: _origin!,
        destination: pos,
      );

      if (!mounted) return;
      setState(() => _info = directions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _info = null);
    }
  }

  void _fitRoute() {
    if (_origin == null || _destination == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _origin!.latitude < _destination!.position.latitude
            ? _origin!.latitude
            : _destination!.position.latitude,
        _origin!.longitude < _destination!.position.longitude
            ? _origin!.longitude
            : _destination!.position.longitude,
      ),
      northeast: LatLng(
        _origin!.latitude > _destination!.position.latitude
            ? _origin!.latitude
            : _destination!.position.latitude,
        _origin!.longitude > _destination!.position.longitude
            ? _origin!.longitude
            : _destination!.position.longitude,
      ),
    );

    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _clearRoute() {
    setState(() {
      _destination = null;
      _info = null;
      _selectedMarkerId = null;
    });
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,

            markers: {
              if (_originMarker != null) _originMarker!,

              ...MarkersService.buildMarkers(
                (destino, id) {
                  setState(() => _selectedMarkerId = id);
                  _selectDestination(destino);
                },
                _selectedMarkerId,
              ),

              if (_destination != null) _destination!,
            },

            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: _info!.polylinePoints
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                ),
            },

            onLongPress: _setOrigin,
          ),

          // 🟥 Limpar rota
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: (_destination == null) ? null : _clearRoute,
              child: const Icon(Icons.close),
            ),
          ),

          // 🎯 Fit rota
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: (_origin == null || _destination == null)
                  ? null
                  : _fitRoute,
              child: const Icon(Icons.center_focus_strong),
            ),
          ),

          // 📊 INFO BOX (estilo centralizado)
          if (_info != null)
            Positioned(
              top: 20,
              child: Container(
                padding: MapaStyle.infoPadding,
                decoration: MapaStyle.infoBox,
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: MapaStyle.infoText,
                ),
              ),
            ),

          // 🟢🔵 BOTÕES ORIGEM / DESTINO
          if (_origin != null || _destination != null)
            Positioned(
              top: 20,
              right: 10,
              child: Row(
                children: [
                  if (_origin != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ElevatedButton(
                        style: MapaStyle.originButton,
                        onPressed: () {
                          _googleMapController?.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _origin!,
                                zoom: 14.5,
                                tilt: 50,
                              ),
                            ),
                          );
                        },
                        child: const Text("Origem"),
                      ),
                    ),

                  if (_destination != null)
                    ElevatedButton(
                      style: MapaStyle.destinationButton,
                      onPressed: () {
                        _googleMapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: _destination!.position,
                              zoom: 14.5,
                              tilt: 50,
                            ),
                          ),
                        );
                      },
                      child: const Text("Destino"),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}