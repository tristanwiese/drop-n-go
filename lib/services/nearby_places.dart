// ignore_for_file: avoid_print

import 'package:drop_n_go/models/nearby_locations_data.dart';
import 'package:http/http.dart' as http;

class NearbyPlaces {
  int radius;
  double lat;
  double lon;
  final String _key = 'AIzaSyASHyqPfVoEeH4KDaCKbz4Vr6ZM1vzdSO4';

  NearbyPlaces({required this.lat, required this.lon, required this.radius});

  Future<NearbyLocationsData?> get() async {

    String url =
        "https://etrainer.co.za/tristan/google_nearby_places_api/get.places.php";
    var response = await http.post(
      Uri.parse(url),
      body: {
        'get': 'normal',
        'lat':'$lat',
        'lon':'$lon',
        'rad':'$radius',
        'key': _key,
      }
      );
    if (response.statusCode == 200) {
      String json = response.body;

      return nearbyLocationsDataFromJson(json);
    } else {
      return null;
    }
  }

  Future<NearbyLocationsData?> getMore(token) async {
    String url =
        "https://etrainer.co.za/tristan/google_nearby_places_api/get.places.php";

    var response = await http.post(
      Uri.parse(url),
      body:{
        'get': 'more',
        'token':'$token',
        'key':_key
      }
      );
    if (response.statusCode == 200) {
      String json = response.body;
      return nearbyLocationsDataFromJson(json);
    } else {
      return null;
    }
  }
}
