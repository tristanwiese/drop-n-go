// ignore_for_file: avoid_print

import 'package:drop_n_go/models/compact_weather_model.dart';
import 'package:http/http.dart' as http;

class Weather {
  double? lon;
  double? lat;
  Weather({
    required this.lon,
    required this.lat,
  });

  Future<CompactWeatherData?> get() async {
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
}
