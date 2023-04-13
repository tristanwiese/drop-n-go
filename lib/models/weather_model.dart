// To parse this JSON data, do
//
//     final weatherData = weatherDataFromJson(jsonString);

// ignore_for_file: constant_identifier_names

import 'dart:convert';

WeatherData weatherDataFromJson(String str) => WeatherData.fromJson(json.decode(str));

String weatherDataToJson(WeatherData data) => json.encode(data.toJson());

class WeatherData {
    WeatherData({
        required this.type,
        required this.geometry,
        required this.properties,
    });

    String type;
    Geometry geometry;
    Properties properties;

    factory WeatherData.fromJson(Map<String, dynamic> json) => WeatherData(
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
        required this.airTemperatureMax,
        required this.airTemperatureMin,
        required this.cloudAreaFraction,
        required this.cloudAreaFractionHigh,
        required this.cloudAreaFractionLow,
        required this.cloudAreaFractionMedium,
        required this.dewPointTemperature,
        required this.fogAreaFraction,
        required this.precipitationAmount,
        required this.relativeHumidity,
        required this.ultravioletIndexClearSky,
        required this.windFromDirection,
        required this.windSpeed,
    });

    String airPressureAtSeaLevel;
    String airTemperature;
    String airTemperatureMax;
    String airTemperatureMin;
    String cloudAreaFraction;
    String cloudAreaFractionHigh;
    String cloudAreaFractionLow;
    String cloudAreaFractionMedium;
    String dewPointTemperature;
    String fogAreaFraction;
    String precipitationAmount;
    String relativeHumidity;
    String ultravioletIndexClearSky;
    String windFromDirection;
    String windSpeed;

    factory Units.fromJson(Map<String, dynamic> json) => Units(
        airPressureAtSeaLevel: json["air_pressure_at_sea_level"],
        airTemperature: json["air_temperature"],
        airTemperatureMax: json["air_temperature_max"],
        airTemperatureMin: json["air_temperature_min"],
        cloudAreaFraction: json["cloud_area_fraction"],
        cloudAreaFractionHigh: json["cloud_area_fraction_high"],
        cloudAreaFractionLow: json["cloud_area_fraction_low"],
        cloudAreaFractionMedium: json["cloud_area_fraction_medium"],
        dewPointTemperature: json["dew_point_temperature"],
        fogAreaFraction: json["fog_area_fraction"],
        precipitationAmount: json["precipitation_amount"],
        relativeHumidity: json["relative_humidity"],
        ultravioletIndexClearSky: json["ultraviolet_index_clear_sky"],
        windFromDirection: json["wind_from_direction"],
        windSpeed: json["wind_speed"],
    );

    Map<String, dynamic> toJson() => {
        "air_pressure_at_sea_level": airPressureAtSeaLevel,
        "air_temperature": airTemperature,
        "air_temperature_max": airTemperatureMax,
        "air_temperature_min": airTemperatureMin,
        "cloud_area_fraction": cloudAreaFraction,
        "cloud_area_fraction_high": cloudAreaFractionHigh,
        "cloud_area_fraction_low": cloudAreaFractionLow,
        "cloud_area_fraction_medium": cloudAreaFractionMedium,
        "dew_point_temperature": dewPointTemperature,
        "fog_area_fraction": fogAreaFraction,
        "precipitation_amount": precipitationAmount,
        "relative_humidity": relativeHumidity,
        "ultraviolet_index_clear_sky": ultravioletIndexClearSky,
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
    Next1Hours? next1Hours;
    Next6Hours? next6Hours;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        instant: Instant.fromJson(json["instant"]),
        next12Hours: json["next_12_hours"] == null ? null : Next12Hours.fromJson(json["next_12_hours"]),
        next1Hours: json["next_1_hours"] == null ? null : Next1Hours.fromJson(json["next_1_hours"]),
        next6Hours: json["next_6_hours"] == null ? null : Next6Hours.fromJson(json["next_6_hours"]),
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

    Map<String, double> details;

    factory Instant.fromJson(Map<String, dynamic> json) => Instant(
        details: Map.from(json["details"]).map((k, v) => MapEntry<String, double>(k, v?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "details": Map.from(details).map((k, v) => MapEntry<String, dynamic>(k, v)),
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

enum SymbolCode { PARTLYCLOUDY_DAY, PARTLYCLOUDY_NIGHT, CLOUDY, FAIR_NIGHT, CLEARSKY_NIGHT, CLEARSKY_DAY, FAIR_DAY, LIGHTRAINSHOWERS_DAY, RAINSHOWERS_DAY, RAIN, HEAVYRAIN, RAINSHOWERS_NIGHT }

final symbolCodeValues = EnumValues({
    "clearsky_day": SymbolCode.CLEARSKY_DAY,
    "clearsky_night": SymbolCode.CLEARSKY_NIGHT,
    "cloudy": SymbolCode.CLOUDY,
    "fair_day": SymbolCode.FAIR_DAY,
    "fair_night": SymbolCode.FAIR_NIGHT,
    "heavyrain": SymbolCode.HEAVYRAIN,
    "lightrainshowers_day": SymbolCode.LIGHTRAINSHOWERS_DAY,
    "partlycloudy_day": SymbolCode.PARTLYCLOUDY_DAY,
    "partlycloudy_night": SymbolCode.PARTLYCLOUDY_NIGHT,
    "rain": SymbolCode.RAIN,
    "rainshowers_day": SymbolCode.RAINSHOWERS_DAY,
    "rainshowers_night": SymbolCode.RAINSHOWERS_NIGHT
});

class Next1Hours {
    Next1Hours({
        required this.summary,
        required this.details,
    });

    Summary summary;
    Next1HoursDetails details;

    factory Next1Hours.fromJson(Map<String, dynamic> json) => Next1Hours(
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

class Next6Hours {
    Next6Hours({
        required this.summary,
        required this.details,
    });

    Summary summary;
    Next6HoursDetails details;

    factory Next6Hours.fromJson(Map<String, dynamic> json) => Next6Hours(
        summary: Summary.fromJson(json["summary"]),
        details: Next6HoursDetails.fromJson(json["details"]),
    );

    Map<String, dynamic> toJson() => {
        "summary": summary.toJson(),
        "details": details.toJson(),
    };
}

class Next6HoursDetails {
    Next6HoursDetails({
        required this.airTemperatureMax,
        required this.airTemperatureMin,
        required this.precipitationAmount,
    });

    double airTemperatureMax;
    double airTemperatureMin;
    double precipitationAmount;

    factory Next6HoursDetails.fromJson(Map<String, dynamic> json) => Next6HoursDetails(
        airTemperatureMax: json["air_temperature_max"]?.toDouble(),
        airTemperatureMin: json["air_temperature_min"]?.toDouble(),
        precipitationAmount: json["precipitation_amount"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "air_temperature_max": airTemperatureMax,
        "air_temperature_min": airTemperatureMin,
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
