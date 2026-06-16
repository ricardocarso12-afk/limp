import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> currentPosition() async {
    var enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception('Location service disabled');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
