import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> fetchNearbyPharmaciesOnDuty() async {
    // Si on tourne sur le Web, on simule la réponse GPS pour éviter le crash du compilateur
    if (kIsWeb) {
      await Future.delayed(const Duration(seconds: 1));
      return Position(
        longitude: 11.5167,
        latitude: 3.8667,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );
    }

    // Code pour Android / iOS réel
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de géolocalisation sont désactivés.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Les permissions de géolocalisation ont été refusées.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions sont refusées définitivement.');
    } 

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
