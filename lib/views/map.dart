// ignore_for_file: avoid_print, use_build_context_synchronously, constant_identifier_names

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

enum Filters { Restaurants, Lodging, Health, Park }

const List<Text> filterTypes = <Text>[
  Text('Restaurant'),
  Text('Lodging'),
  Text('Health'),
  Text('Park')
];

class _MapWidgetState extends State<MapWidget> {
  //radio buttons
  final List<bool> _selectedFilters = <bool>[false, false, false, false];

  static late GoogleMapController mapController;

  String viewType = 'Satellite';
  MapType mapType = MapType.normal;
  final Set<Circle> _circle = <Circle>{};
  double searchRadius = 1000;
  Timer? _debounce;
  NearbyLocationsData? searchResults;
  bool isLoaded = false;

  //filter indexes
  List? indexes = [];
  bool filterActive = false;
  List<String?> filters = [];

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

  basicFilter(List<String?> filters) {
    List index = [];
    for (var j = 0; j < filters.length; j++) {
      for (var i = 0; i < searchResults!.results.length; i++) {
        if (searchResults!.results[i].types.contains(filters[j])) {
          if (!index.contains(i)) {
            index.add(i);
          }
        }
      }
    }
    print(index);
    setState(() {
      indexes = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                late int count;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then(
                  (value) {
                    count = value.data()!['count'];
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({"count": count + 1});
                final fav = Favorite(
                  id: "Location#$count",
                  area: searchResults!.results[0].name,
                  lat: widget.lat,
                  lon: widget.lon,
                  date: DateFormat('dd/M/yyyy').format(DateTime.now()),
                  time: DateFormat('kk:mm:ss').format(DateTime.now()),
                );
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('favorites')
                    .doc('Location#$count')
                    .set(fav.toDB());
                navReplace(context, const Initializer());
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
                    if (filterActive) {
                      setState(() {
                        basicFilter(filters);
                      });
                    }
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
        top: 70,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: ToggleButtons(
                onPressed: (index) {
                  setState(() {
                    _selectedFilters[index] = !_selectedFilters[index];
                    if (_selectedFilters.contains(true)) {
                      setState(() {
                        filterActive = true;
                      });
                    } else {
                      setState(() {
                        filterActive = false;
                      });
                    }
                    if (!_selectedFilters[index]) {
                      filters.remove(filterTypes[index].data!.toLowerCase());
                      basicFilter(filters);
                      print(filters);
                    } else {
                      filters.add(filterTypes[index].data!.toLowerCase());
                      print(filters);
                      basicFilter(filters);
                    }
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.black,
                selectedColor: Colors.white,
                fillColor: Colors.green[200],
                color: Colors.green[400],
                constraints:
                    const BoxConstraints(minHeight: 40.0, minWidth: 80),
                direction: Axis.horizontal,
                isSelected: _selectedFilters,
                children: filterTypes),
          ),
        ),
      ),
      Positioned(
        bottom: 80,
        child: SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: nearbyPlacesDrawer(),
        ),
      ),
    ]);
  }

  nearbyPlacesDrawer() {
    return isLoaded
        ? filterActive
            ? indexes!.isNotEmpty
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: indexes!.length,
                    itemBuilder: (BuildContext context, index) {
                      return myListBuilder(indexes![index], index, indexes);
                    })
                : searchResults!.htmlAttributions != null
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('No results for filters on this page',
                              style: TextStyle(fontSize: 20)),
                          IconButton(
                            icon: const Icon(Icons.arrow_right_alt_rounded),
                            onPressed: () async {
                              setState(() {
                                isLoaded = false;
                              });
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => const Center(
                                    child: CircularProgressIndicator()),
                              );
                              searchResults = await NearbyPlaces(
                                      lat: widget.lat,
                                      lon: widget.lon,
                                      radius: searchRadius.toInt())
                                  .getMore(searchResults!.nextPageToken);
                              if (filterActive) {
                                basicFilter(filters);
                              }
                              setState(() {
                                isLoaded = true;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    : const Center(
                        child: Text('No results for filters on this page',
                            style: TextStyle(fontSize: 20)),
                      )
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchResults!.results.length,
                itemBuilder: (BuildContext context, index) {
                  return myListBuilder(index, index, searchResults!.results);
                })
        : Container();
  }

  Padding myListBuilder(int filterIndex, listTileIndex, end) {
    if (listTileIndex == end.length - 1 &&
        searchResults!.nextPageToken != null) {
      return Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            InkWell(
              onTap: () => toggleMapCameraPos(
                  searchResults!.results[filterIndex].geometry.location.lat,
                  searchResults!.results[filterIndex].geometry.location.lng),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(), color: Colors.green.withOpacity(0.5)),
                width: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(searchResults!.results[filterIndex].name,
                        textAlign: TextAlign.center),
                    Text(
                      "Type: ${StringExtension(string: searchResults!.results[filterIndex].types[0].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}, ${StringExtension(string: searchResults!.results[filterIndex].types[1].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}",
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
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) =>
                      const Center(child: CircularProgressIndicator()),
                );
                searchResults = await NearbyPlaces(
                        lat: widget.lat,
                        lon: widget.lon,
                        radius: searchRadius.toInt())
                    .getMore(searchResults!.nextPageToken);
                if (filterActive) {
                  basicFilter(filters);
                }
                setState(() {
                  isLoaded = true;
                });
                Navigator.pop(context);
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
                searchResults!.results[filterIndex].geometry.location.lat,
                searchResults!.results[filterIndex].geometry.location.lng),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(), color: Colors.green.withOpacity(0.5)),
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(searchResults!.results[filterIndex].name,
                      textAlign: TextAlign.center),
                  Text(
                    "Type: ${StringExtension(string: searchResults!.results[filterIndex].types[0].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}, ${StringExtension(string: searchResults!.results[filterIndex].types[1].replaceAll(RegExp('[\\W_]+'), ' ')).capitalize()}",
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ));
    }
  }
}
