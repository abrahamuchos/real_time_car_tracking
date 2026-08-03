import 'dart:async';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:real_time_car_tracking/common/location_manager.dart';
import 'package:real_time_car_tracking/common/service_call.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late LatLng currentPosition;
  Set<Marker> markers = {};
  BitmapDescriptor? icon;

  @override
  void initState() {
    super.initState();

    getIcon();
    currentPosition = LatLng(
      LocationManager.shared.currentPosition?.latitude ?? 0.0,
      LocationManager.shared.currentPosition?.longitude ?? 0.0,
    );

    addMarker();
    FBroadcast.instance().register("update_location", (newLocation, callback) {
      if (newLocation is Position) {
        var mid = MarkerId(ServicesCall.userUuid);
        var newPosition = LatLng(newLocation.latitude, newLocation.longitude);
        markers = {
          Marker(
            markerId: mid,
            position: newPosition,
            icon: icon ?? BitmapDescriptor.defaultMarker,
            anchor: Offset(0.5, 0.5),
            rotation: LocationManager.calculateDegrees(
              currentPosition,
              newPosition,
            ),
          ),
        };
        currentPosition = newPosition;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentPosition, zoom: 15),
      ),
    );
  }

  void addMarker() {
    var mid = MarkerId(ServicesCall.userUuid);
    markers = {
      Marker(
        markerId: mid,
        position: currentPosition,
        icon: icon ?? BitmapDescriptor.defaultMarker,
      ),
    };
    setState(() {});
  }

  getIcon() async {
    var icon = await BitmapDescriptor.asset(
      const ImageConfiguration(devicePixelRatio: 3.2),
      "assets/images/car.png",
      width: 40,
      height: 40,
    );

    setState(() {
      this.icon = icon;
    });
  }

}
