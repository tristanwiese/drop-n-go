import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import '../services/permisions.dart';
import 'home_page.dart';

class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {
  static QuerySnapshot<Map<String, dynamic>>? favorites;
  Position? _currentPosition;
  bool initialized = false;
  

  @override
  void initState() {
    super.initState();

    initialize();
  }

  initialize() async {
    await getCurrentPosition();
    await databaseFetch();

    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Visibility(
        visible: initialized,
        replacement: loadWidget(context),
        child: MyHomePage(
          title: 'Drop n Go',
          currentPosition: _currentPosition,
          favorites: favorites,
        ),
      ),
    );
  }

  Widget loadWidget(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'We are finding you...',
          style: TextStyle(fontSize: 30),
        ),
        const SizedBox(height: 20,),
        SizedBox(
          height: 200,
          width: 200,
          child: Lottie.asset("assets/animations/location-pin.json", fit: BoxFit.cover),
        ),
      ],
    ));
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission(context);
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  databaseFetch() async {
    favorites = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('favorites')
        .get();
  }
}
