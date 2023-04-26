// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:drop_n_go/models/nearby_locations_data.dart';
import 'package:http/http.dart' as http;

class NearbyPlaces {
  int radius;
  double lat;
  double lon;

  NearbyPlaces({required this.lat, required this.lon, required this.radius});

  Future<NearbyLocationsData?> get() async {
    NearbyLocationsData results;
    final corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
    };
    
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?&location=$lat,$lon&radius=$radius&key=AIzaSyASHyqPfVoEeH4KDaCKbz4Vr6ZM1vzdSO4");

    var response = await http.get(url, headers: corsHeaders);
    if (response.statusCode == 200) {
      String json = response.body;
      results = nearbyLocationsDataFromJson(json);
      return results;
    } else {
      return null;
    }
  }

  Future<NearbyLocationsData?> getMore(token) async {
    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?&pagetoken=$token&key=AIzaSyASHyqPfVoEeH4KDaCKbz4Vr6ZM1vzdSO4";

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String json = response.body;
      final extra = nearbyLocationsDataFromJson(json);
      return extra;
    } else {
      return null;
    }
  }
}
