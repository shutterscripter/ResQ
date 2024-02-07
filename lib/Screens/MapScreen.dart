import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:resq/const.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng? _currentLocation;
  Map<PolylineId, Polyline> polylines = {};
  static const LatLng _pGooglePlex =
      LatLng(37.42796133580664, -122.085749655962);
  static const LatLng _pApplePark = LatLng(37.334722, -122.008889);

  @override
  void initState() {
    super.initState();
    _getLocationUpdates().then(
      (_) => {
        getPolylinePoints().then(
          (coordinates) {
            // ignore: avoid_print
            print(coordinates);
          },
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          _currentLocation == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : GoogleMap(
                  onMapCreated: ((GoogleMapController controller) =>
                      _mapController.complete(controller)),
                  mapType: MapType.normal,
                  padding: const EdgeInsets.only(bottom: 20),
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('_sourceLocation'),
                      position: _currentLocation!,
                      icon: BitmapDescriptor.defaultMarker,
                    ),
                  },
                  polylines: Set<Polyline>.of(polylines.values),
                ),
        ],
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: position,
        zoom: 15,
      ),
    ));
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.longitude != null &&
          currentLocation.latitude != null) {
        setState(() {
          _currentLocation =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          // ignore: avoid_print
          // print("Location Updated: $_currentLocation");
          _cameraToPosition(_currentLocation!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    final List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_API_KEY,
      PointLatLng(_currentLocation!.latitude, _currentLocation!.longitude),
      PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      Get.snackbar("Error", "No route found");
    }
    return polylineCoordinates;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) {
    const PolylineId id = PolylineId('poly');
    final Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 6,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }
}
