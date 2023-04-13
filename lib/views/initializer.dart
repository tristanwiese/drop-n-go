import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_n_go/Views/home_page.dart';
import 'package:drop_n_go/models/compact_weather_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/weather.dart';
import '../services/permisions.dart';

class Initializer extends StatefulWidget {
  const Initializer({super.key});

  @override
  State<Initializer> createState() => _InitializerState();
}

class _InitializerState extends State<Initializer> {

  static QuerySnapshot<Map<String, dynamic>>? favorites;
  Position? _currentPosition;
  CompactWeatherData? weather;
  double? temp;
  bool initialized = false;


  @override
  void initState(){
    super.initState();

    initialize();
  }

  initialize() async{
    await getCurrentPosition();
    getWeather();
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
        child: MyHomePage(title: 'Drop n Go', currentPosition: _currentPosition, temp: temp, weather: weather, favorites: favorites,),
        ),
    );
  }

  Widget loadWidget(BuildContext context){
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
        Text('We are finding you...', style: TextStyle(fontSize: 30),),
        CircularProgressIndicator(backgroundColor: Colors.green,)
      ],)
    );
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

  getWeather() async{
    await Weather(lon: _currentPosition?.longitude, lat: _currentPosition?.latitude).get().then((data) => {
      setState(()=> weather = data)
    });
    setState(() {
      temp = weather!.properties.timeseries[1].data.instant.details.airTemperature;
    });
  }

  databaseFetch() async {
    favorites = await FirebaseFirestore.instance
        .collection('users')
        .doc('test')
        .collection('favorites')
        .get();
  }
}