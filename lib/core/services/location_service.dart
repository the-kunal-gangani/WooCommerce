import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'storage_services.dart';

class LocationService extends GetxService {
  LocationService(this._storage);

  final StorageService _storage;

  static const String _cityKey = 'user_city';

  final city = ''.obs;
  final isLoading = false.obs;

  String? get savedCity {
    final value = _storage.read<String>(_cityKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  @override
  void onInit() {
    super.onInit();
    final saved = savedCity;
    if (saved != null) {
      city.value = saved;
    }
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<String?> detectCity() async {
    if (isLoading.value) return city.value.isEmpty ? null : city.value;
    isLoading.value = true;
    try {
      final hasPermission = await _ensurePermission();
      if (!hasPermission) {
        return null;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      final geocoding = Geocoding();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        return null;
      }
      final placemark = placemarks.first;
      final detectedCity = _extractCity(placemark);
      if (detectedCity == null) {
        return null;
      }
      city.value = detectedCity;
      await _storage.write(_cityKey, detectedCity);
      return detectedCity;
    } catch (e) {
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractCity(Placemark placemark) {
    final candidates = [
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
    ];
    for (final value in candidates) {
      final city = value?.trim();
      if (city != null && city.isNotEmpty) {
        return city;
      }
    }
    return null;
  }

  Future<void> clearCity() async {
    city.value = '';
    await _storage.remove(_cityKey);
  }
}
