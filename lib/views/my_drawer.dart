// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_n_go/Views/initializer.dart';
import 'package:drop_n_go/main.dart';
import 'package:drop_n_go/services/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/nearby_locations_data.dart';
import '../services/nearby_places.dart';
import 'map.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    super.key,
    required this.favorites,
  });
  final QuerySnapshot<Map<String, dynamic>>? favorites;

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      width: 70,
      margin: EdgeInsets.zero,
      decoration: const BoxDecoration(color: Colors.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          favoriteButton(),
          const SizedBox(),
          const SignOut(),
        ],
      ),
    );
  }

  IconButton favoriteButton() {
    return IconButton(
        icon: const Icon(Icons.star_border),
        iconSize: 40,
        color: Colors.white,
        onPressed: () => showFavoritepage());
  }

  Widget favoritePage(BuildContext context) {
    return AlertDialog(
      title: const Text('Favorites'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: ListView.builder(
          itemCount: widget.favorites!.docs.length,
          itemBuilder: (BuildContext context, index) {
            if(widget.favorites!.docs.isNotEmpty){
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: InkWell(
                onTap: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                  );
                  NearbyLocationsData? places = await NearbyPlaces(
                          lon: widget.favorites!.docs[index]['lon'],
                          lat: widget.favorites!.docs[index]['lat'],
                          radius: 1000)
                      .get();
                  navPop(context);
                  navPush(
                      context,
                      MapWidget(
                        lat: widget.favorites!.docs[index]['lat'],
                        lon: widget.favorites!.docs[index]['lon'],
                        places: places,
                      ));
                },
                child:Container(
                  decoration: BoxDecoration(border: Border.all(), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(widget.favorites!.docs[index]['id']),
                            Text(widget.favorites!.docs[index]['area']),
                            Text('Date: ${widget.favorites!.docs[index]['date']}'),
                            Text('Time: ${widget.favorites!.docs[index]['time']}')
                          ],
                          ),
                        IconButton(
                        onPressed: () =>
                            deleteFav(widget.favorites!.docs[index]['id']),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          else{
            return const Center(child: Text('No favorites'),);
          }
          }
        ),
      ),
    );
  }

  deleteFav(id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .doc(id)
        .delete();

    navReplace(context, const Initializer());
  }

  showFavoritepage() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return favoritePage(context);
      },
    );
  }
}

class SignOut extends StatelessWidget {
  const SignOut({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        navReplace(context, const MainPage());
      },
      icon: const Icon(Icons.logout_rounded),
      color: Colors.red[300],
      iconSize: 40,
    );
  }
}
