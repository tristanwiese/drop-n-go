// ignore_for_file: avoid_print

// import 'dart:math';

import 'dart:developer';

import 'package:drop_n_go/models/nearby_locations_data.dart';
import 'package:http/http.dart' as http;

class NearbyPlaces {
  int radius;
  double lat;
  double lon;
  final String _key = 'AIzaSyAlDA6e_tymSuGdvSX7aLNth2mdkEzFPQA';

  NearbyPlaces({required this.lat, required this.lon, required this.radius});

  Future<NearbyLocationsData?> get() async {
    // String url =
    //     "https://etrainer.co.za/tristan/google_nearby_places_api/get.places.php";
    String url =
        "https://etrainer.co.za/tristan/php/whatsapp-api/receive_api.php";
    var res = await http.post(Uri.parse(url), body: "test");
    log(res.body);
    // var response = await http.post(Uri.parse(url), body: {
    //   'get': 'normal',
    //   'lat': '$lat',
    //   'lon': '$lon',
    //   'rad': '$radius',
    //   'key': _key,
    // });
    // if (response.statusCode == 200) {
    //   String json = response.body;

    //   print(response.body);

    //   return nearbyLocationsDataFromJson(json);
    // } else {
    //   return null;
    // }
  }

  Future<NearbyLocationsData?> getMore(token) async {
    String url =
        "https://etrainer.co.za/tristan/google_nearby_places_api/get.places.php";

    var response = await http.post(Uri.parse(url),
        body: {'get': 'more', 'token': '$token', 'key': _key});
    if (response.statusCode == 200) {
      String json = response.body;
      return nearbyLocationsDataFromJson(json);
    } else {
      return null;
    }
  }
}
