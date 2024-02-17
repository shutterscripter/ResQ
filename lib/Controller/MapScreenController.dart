import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resq/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  storeDataIntoFirebase(src, dest, condition, movSrc, movDest, uuid) async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Create a reference to the 'users' collection
      CollectionReference users = FirebaseFirestore.instance.collection('trips');

      // Prepare the order data
      Map<String, dynamic> orderData = {
        'source': {'latitude': src.latitude, 'longitude': src.longitude},
        'destination': {'latitude': dest.latitude, 'longitude': dest.longitude},
        'condition': condition,
        'movSrc': {'latitude': movSrc.latitude, 'longitude': movSrc.longitude},
        'movDest': {'latitude': movDest.latitude, 'longitude': movDest.longitude},
      };
      // Create a new document with the unique ID and set the order data
      DocumentReference docRef = users.doc(user.uid).collection('orders').doc(uuid);

      await docRef.set(orderData).then((value) {
        print("Order Added");
        _storeOrderIdInSharedPreferences(docRef.id);
      }).catchError((error) => print("Failed to add order: $error"));
    } else {
      print("No user is signed in.");
    }
  }

  _storeOrderIdInSharedPreferences(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('orderId', orderId);
  }

  Future<String?> getOrderIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('orderId');
  }
}
