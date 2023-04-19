class Favorite{
  final String id;
  final double lat;
  final double lon;
  final String date;
  final String time;
  final String area;

  Favorite({
    required this.area,
    required this.id,
    required this.lat,
    required this.lon,
    required this.date,
    required this.time,
  });
 
 toDB(){
  return{
  "id":id,
  "lat":lat,
  "lon":lon,
  "date":date,
  "time":time,
  "area":area
  };
 }
}