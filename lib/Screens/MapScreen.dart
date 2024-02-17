import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/Controller/MapScreenController.dart';
import 'package:resq/Screens/LocationServices.dart';
import 'package:resq/const.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];
  LatLng? _currentLocation;
  bool fabEnabled = false;
  final MapScreenController _mapScreenController =
      Get.put(MapScreenController());
  Map<String, dynamic>? result;
  String distance = "";
  String duration = "";
  String _activeTextField = "";
  BitmapDescriptor sourceMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destMarkerIcon = BitmapDescriptor.defaultMarker;

  StreamSubscription<Position>? _positionStreamSubscription;
  Set<Marker> _sourceMarkers = Set<Marker>();
  Set<Marker> _destinationMarkers = Set<Marker>();

  void getSuggestion(String input) async {
    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';

      var response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _originController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polygon> _polygons = Set<Polygon>();
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polygonLatLngs = <LatLng>[];

  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();

    _setMarker(const LatLng(37.42796133580664, -122.085749655962), "");

    _getLocationUpdates().then(
      (_) => {},
    );
    _originController.addListener(() {
      if (_sessionToken == null) {
        setState(() {
          _sessionToken = uuid.v4();
        });
      }
      _activeTextField = "origin";
      getSuggestion(_originController.text);
    });
    _destinationController.addListener(() {
      if (_sessionToken == null) {
        setState(() {
          _sessionToken = uuid.v4();
        });
      }
      _activeTextField = "destination";
      getSuggestion(_destinationController.text);
    });
  }

  void _setMarker(LatLng point, String id) {
    setState(() {
      if (id == "src") {
        _sourceMarkers.add(
          Marker(
            markerId: MarkerId('marker$id'),
            position: point,
          ),
        );
      } else if (id == "dest") {
        _destinationMarkers.add(
          Marker(
            markerId: MarkerId('marker$id'),
            position: point,
          ),
        );
      }
    });
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/car.png")
        .then(
      (icon) {
        setState(() {
          sourceMarkerIcon = icon;
        });
      },
    );

    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), "assets/destination.png")
        .then(
      (icon) {
        setState(() {
          destMarkerIcon = icon;
        });
      },
    );
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;

    _polygons.add(
      Polygon(
        polygonId: PolygonId(polygonIdVal),
        points: polygonLatLngs,
        strokeWidth: 2,
        fillColor: Colors.transparent,
      ),
    );
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 4,
        color: Colors.deepPurple,
        points: points
            .map(
              (point) => LatLng(point.latitude, point.longitude),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            /// Google Map
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                markers: {..._sourceMarkers, ..._destinationMarkers},
                polygons: _polygons,
                polylines: _polylines,
                initialCameraPosition: _kGooglePlex,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),

            /// Search Bar
            Positioned(
              top: 20,
              right: 0,
              left: 0,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _originController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: ' Origin',
                              ),
                              onChanged: (value) {
                                //ignore: avoid_print
                                print(value);
                              },
                            ),
                            const Divider(color: Colors.grey),
                            TextFormField(
                              controller: _destinationController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: ' Destination',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                //ignore: avoid_print
                                print(value);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        var directions = await LocationService().getDirections(
                          _originController.text,
                          _destinationController.text,
                        );
                        setState(() {
                          fabEnabled = true;
                          FocusScope.of(context).requestFocus(FocusNode());
                        });
                        Map<String, dynamic> result =
                            await _mapScreenController.getDistanceAndDuration(
                          _originController.text,
                          _destinationController.text,
                        );

                        setState(() {
                          distance = result['distance'];
                          duration = result['duration'];
                        });

                        _goToPlace(
                          directions['start_location']['lat'],
                          directions['start_location']['lng'],
                          directions['bounds_ne'],
                          directions['bounds_sw'],
                          directions['end_location']['lat'],
                          // Pass destination lat
                          directions['end_location']
                              ['lng'], // Pass destination lng
                        );

                        _setPolyline(directions['polyline_decoded']);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // list of places
            if (_placeList.isNotEmpty)
              Positioned(
                top: 150,
                right: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _placeList
                        .map(
                          (place) => ListTile(
                            title: Text(place['description']),
                            onTap: () {
                              if (_activeTextField == 'origin') {
                                _originController.text = place['description'];
                              } else if (_activeTextField == 'destination') {
                                _destinationController.text =
                                    place['description'];
                              }
                              setState(() {
                                _placeList.clear();
                                _activeTextField = '';
                              });
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: fabEnabled
          ? BottomAppBar(
              surfaceTintColor: Colors.white,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          duration,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        _startLocationTracking();
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.navigation_rounded),
                          SizedBox(width: 10),
                          Text("Start"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _goToPlace(
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
    double destLat,
    double destLng,
  ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 12),
      ),
    );

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
          ),
          25),
    );
    addCustomIcon();
    _setMarker(LatLng(lat, lng), "src"); // Start location marker
    _setMarker(LatLng(destLat, destLng), "dest"); // Destination location marker
  }

  _getLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      //change the camera position to the current location
      _goToPlace(
        position.latitude,
        position.longitude,
        {
          'lat': position.latitude + 0.005,
          'lng': position.longitude + 0.005,
        },
        {
          'lat': position.latitude - 0.005,
          'lng': position.longitude - 0.005,
        },
        position.latitude, // Add destination latitude
        position.longitude, // Add destination longitude
      );
    });
  }

  void _startLocationTracking() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) async {
      _updateCameraPosition(position.latitude, position.longitude);

      // Get the updated distance and duration
      Map<String, dynamic> result =
          await _mapScreenController.getDistanceAndDuration(
        _originController.text,
        _destinationController.text,
      );

      setState(() {
        distance = result['distance'];
        duration = result['duration'];
      });

      // TODO: Add updated location on the firebase
    });
  }

  void _updateCameraPosition(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 14.4746,
        ),
      ),
    );

    // Clear the existing source marker
    setState(() {
      _sourceMarkers.clear();
    });

    // Add a new source marker at the updated location
    _setMarker(LatLng(latitude, longitude), "src");

    // Get the updated polyline points
    var directions = await LocationService().getDirections(
      _originController.text,
      _destinationController.text,
    );

    // Clear the existing polyline
    setState(() {
      _polylines.clear();
    });

    // Set the updated polyline
    _setPolyline(directions['polyline_decoded']);
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
