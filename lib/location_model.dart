import 'package:google_maps_flutter/google_maps_flutter.dart';

// API Google Maps
class NearbyLocation {
  String businessStatus;
  LatLng? latLng;
  String icon;
  String iconBg;
  String name;
  String placeId;
  String address;
  String reference;
  bool isOpen;
  String? photo;
  NearbyLocation({
    required this.businessStatus,
    required this.latLng,
    required this.icon,
    required this.iconBg,
    required this.name,
    required this.placeId,
    required this.address,
    required this.reference,
    this.isOpen = false,
    this.photo,
  });

  factory NearbyLocation.fromJson(Map<String, dynamic> json) {
    return NearbyLocation(
        businessStatus: json['business_status'] ?? '',
        latLng: LatLng(json['geometry']['location']['lat'] ?? 0,
            json['geometry']['location']['lng'] ?? 0),
        icon: json['icon'] ?? '',
        iconBg: json['icon_background_color'],
        name: json['name'] ?? '',
        placeId: json['place_id'] ?? '',
        address: json['vicinity'] ?? '',
        reference: json['reference'] ?? '',
        photo: json['photos'] == null
            ? null
            : 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${json['photos'][0]['photo_reference']}&key=AIzaSyCE-jK-YTXkl89RkMQrJ5ruCIsrfcG3cWs',
        isOpen: json.containsKey('opening_hours')
            ? json['opening_hours']['open_now'] != Null
            : false);
  }
}
