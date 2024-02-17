import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resq/const.dart';

class MapScreenController extends GetxController {
  Future<Map<String, dynamic>> getDistanceAndDuration(
      String origin, String destination) async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$GOOGLE_API_KEY";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String distance =
          jsonResponse['routes'][0]['legs'][0]['distance']['text'];
      String duration =
          jsonResponse['routes'][0]['legs'][0]['duration']['text'];

      return {'distance': distance, 'duration': duration};
    } else {
      throw Exception('Failed to load distance and duration');
    }
  }
}
