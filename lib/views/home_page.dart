// ignore_for_file: unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_n_go/services/nav.dart';
import 'package:drop_n_go/Views/my_drawer.dart';
import 'package:drop_n_go/services/nearby_places.dart';
import 'package:drop_n_go/views/initializer.dart';
import 'package:drop_n_go/views/map.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/compact_weather_model.dart';
import '../services/utils.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  MyHomePage({
    super.key,
    required this.title,
    required this.currentPosition,
    required this.weather,
    required this.temp,
    required this.favorites,
  });
  QuerySnapshot<Map<String, dynamic>>? favorites;
  final String title;
  Position? currentPosition;
  CompactWeatherData? weather;
  double? temp;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            navReplace(context, const Initializer());
          },
          child: const Icon(Icons.gps_fixed_outlined)),
      body: Center(
        child: Row(
          children: [
            MyDrawer(favorites: widget.favorites),
            centrColumn(context),
            const RightGap(),
          ],
        ),
      ),
    );
  }






  Expanded centrColumn(BuildContext context) {
    return Expanded(
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Logo(),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green[100],
              child: IconButton(
                // ignore: avoid_returning_null_for_void
                onPressed: () {
                  navPush(
                      context,
                      MapWidget(
                          lat: widget.currentPosition!.latitude,
                          lon: widget.currentPosition!.longitude));
                  NearbyPlaces(
                          lon: widget.currentPosition!.longitude,
                          lat: widget.currentPosition!.latitude,
                          radius: 1000)
                      .get();
                },
                icon: const Icon(Icons.location_on_outlined),
                iconSize: 60,
                color: Colors.green,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextCard(text: 'LAT: ${widget.currentPosition!.latitude}'),
                    const SizedBox(width: 20),
                    TextCard(text: 'LON: ${widget.currentPosition!.longitude}'),
                    const SizedBox(width: 20),
                    TextCard(text: 'TEMP C: ${widget.temp}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightGap extends StatelessWidget {
  const RightGap({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column();
  }
}

class TextCard extends StatelessWidget {
  const TextCard({
    super.key,
    required this.text,
  });

  final dynamic text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
