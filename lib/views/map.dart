import 'package:drop_n_go/models/favorite_locations.dart';
import 'package:drop_n_go/services/nav.dart';
import 'package:drop_n_go/views/initializer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    super.key,
    required this.lat,
    required this.lon,
  });

  final double lat;
  final double lon;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;

  String viewType = 'Satellite';
  MapType mapType = MapType.normal;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      appBar: AppBar(
        title: const Text('Map'),
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
      body: GoogleMap(
          myLocationButtonEnabled: true,
          onMapCreated: _onMapCreated,
          mapType: mapType,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            zoom: 18.0,
          ),
          markers: {
            Marker(
                markerId: const MarkerId('currentPosition'),
                position: LatLng(widget.lat, widget.lon),
                infoWindow: InfoWindow(
                    title: "Current Positon",
                    snippet: "Lat: ${widget.lat}, Lon: ${widget.lon}"))
          }),
    );
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
                  lon: widget.lon);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc('test')
                  .collection('favorites')
                  .doc(nameControler.text.trim())
                  .set(fav.toDB());
              // ignore: use_build_context_synchronously
              navReplace(context, const Initializer());
            },
            child: const Text('Save')));

    return AlertDialog(
      content: const Text('Enter Location Name'),
      actions: [name, saveButton],
    );
  }
}
