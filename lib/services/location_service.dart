import 'package:geolocator/geolocator.dart';
import 'package:pavisense/models/location_model.dart';

class LocationService {
  Future<LocationModel?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LocationModel(latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
