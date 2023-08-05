import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tugas_15/home.dart';
import 'package:tugas_15/location_service.dart';

bool locPermission = false;
late Position userPosition;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locPermission = await MyLocation().handleLocationPermission();

  if (locPermission) {
    userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: HomeScreen()),
    );
  }
}
