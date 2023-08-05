import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tugas_15/location_model.dart';

class MyLocation {
  final String _apiKey = 'AIzaSyBjQl39UDNHgRNM00GAXB_MCQ6YBLLQDHU';
  final int _nearbyRadius = 5000;
  final _placeType = 'lodging';

  Future<List<NearbyLocation>> getNearbyLodging(LatLng latLng) async {
    try {
      var res = await Dio().get(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latLng.latitude},${latLng.longitude}&radius=$_nearbyRadius&type=$_placeType&key=$_apiKey');
      List data = res.data['results'] as List;
      return data.map((e) => NearbyLocation.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<String> getUrl(String placeId) async {
    var url = await Dio().get(
        'https://maps.googleapis.com/maps/api/place/details/json?key=$_apiKey&placeid=$placeId');
    return url.data['result']['url'];
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
