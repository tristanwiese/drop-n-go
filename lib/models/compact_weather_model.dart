// To parse this JSON data, do
//
//     final compactWeatherData = compactWeatherDataFromJson(jsonString);

import 'dart:convert';

CompactWeatherData compactWeatherDataFromJson(String str) => CompactWeatherData.fromJson(json.decode(str));

String compactWeatherDataToJson(CompactWeatherData data) => json.encode(data.toJson());

class CompactWeatherData {
    CompactWeatherData({
        required this.type,
        required this.geometry,
        required this.properties,
    });

    String type;
    Geometry geometry;
    Properties properties;

    factory CompactWeatherData.fromJson(Map<String, dynamic> json) => CompactWeatherData(
        type: json["type"],
        geometry: Geometry.fromJson(json["geometry"]),
        properties: Properties.fromJson(json["properties"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
    };
}

class Geometry {
    Geometry({
        required this.type,
        required this.coordinates,
    });

    String type;
    List<double> coordinates;

    factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates: List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
    };
}

class Properties {
    Properties({
        required this.meta,
        required this.timeseries,
    });

    Meta meta;
    List<Timesery> timeseries;

    factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        meta: Meta.fromJson(json["meta"]),
        timeseries: List<Timesery>.from(json["timeseries"].map((x) => Timesery.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "meta": meta.toJson(),
        "timeseries": List<dynamic>.from(timeseries.map((x) => x.toJson())),
    };
}

class Meta {
    Meta({
        required this.updatedAt,
        required this.units,
    });

    DateTime updatedAt;
    Units units;

    factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        updatedAt: DateTime.parse(json["updated_at"]),
        units: Units.fromJson(json["units"]),
    );

    Map<String, dynamic> toJson() => {
        "updated_at": updatedAt.toIso8601String(),
        "units": units.toJson(),
    };
}

class Units {
    Units({
        required this.airPressureAtSeaLevel,
        required this.airTemperature,
        required this.cloudAreaFraction,
        required this.precipitationAmount,
        required this.relativeHumidity,
        required this.windFromDirection,
        required this.windSpeed,
    });

    String airPressureAtSeaLevel;
    String airTemperature;
    String cloudAreaFraction;
    String precipitationAmount;
    String relativeHumidity;
    String windFromDirection;
    String windSpeed;

    factory Units.fromJson(Map<String, dynamic> json) => Units(
        airPressureAtSeaLevel: json["air_pressure_at_sea_level"],
        airTemperature: json["air_temperature"],
        cloudAreaFraction: json["cloud_area_fraction"],
        precipitationAmount: json["precipitation_amount"],
        relativeHumidity: json["relative_humidity"],
        windFromDirection: json["wind_from_direction"],
        windSpeed: json["wind_speed"],
    );

    Map<String, dynamic> toJson() => {
        "air_pressure_at_sea_level": airPressureAtSeaLevel,
        "air_temperature": airTemperature,
        "cloud_area_fraction": cloudAreaFraction,
        "precipitation_amount": precipitationAmount,
        "relative_humidity": relativeHumidity,
        "wind_from_direction": windFromDirection,
        "wind_speed": windSpeed,
    };
}

class Timesery {
    Timesery({
        required this.time,
        required this.data,
    });

    DateTime time;
    Data data;

    factory Timesery.fromJson(Map<String, dynamic> json) => Timesery(
        time: DateTime.parse(json["time"]),
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "time": time.toIso8601String(),
        "data": data.toJson(),
    };
}

class Data {
    Data({
        required this.instant,
        this.next12Hours,
        this.next1Hours,
        this.next6Hours,
    });

    Instant instant;
    Next12Hours? next12Hours;
    NextHours? next1Hours;
    NextHours? next6Hours;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        instant: Instant.fromJson(json["instant"]),
        next12Hours: json["next_12_hours"] == null ? null : Next12Hours.fromJson(json["next_12_hours"]),
        next1Hours: json["next_1_hours"] == null ? null : NextHours.fromJson(json["next_1_hours"]),
        next6Hours: json["next_6_hours"] == null ? null : NextHours.fromJson(json["next_6_hours"]),
    );

    Map<String, dynamic> toJson() => {
        "instant": instant.toJson(),
        "next_12_hours": next12Hours?.toJson(),
        "next_1_hours": next1Hours?.toJson(),
        "next_6_hours": next6Hours?.toJson(),
    };
}

