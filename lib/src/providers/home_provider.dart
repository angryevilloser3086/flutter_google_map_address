import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_google_map_address/src/db/db.dart';
import 'package:flutter_google_map_address/src/model/location_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeProvider extends ChangeNotifier {
  var center = const LatLng(0, 0);
  GoogleMapController? mapController;
  final GeolocatorPlatform geolocator = GeolocatorPlatform.instance;
  DB db = DB();
  bool positionStreamStarted = false;
  List<Address> address = [];
  Address? currAddress;

  Future<Address> getLocation() async {
    
     bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Position cord = await geolocator.getCurrentPosition(locationSettings: locationSettings);
    if (cord != null) {
      center = LatLng(cord.latitude, cord.longitude);
      List<Placemark> placemark =
          await placemarkFromCoordinates(cord.latitude, cord.longitude);

      placemark.map((e) {
        currAddress = Address(
            name: e.name,
            street: e.street,
            iSoCode: e.isoCountryCode,
            country: e.country,
            postalCode: e.postalCode,
            adminArea: e.administrativeArea,
            subAdminArea: e.subAdministrativeArea,
            locality: e.locality,
            subLocality: e.subLocality,
            thoroughfare: e.thoroughfare,
            subThoroughFare: e.subThoroughfare);

        //print(address.toList());
      }).toList();
    }
    return currAddress!;
  }

  void determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position? location;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    //var accept = await openDailog(context);

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse) {
        // When we reach here, permissions are granted and we can
        // continue accessing the position of the device.
        Position? location;
        location = await Geolocator.getCurrentPosition();
        //print(location.toJson());
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        permission = Geolocator.openLocationSettings() as LocationPermission;

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (permission == LocationPermission.whileInUse) {
      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.

      location = await Geolocator.getCurrentPosition();
    }
    center = LatLng(location!.latitude, location.longitude);

    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    notifyListeners();
    // print(placemarks.first.toJson());
    // print(placemarks.toList());
  }

  getAddresses() async {
    address = await db.getAdresses();
    // print("object address");
    // print(address.toList());
    notifyListeners();
  }

  
}



//
// {
//   name: 480,
//   street: 480 E Meadow Dr,
//   isoCountryCode: US,
//    country: United States,
//     postalCode: 94306, 
//     administrativeArea: California, 
//     subAdministrativeArea: Santa Clara County, 
//     locality: Palo Alto, 
//     subLocality: , 
//     thoroughfare: East Meadow Drive, 
//     subThoroughfare: 480
//     }