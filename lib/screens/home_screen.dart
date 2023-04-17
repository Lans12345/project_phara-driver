import 'dart:async';

import 'package:badges/badges.dart' as b;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phara_driver/widgets/toast_widget.dart';

import '../plugins/my_location.dart';
import '../utils/colors.dart';
import '../widgets/book_bottomsheet_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/text_widget.dart';
import 'pages/messages_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late String currentAddress;

  late double lat = 0;
  late double long = 0;

  var hasLoaded = false;

  GoogleMapController? mapController;

  Set<Marker> markers = {};

  var _value = false;

  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Drivers')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    final CameraPosition camPosition = CameraPosition(
        target: LatLng(lat, long), zoom: 16, bearing: 45, tilt: 40);
    return hasLoaded
        ? Scaffold(
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: (() {
                      mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              bearing: 45,
                              tilt: 40,
                              target: LatLng(lat, long),
                              zoom: 16)));
                    }),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Colors.red,
                    )),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: (() {
                      // Navigator.of(context).pushReplacement(MaterialPageRoute(
                      //     builder: (context) => const BookmarksPage()));
                    }),
                    child: const Icon(
                      Icons.send,
                      color: Colors.red,
                    )),
              ],
            ),
            drawer: Drawer(
              child: DrawerWidget(),
            ),
            appBar: AppBar(
              title:
                  TextRegular(text: 'Home', fontSize: 24, color: Colors.black),
              foregroundColor: grey,
              backgroundColor: Colors.white,
              actions: [
                b.Badge(
                  position: b.BadgePosition.custom(start: -1, top: 3),
                  badgeContent: TextRegular(
                    text: '1',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: (() {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MessagesTab()));
                    }),
                    icon: const Icon(Icons.message_outlined),
                  ),
                ),
                b.Badge(
                  position: b.BadgePosition.custom(start: -1, top: 3),
                  badgeContent: TextRegular(
                    text: '1',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    onPressed: (() {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => const MessagesTab()));
                    }),
                    icon: const Icon(Icons.notifications),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                StreamBuilder<DocumentSnapshot>(
                    stream: userData,
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: Text('Loading'));
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      dynamic data = snapshot.data;
                      return Container(
                        padding: const EdgeInsets.only(right: 20),
                        width: 50,
                        child: SwitchListTile(
                          value: data['isActive'],
                          onChanged: (value) {
                            setState(() {
                              _value = value;
                              if (_value == true) {
                                FirebaseFirestore.instance
                                    .collection('Drivers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'isActive': true,
                                });
                                showToast(
                                    'Status: Active\nPassengers can now book a ride');
                              } else {
                                FirebaseFirestore.instance
                                    .collection('Drivers')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .update({
                                  'isActive': false,
                                });
                                showToast(
                                    'Status: Inactive\nPassengers will not be able to book a ride');
                              }
                            });
                          },
                        ),
                      );
                    }),
              ],
            ),
            body: Stack(
              children: [
                GoogleMap(
                  buildingsEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: false,
                  markers: markers,
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  initialCameraPosition: camPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {
                      myLocationMarker(lat, long);
                      mapController = controller;
                    });
                  },
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ButtonWidget(
                          width: 175,
                          radius: 100,
                          opacity: 1,
                          color: Colors.green,
                          label: 'View passenger',
                          onPressed: (() {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                builder: ((context) {
                                  return BookBottomSheetWidget();
                                }));
                          })),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }

  myLocationMarker(double lat, double lang) async {
    Marker mylocationMarker = Marker(
        markerId: const MarkerId('currentLocation'),
        infoWindow: const InfoWindow(
          title: 'Your Current Location',
        ),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(lat, lang));

    markers.add(mylocationMarker);
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> p =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = p[0];

    setState(() {
      lat = position.latitude;
      long = position.longitude;
      currentAddress =
          '${place.street}, ${place.subLocality}, ${place.locality}';
      hasLoaded = true;
    });

    Timer.periodic(const Duration(minutes: 3), (timer) {
      StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream().listen(
        (position) {
          FirebaseFirestore.instance
              .collection('Drivers')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'location': {'lat': position.latitude, 'long': position.longitude},
          });
        },
        onError: (error) {
          print('Error getting location stream: $error');
        },
        cancelOnError: true,
      );
    });
  }
}