class Instant {
    Instant({
        required this.details,
    });

    InstantDetails details;

    factory Instant.fromJson(Map<String, dynamic> json) => Instant(
        details: InstantDetails.fromJson(json["details"]),
    );

    Map<String, dynamic> toJson() => {
        "details": details.toJson(),
    };
}

class InstantDetails {
    InstantDetails({
        required this.airPressureAtSeaLevel,
        required this.airTemperature,
        required this.cloudAreaFraction,
        required this.relativeHumidity,
        required this.windFromDirection,
        required this.windSpeed,
    });

    double airPressureAtSeaLevel;
    double airTemperature;
    double cloudAreaFraction;
    double relativeHumidity;
    double windFromDirection;
    double windSpeed;

    factory InstantDetails.fromJson(Map<String, dynamic> json) => InstantDetails(
        airPressureAtSeaLevel: json["air_pressure_at_sea_level"]?.toDouble(),
        airTemperature: json["air_temperature"]?.toDouble(),
        cloudAreaFraction: json["cloud_area_fraction"]?.toDouble(),
        relativeHumidity: json["relative_humidity"]?.toDouble(),
        windFromDirection: json["wind_from_direction"]?.toDouble(),
        windSpeed: json["wind_speed"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "air_pressure_at_sea_level": airPressureAtSeaLevel,
        "air_temperature": airTemperature,
        "cloud_area_fraction": cloudAreaFraction,
        "relative_humidity": relativeHumidity,
        "wind_from_direction": windFromDirection,
        "wind_speed": windSpeed,
    };
}

class Next12Hours {
    Next12Hours({
        required this.summary,
    });

    Summary summary;

    factory Next12Hours.fromJson(Map<String, dynamic> json) => Next12Hours(
        summary: Summary.fromJson(json["summary"]),
    );

    Map<String, dynamic> toJson() => {
        "summary": summary.toJson(),
    };
}

class Summary {
    Summary({
        required this.symbolCode,
    });

    SymbolCode symbolCode;

    factory Summary.fromJson(Map<String, dynamic> json) => Summary(
        symbolCode: symbolCodeValues.map[json["symbol_code"]]!,
    );

    Map<String, dynamic> toJson() => {
        "symbol_code": symbolCodeValues.reverse[symbolCode],
    };
}

// ignore: constant_identifier_names
enum SymbolCode { CLOUDY, PARTLYCLOUDY_DAY, LIGHTRAINSHOWERS_DAY, FAIR_DAY, FAIR_NIGHT, PARTLYCLOUDY_NIGHT, CLEARSKY_DAY, CLEARSKY_NIGHT, LIGHTRAIN, LIGHTRAINSHOWERS_NIGHT, RAIN }

final symbolCodeValues = EnumValues({
    "clearsky_day": SymbolCode.CLEARSKY_DAY,
    "clearsky_night": SymbolCode.CLEARSKY_NIGHT,
    "cloudy": SymbolCode.CLOUDY,
    "fair_day": SymbolCode.FAIR_DAY,
    "fair_night": SymbolCode.FAIR_NIGHT,
    "lightrain": SymbolCode.LIGHTRAIN,
    "lightrainshowers_day": SymbolCode.LIGHTRAINSHOWERS_DAY,
    "lightrainshowers_night": SymbolCode.LIGHTRAINSHOWERS_NIGHT,
    "partlycloudy_day": SymbolCode.PARTLYCLOUDY_DAY,
    "partlycloudy_night": SymbolCode.PARTLYCLOUDY_NIGHT,
    "rain": SymbolCode.RAIN
});

class NextHours {
    NextHours({
        required this.summary,
        required this.details,
    });

    Summary summary;
    Next1HoursDetails details;

    factory NextHours.fromJson(Map<String, dynamic> json) => NextHours(
        summary: Summary.fromJson(json["summary"]),
        details: Next1HoursDetails.fromJson(json["details"]),
    );

    Map<String, dynamic> toJson() => {
        "summary": summary.toJson(),
        "details": details.toJson(),
    };
}

class Next1HoursDetails {
    Next1HoursDetails({
        required this.precipitationAmount,
    });

    double precipitationAmount;

    factory Next1HoursDetails.fromJson(Map<String, dynamic> json) => Next1HoursDetails(
        precipitationAmount: json["precipitation_amount"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "precipitation_amount": precipitationAmount,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
