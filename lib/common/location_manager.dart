import 'dart:async';
import 'dart:math' as Math;

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_car_tracking/helpers/ansi_color.dart';

class LocationManager {
  // Constructor privado para tener una unica instancia
  static final LocationManager singleton = LocationManager._internal();

  LocationManager._internal();

  Position? currentPosition;
  double carDegree = 0.0;

  static LocationManager get shared => singleton;

  void initLocation() {
    getLocationUpdates();
  }

  getLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint(
        "${AnsiColor.red}Location service is disabled${AnsiColor.reset}",
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint(
          '${AnsiColor.red}Location permission is denied${AnsiColor.reset}',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
        '${AnsiColor.red}Location permission are permanently denied${AnsiColor
            .reset}',
      );
      return;
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5,
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      carDegree = calculateDegrees(
        LatLng(
          currentPosition?.latitude ?? 0.0,
          currentPosition?.longitude ?? 0.0,
        ),
        LatLng(position.latitude, position.longitude),
      );
      currentPosition = position;
      FBroadcast.instance().broadcast("update_location", value: position);
      debugPrint(AnsiColor.green + position.toString() + AnsiColor.reset);
    });
  }

  // Util para calcular la dirección del carro (icono)
  static double calculateDegrees(LatLng startPoint, LatLng endPoint) {
    final double startLat = toRadian(startPoint.latitude);
    final double startLng = toRadian(startPoint.longitude);
    final double endLat = toRadian(endPoint.latitude);
    final double endLng = toRadian(endPoint.longitude);

    final double deltaLng = endLng - startLng;

    final double x =
    (Math.cos(startLat) * Math.sin(endLat) -
        Math.sin(startLat) * Math.cos(endLat) * Math.cos(deltaLng));
    final double y = Math.sin(deltaLng) * Math.cos(endLat);

    final double bearing = Math.atan2(y, x);

    return (toDegree(bearing) + 360) % 360;
  }

  static double toRadian(double degree) {
    return degree * (Math.pi / 180.0);
  }

  static double toDegree(double radian) {
    return radian * (180 / Math.pi);
  }
}
