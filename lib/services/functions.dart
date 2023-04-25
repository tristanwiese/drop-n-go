import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:drop_n_go/models/sorted_results.dart';

import '../models/nearby_locations_data.dart';

String measurement = '';

double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371;
  const multiplier = pi / 180;
  final latDif = (lat1 - lat2) * multiplier;
  final lonDif = (lon1 - lon2) * multiplier;
  final form1 = sin(latDif / 2) * sin(latDif / 2) +
      cos(lat1 * multiplier) *
          cos(lat2 * multiplier) *
          sin(lonDif / 2) *
          sin(lonDif / 2);
  final form2 = 2 * atan2(sqrt(form1), sqrt(1 - form1));
  final distance = r * form2;

  measurement = 'm';
  return distance * 1000;
}


List<Result> sort(NearbyLocationsData? data, lat, lon) {
  List<Result> results = data!.results;

  List<Map<String, dynamic>> sortedData = [];
  Map sortedMap = {};
  Map<double, int> map = {};
  List<Result> sortedResults = [];

  for (var i = 0; i < results.length; i++) {
    double distance = distanceBetween(lat, lon,
        results[i].geometry.location.lat, results[i].geometry.location.lng);
    map[distance] = i;
    sortedMap = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }
  sortedMap.forEach((key, value) {
    sortedData.add({"distance": key, "index": value});
    sortedResults.add(data.results[value]);
  });
  return sortedResults;
}
