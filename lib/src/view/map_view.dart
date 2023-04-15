import 'dart:async';
import 'package:flutter_google_map_address/src/app_utils.dart';
import 'package:flutter_google_map_address/src/db/db.dart';
import 'package:flutter_google_map_address/src/model/addr_type.dart';
import 'package:flutter_google_map_address/src/model/location_model.dart';
import 'package:flutter_google_map_address/src/view/home_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  TextEditingController flatNo = TextEditingController();
  TextEditingController house = TextEditingController();
  TextEditingController other = TextEditingController();
  DB db = DB();
  LatLng? markerPos;
  LatLng? initPos;
  Address? address;
  Set<Marker> markers = {};
  TextEditingController? searchPlaceController;
  bool loadingMap = false;
  bool init = true;
  bool loadingAddressDetails = false;
  String addressTitle = '';
  String locality = '';
  String city = '';
  String state = '';
  String pincode = '';
  String country = '';
  String street = '';
  List<TypeAddr> listAdd = [];
  List<String> list = ['Home', 'Work', 'Friends/Family', "Other"];
  TypeAddr? _typeAddr;
  List<IconData> iconsDat = [
    Icons.home,
    Icons.work,
    Icons.person,
    Icons.my_location_sharp
  ];

  StreamController<LatLng> streamController = StreamController();

  void fetchAddressDetail(LatLng location) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
    print(placemarks.first.toJson());
    setState(() {
      street = placemarks[0].street!;
      addressTitle = placemarks[0].name!;
      locality = placemarks[0].locality!;
      city = placemarks[0].subAdministrativeArea!;
      pincode = placemarks[0].postalCode!;
      state = placemarks[0].administrativeArea!;
      country = placemarks[0].country!;
    });
  }

  getCurrentLoc() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    initPos = LatLng(position.latitude, position.longitude);
    streamController.add(initPos as LatLng);
    setState(() {
      loadingMap = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadingMap = true;
    getCurrentLoc();
    for (int i = 0; i < 4; i++) {
      listAdd.add(
          TypeAddr(name: list[i], iconName: iconsDat[i], isSelected: false));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    streamController.close();
  }

  renderMap() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: (loadingMap)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              buildingsEnabled: true,
              indoorViewEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
                setState(() {
                  fetchAddressDetail(initPos!);
                });
              },
              circles: {
                Circle(
                    circleId: const CircleId("1"), center: initPos!, radius: 10)
              },
              onCameraMove: (CameraPosition pos) {
                streamController.add(pos.target);
              },
              markers: markers,
              initialCameraPosition: CameraPosition(
                target: initPos!,
                zoom: 14.4746,
              ),
              onTap: (latLang) {
                //print(latLang.toJson());
                setAddress(latLang);
                setState(() {});
              },
              mapType: MapType.terrain,
            ),
    );
  }

  setAddress(LatLng latLng) {
    setState(() {
      markerPos = latLng;
      markers.add(Marker(
        markerId: const MarkerId('1'),
        position: latLng,
        onTap: () {
          //print("Tapped");
        },
      ));
      fetchAddressDetail(markerPos!);
    });
  }

  backButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      color: Colors.black87,
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            renderMap(),
            Positioned(
                bottom: 0,
                child: SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height * getHeight(),
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.orange[200],
                              size: MediaQuery.of(context).size.width * 0.08,
                            ),
                            const Padding(padding: EdgeInsets.all(2)),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addressTitle,
                                  style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87),
                                ),
                                const Padding(padding: EdgeInsets.all(2)),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*.8,
                                  child: Text(
                                    "$locality,$city,$state,$pincode,$country",
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const Padding(padding: EdgeInsets.all(10)),
                        Expanded(
                          child: Column(children: [
                            TextField(
                              decoration: AppConstants.inputDecorationValidate(
                                  context, "House/Flat/Floor No."),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextField(
                              decoration: AppConstants.inputDecorationValidate(
                                  context, "Appartment/Road/Area(optional)"),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: listAdd.map((typeAddr) {
                                  return toBox(typeAddr);
                                }).toList(),
                              ),
                            ),
                            if (_typeAddr != null && _typeAddr!.name == "Other")
                              TextField(
                                controller: other,
                                decoration:
                                    AppConstants.inputDecorationValidate(
                                        context, "Enter the name"),
                              ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                if (_typeAddr != null) {
                                  updateAddress();
                                } else {
                                  AppConstants.showSnackBar(context,
                                      "please select the type of Address!");
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.orangeAccent[400],
                                    borderRadius: BorderRadius.circular(5)),
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: const Center(
                                  child: Text(
                                    'Confirm Address',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ]),
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      )),
    );
  }

  double getHeight() {
    if (_typeAddr != null) {
      if (_typeAddr!.name == "Other") {
        return 0.5;
      }
      return 0.45;
    }
    return 0.45;
  }

  InkWell toBox(TypeAddr typeAddr) {
    return InkWell(
      onTap: () {
        setState(() {
          _typeAddr = typeAddr;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: getDecoration(typeAddr),
          child: Row(
            children: [Icon(typeAddr.iconName, size: 20), Text(typeAddr.name!)],
          ),
        ),
      ),
    );
  }

  getDecoration(TypeAddr typeAddr) {
    if (_typeAddr != null) {
      if (typeAddr.name == _typeAddr!.name) {
        return AppConstants.boxBorderDecorationPrimary;
      } else {
        return AppConstants.boxBorderDecoration;
      }
    } else {
      return AppConstants.boxBorderDecoration;
    }
  }

  void updateAddress() {
    address = Address(
        title: _typeAddr!.name != "Other" ? _typeAddr!.name : other.text,
        name: flatNo.text.isEmpty ? addressTitle : flatNo.text,
        street: street,
        subAdminArea: "",
        adminArea: state,
        locality: locality,
        subLocality: city,
        thoroughfare: "",
        subThoroughFare: "",
        country: country,
        iSoCode: "",
        postalCode: pincode);
    db.insertAddr(address!).then((value) {
      AppConstants.showSnackBar(context, "Address updated Successfully");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const HomeScreen(), maintainState: false),
      );
    }).catchError((err) {
      throw Exception(err);
    });
  }
}
