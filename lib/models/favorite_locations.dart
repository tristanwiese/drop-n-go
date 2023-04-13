class Favorite{
  final String id;
  final double lat;
  final double lon;

  Favorite({
    required this.id,
    required this.lat,
    required this.lon,
  });
 
 toDB(){
  return{
  "id":id,
  "lat":lat,
  "lon":lon,
  };
 }
}