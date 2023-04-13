// ignore_for_file: avoid_print

import 'package:drop_n_go/models/nearby_locations_data.dart';
import 'package:http/http.dart' as http;

class NearbyPlaces {

  final corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'OPTIONS, POST, GET',
  'Access-Control-Max-Age':'3600',
  'Access-Control-Allow-Credentials':'true',
  'Access-Control-Allow-Headers':'Content-Type',
};

  double radius;
  double lat;
  double lon;

  NearbyPlaces({required this.lat, required this.lon, required this.radius});

  Future<NearbyLocationsData?>get() async{

    String url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?&location=$lat,$lon&radius=$radius&key=AIzaSyASHyqPfVoEeH4KDaCKbz4Vr6ZM1vzdSO4";
    var client = http.Client();
      var uri = Uri.parse(url);
      try{
      var response = await client.get(uri, headers: corsHeaders);
      if (response.statusCode == 200) {
        String json = response.body;
        print(json);
        return nearbyLocationsDataFromJson(json);
      } else {
        return null;
      }
      }catch(e){
        print(e);
        return null;
      }
  }
}
