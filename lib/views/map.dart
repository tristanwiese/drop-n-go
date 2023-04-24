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
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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
  State<MapWidget> createState() => _MapWidgetState(lat: lat, lon: lon);
}

enum Filters { Restaurants, Lodging, Health, Park }

const List<Text> filterTypes = <Text>[
  Text('Restaurant'),
  Text('Lodging'),
  Text('Health'),
  Text('Park')
];

class _MapWidgetState extends State<MapWidget> {
  _MapWidgetState({required this.lat, required this.lon});

  final double lat;
  final double lon;

  //radio buttons states
  final List<bool> _selectedFilters = <bool>[false, false, false, false];

  //map controller
  static late GoogleMapController mapController;

  //initial map data
  String viewType = 'Satellite';
  MapType mapType = MapType.normal;
  final Set<Circle> _circle = <Circle>{};
  double searchRadius = 1000;

  //map markers
  late Set<Marker> _markers = {
    Marker(
        markerId: const MarkerId('currentPosition'),
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(
            title: "Current Positon", snippet: "Lat: $lat, Lon: $lon"))
  };

  //debouncer to limit api calls
  Timer? _debounce;

  //nearby locations
  NearbyLocationsData? searchResults;
  List? results;

  //nearby locations container state controller
  bool isLoaded = false;

  //list of idexes of litered data
  List? indexes = [];

  //state controller for data when filter is applied
  bool filterActive = false;

  //list of active filters
  List<String?> filters = [];

  //send to maps page
  bool resultClicked = false;

  //current viewed result index
  late int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () {
                addFavorite();
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
          markers: _markers),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
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
                      _debounce = Timer(const Duration(milliseconds: 700), () {
                        getData();
                      });
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(right: 8),
                child: Text("${searchRadius.toInt()}m"),
              )
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
          bottom: 230,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                resultClicked
                    ? Expanded(
                        child: ElevatedButton(
                          onPressed: () async{
                            String mapUrl =
                                "https://www.google.com/maps/@${searchResults!.results[currentIndex].geometry.location.lat},${searchResults!.results[currentIndex].geometry.location.lng},19z";
                            final mapUri = Uri.parse(mapUrl);
                            _launchUrl(mapUri);
                          },
                          child: const Text('Go here'),
                        ),
                      )
                    : Container(),
                const SizedBox(width: 10),
                isLoaded
                    ? searchResults!.nextPageToken != null
                        ? ElevatedButton(
                            onPressed: () => getMoreData(),
                            child: const Text('Load more'))
                        : Container()
                    : Container()
              ],
            ),
          )),
      Positioned(
        bottom: 80,
        child: SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: nearbyPlacesDrawer(),
        ),
      ),
      Positioned(
        bottom: 20,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: Offset(0, 10))
            ]),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.green,
              child: IconButton(
                icon: const Icon(Icons.gps_fixed),
                color: Colors.white,
                onPressed: () {
                  _markers.removeWhere((marker) {
                    if (marker.markerId.value == 'clickedResult') {
                      return true;
                    }
                    return false;
                  });
                  setState(() {
                    resultClicked = false;
                  });
                  mapController.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(widget.lat, widget.lon),
                      zoom: 14.0,
                    ),
                  ));
                },
              ),
            ),
          ),
        ),
      )
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
                : const Center(child: Text("No results found"))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: searchResults!.results.length,
                itemBuilder: (BuildContext context, index) {
                  return myListBuilder(index, index, searchResults!.results);
                })
        : Container();
  }

  Padding myListBuilder(int filterIndex, listTileIndex, end) {
    return Padding(
        padding: const EdgeInsets.all(5.0),
        child: InkWell(
          onTap: () {
            _markers.add(Marker(
                markerId: const MarkerId('clickedResult'),
                position: LatLng(
                    searchResults!.results[filterIndex].geometry.location.lat,
                    searchResults!
                        .results[filterIndex].geometry.location.lng)));
            toggleMapCameraPos(
                searchResults!.results[filterIndex].geometry.location.lat,
                searchResults!.results[filterIndex].geometry.location.lng);
            setState(() {
              resultClicked = true;
              currentIndex = filterIndex;
            });
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(), color: Colors.green.withOpacity(0.5)),
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('${listTileIndex + 1}', textAlign: TextAlign.center),
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




  _launchUrl(url)async{
    if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
    }
  }
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
    setState(() {
      indexes = index;
    });
  }

  getData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    searchResults = await NearbyPlaces(
            lat: widget.lat, lon: widget.lon, radius: searchRadius.toInt())
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
  }

  getMoreData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    final moreResults = await NearbyPlaces(
            lat: widget.lat, lon: widget.lon, radius: searchRadius.toInt())
        .getMore(searchResults!.nextPageToken);
    searchResults!.results.addAll(moreResults!.results);
    searchResults!.nextPageToken = moreResults.nextPageToken;
    if (filterActive) {
      basicFilter(filters);
    }
    setState(() {});
    Navigator.pop(context);
  }

  addFavorite() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
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
  }
}
