// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:drop_n_go/models/favorite_locations.dart';
import 'package:drop_n_go/services/nav.dart';
import 'package:drop_n_go/services/nearby_places.dart';
import 'package:drop_n_go/views/initializer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:drop_n_go/services/utils.dart';

import '../models/nearby_locations_data.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    required this.lat,
    required this.lon,
    this.places,
  });

  final NearbyLocationsData? places;
  final double lat;
  final double lon;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static late GoogleMapController mapController;

  String viewType = 'Satellite';
  MapType mapType = MapType.normal;
  final Set<Circle> _circle = <Circle>{};
  double searchRadius = 1000;
  Timer? _debounce;
  NearbyLocationsData? searchResults;
  bool isLoaded = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setCircle();
    searchResults = widget.places;
    setState(() {
      isLoaded = true;
    });
  }

  setCircle() {
    setState(() {
      _circle.clear();
      _circle.add(Circle(
        circleId: const CircleId('currentLocation'),
        center: LatLng(widget.lat, widget.lon),
        fillColor: Colors.green.withOpacity(0.1),
        strokeColor: Colors.green,
        strokeWidth: 1,
        radius: searchRadius,
      ));
    });
  }

  void toggleMapCameraPos(lat, lon) {
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lon), zoom: 20)));
  }

  configMap() {
    if (viewType == 'Satellite') {
      setState(() {
        viewType = 'Map';
        mapType = MapType.satellite;
      });
    } else {
      setState(() {
        viewType = 'Satellite';
        mapType = MapType.normal;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: locationName,
                );
              },
              child: const Icon(Icons.star_border_outlined),
            )),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        appBar: AppBar(
          title: const Center(child: Text('Map')),
          elevation: 2,
          actions: [
            const Center(
              child: Text(
                'View: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueGrey)),
                  onPressed: () => configMap(),
                  child: Text(viewType),
                )),
          ],
        ),
        body: map());
  }

  map() {
    return Stack(children: [
      GoogleMap(
          myLocationButtonEnabled: true,
          onMapCreated: _onMapCreated,
          mapType: mapType,
          circles: _circle,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            zoom: 14.0,
          ),
          markers: {
            Marker(
                markerId: const MarkerId('currentPosition'),
                position: LatLng(widget.lat, widget.lon),
                infoWindow: InfoWindow(
                    title: "Current Positon",
                    snippet: "Lat: ${widget.lat}, Lon: ${widget.lon}"))
          }),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Container(
          width: 400,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Colors.green.withOpacity(0.4)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Slider(
                max: 5000,
                min: 20,
                value: searchRadius,
                onChanged: (newVal) {
                  isLoaded = false;
                  searchRadius = newVal;
                  setCircle();
                  if (_debounce?.isActive ?? false) {
                    _debounce?.cancel();
                  }
                  _debounce =
                      Timer(const Duration(milliseconds: 700), () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    searchResults = await NearbyPlaces(
                            lat: widget.lat,
                            lon: widget.lon,
                            radius: searchRadius.toInt())
                        .get();
                    navPop(context);
                    setState(() {
                      isLoaded = true;
                    });
                  });
                },
              ))
            ],
          ),
        ),
      ),
      Positioned(
        bottom: 80,
        child: SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: nearbyPlacesDrawer(context),
        ),
      )
    ]);
  }

  Widget nearbyPlacesDrawer(BuildContext ctx) {
    return isLoaded
        ? ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: searchResults!.results.length,
            itemBuilder: (BuildContext context, index) {
              if (index == searchResults!.results.length - 1 &&
                  searchResults!.nextPageToken != null) {
                return Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => toggleMapCameraPos(
                            searchResults!.results[index].geometry.location.lat,
                            searchResults!
                                .results[index].geometry.location.lng),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(),
                              color: Colors.green.withOpacity(0.5)),
                          width: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                  "${index + 1}: ${searchResults!.results[index].name}",
                                  textAlign: TextAlign.center),
                              Text(
                                "Type: ${StringExtension(string: searchResults!.results[index].types[0].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}, ${StringExtension(string: searchResults!.results[index].types[1].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}",
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right_alt_rounded),
                        onPressed: () async {
                          setState(() {
                            isLoaded = false;
                          });
                          showDialog(
                            context: ctx,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                                child: CircularProgressIndicator()),
                          );
                          searchResults = await NearbyPlaces(lat: widget.lat, lon: widget.lon, radius: searchRadius.toInt()).getMore(searchResults!.nextPageToken);
                          setState(() {
                            isLoaded = true;
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: InkWell(
                      onTap: () => toggleMapCameraPos(
                          searchResults!.results[index].geometry.location.lat,
                          searchResults!.results[index].geometry.location.lng),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.green.withOpacity(0.5)),
                        width: 150,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                "${index + 1}: ${searchResults!.results[index].name}",
                                textAlign: TextAlign.center),
                            Text(
                              "Type: ${StringExtension(string: searchResults!.results[index].types[0].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}, ${StringExtension(string: searchResults!.results[index].types[1].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}",
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ));
              }
            })
        : Container();
  }

  Widget locationName(BuildContext context) {
    final TextEditingController nameControler = TextEditingController();

    final name = Container(
      margin: const EdgeInsets.all(10),
      child: TextFormField(
        decoration: const InputDecoration(hintText: 'Location Name'),
        controller: nameControler,
      ),
    );

    final saveButton = Center(
        child: ElevatedButton(
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) =>
                    const Center(child: CircularProgressIndicator()),
              );
              final fav = Favorite(
                id: nameControler.text.trim(),
                lat: widget.lat,
                lon: widget.lon,
                date: DateFormat('dd/M/yyyy').format(DateTime.now()),
                time: DateFormat('kk:mm:ss').format(DateTime.now()),
              );
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('favorites')
                  .doc(nameControler.text.trim())
                  .set(fav.toDB());
              navReplace(context, const Initializer());
            },
            child: const Text('Save')));

    return AlertDialog(
      content: const Text('Enter Location Name'),
      actions: [name, saveButton],
    );
  }
}
