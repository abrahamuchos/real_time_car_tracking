import 'dart:io';

import 'package:flutter/material.dart';
import 'package:real_time_car_tracking/common/globs.dart';
import 'package:real_time_car_tracking/common/location_manager.dart';
import 'package:real_time_car_tracking/common/my_http_overrides.dart';
import 'package:real_time_car_tracking/common/service_call.dart';
import 'package:real_time_car_tracking/common/socket_manager.dart';
import 'package:real_time_car_tracking/screen/map_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

SharedPreferences? preferences;

void main() async{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  preferences = await SharedPreferences.getInstance();

  ServicesCall.userUuid = Globs.udValueString('uuid');

  if(ServicesCall.userUuid  == ''){
    ServicesCall.userUuid = Uuid().v6();
    Globs.udStringSet(ServicesCall.userUuid , 'uuid');
  }
  SocketManager.shared.initSocket();
  LocationManager.shared.initLocation();

  SocketManager.shared.initSocket();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real Time Car Tracking',
      home: MapScreen(),
    );
  }
}

