import 'dart:async';

import 'package:badges/badges.dart' as b;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:phara_driver/screens/pages/messages_tab.dart';
import 'package:phara_driver/widgets/toast_widget.dart';

import '../data/user_stream.dart';
import '../plugins/my_location.dart';
import '../utils/colors.dart';
import '../widgets/book_bottomsheet_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/text_widget.dart';

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
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Messages')
                        .where('driverId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('seen', isEqualTo: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print('error');
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.black,
                          )),
                        );
                      }

                      final data = snapshot.requireData;
                      return b.Badge(
                        position: b.BadgePosition.custom(top: 5, start: -5),
                        showBadge: data.docs.isNotEmpty,
                        badgeAnimation: const b.BadgeAnimation.fade(),
                        badgeStyle: const b.BadgeStyle(
                          badgeColor: Colors.red,
                        ),
                        badgeContent: TextRegular(
                            text: data.docs.length.toString(),
                            fontSize: 12,
                            color: Colors.white),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MessagesTab()));
                            },
                            child: const Icon(
                              Icons.message_outlined,
                              color: grey,
                            ),
                          ),
                        ),
                      );
                    }),
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseData().userData,
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

                      List oldnotifs = data['notif'];

                      List notifs = oldnotifs.reversed.toList();
                      return PopupMenuButton(
                          icon: b.Badge(
                            showBadge: notifs.isNotEmpty,
                            badgeContent: TextRegular(
                              text: data['notif'].length.toString(),
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            child: const Icon(Icons.notifications_rounded),
                          ),
                          itemBuilder: (context) {
                            return [
                              for (int i = 0; i < notifs.length; i++)
                                PopupMenuItem(
                                    child: ListTile(
                                  title: TextRegular(
                                      text: notifs[i]['notif'],
                                      fontSize: 14,
                                      color: Colors.black),
                                  subtitle: TextRegular(
                                      text: DateFormat.yMMMd()
                                          .add_jm()
                                          .format(notifs[i]['date'].toDate()),
                                      fontSize: 10,
                                      color: grey),
                                  leading: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: grey,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('Users')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .update({
                                        'notif':
                                            FieldValue.arrayRemove([notifs[i]]),
                                      });
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: grey,
                                    ),
                                  ),
                                )),
                            ];
                          });
                    }),
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

    Timer.periodic(const Duration(minutes: 5), (timer) {
      Geolocator.getCurrentPosition().then((position) {
        FirebaseFirestore.instance
            .collection('Drivers')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'location': {'lat': position.latitude, 'long': position.longitude},
        });
      }).catchError((error) {
        print('Error getting location: $error');
      });
    });
  }
}
