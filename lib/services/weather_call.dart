// ignore_for_file: avoid_print

import 'package:drop_n_go/models/compact_weather_model.dart';
import 'package:http/http.dart' as http;

class APICall {
  double? lon;
  double? lat;
  APICall({
    required this.lon,
    required this.lat,
  });

  Future<CompactWeatherData?> getWeather() async {
    String url =
        "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=$lat&lon=$lon";
    var client = http.Client();
    var uri = Uri.parse(url);
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      String json = response.body;
      // print(json);
      return compactWeatherDataFromJson(json);
    } else {
      return null;
    }
  }

  Future geNearbyPlaces() async {
    String url ="https://maps.googleapis.com/maps/api/place/nearbysearch/json&location=$lat,$lon&radius=1000&key=AIzaSyA41ACqTA0csL8Hs-JfIUaT6w_UQ4M366M";
    var client = http.Client();
    var uri = Uri.parse(url);
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      String json = response.body;
      print(json);
      return;
    } else {
      return null;
    }
  }
}
