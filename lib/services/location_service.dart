import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled with a timeout.
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 5));
    } catch (_) {
      serviceEnabled = false;
    }
    
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      debugPrint('Location services are disabled.');
      return false;
    }
    
    try {
      permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 5));
    } catch (_) {
      permission = LocationPermission.denied;
    }
    
    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 10));
      } catch (_) {
        permission = LocationPermission.denied;
      }
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately. 
      debugPrint('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}
