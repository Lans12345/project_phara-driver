import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:badges/badges.dart' as b;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:phara_driver/screens/pages/delivery/delivery_page.dart';
import 'package:phara_driver/screens/pages/messages_tab.dart';
import 'package:phara_driver/screens/pages/tracking_user_page.dart';
import 'package:phara_driver/screens/pages/trips_page.dart';
import 'package:phara_driver/widgets/toast_widget.dart';

import '../data/user_stream.dart';
import '../plugins/my_location.dart';
import '../utils/colors.dart';
import '../widgets/button_widget.dart';
import '../widgets/drawer_widget.dart';
import '../widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    FirebaseFirestore.instance
        .collection('Drivers')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((event) async {
      for (var element in event.docChanges) {
        if (element.type == DocumentChangeType.modified) {
          final player = AudioPlayer();
          player.setVolume(1);
          await player.play(AssetSource('music/sound.wav'));
        }
      }
    });
    super.initState();
    determinePosition();
    getLocation();
    getDrivers();
  }

  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  late String currentAddress;

  late double lat = 0;
  late double long = 0;

  var hasLoaded = false;

  // GoogleMapController? mapController;

  // Set<Marker> markers = {};

  var _value = false;

  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Drivers')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();

  final mapController = MapController();

  List<Marker> myMarkers = [];

  late List<CircleMarker> myCircles = [];

  @override
  Widget build(BuildContext context1) {
    // final CameraPosition camPosition = CameraPosition(
    //     target: LatLng(lat, long), zoom: 16, bearing: 80, tilt: 45);

    return hasLoaded && lat != 0
        ? Scaffold(
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Delivery')
                        .where('driverId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('status', isEqualTo: 'Pending')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print('error');
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      final data = snapshot.requireData;
                      return FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: (() {
                            if (data.docs.isNotEmpty) {
                              Navigator.of(context1).push(MaterialPageRoute(
                                  builder: (context) => const DeliveryPage()));
                            } else {
                              showToast('No bookings for delivery');
                            }
                          }),
                          child: b.Badge(
                            showBadge: data.docs.isNotEmpty,
                            badgeContent: TextRegular(
                                text: data.docs.length.toString(),
                                fontSize: 12,
                                color: Colors.white),
                            badgeStyle:
                                b.BadgeStyle(badgeColor: Colors.amber[600]!),
                            child: AvatarGlow(
                              animate: data.docs.isNotEmpty,
                              glowColor: Colors.amber,
                              duration: const Duration(milliseconds: 2000),
                              repeat: true,
                              child: Icon(
                                Icons.delivery_dining_outlined,
                                color: data.docs.isNotEmpty
                                    ? Colors.amber[600]
                                    : grey,
                              ),
                            ),
                          ));
                    }),
                const SizedBox(
                  height: 15,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Bookings')
                        .where('driverId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('status', isEqualTo: 'Pending')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        print('error');
                        return const Center(child: Text('Error'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }

                      final data = snapshot.requireData;
                      return FloatingActionButton(
                          backgroundColor: Colors.white,
                          onPressed: (() {
                            if (data.docs.isNotEmpty) {
                              showBookingData(data);
                            } else {
                              showToast('No bookings');
                            }
                          }),
                          child: b.Badge(
                            showBadge: data.docs.isNotEmpty,
                            badgeContent: TextRegular(
                                text: data.docs.length.toString(),
                                fontSize: 12,
                                color: Colors.white),
                            badgeStyle:
                                b.BadgeStyle(badgeColor: Colors.amber[600]!),
                            child: AvatarGlow(
                              animate: data.docs.isNotEmpty,
                              glowColor: Colors.amber,
                              duration: const Duration(milliseconds: 2000),
                              repeat: true,
                              child: Icon(
                                Icons.groups,
                                color: data.docs.isNotEmpty
                                    ? Colors.amber[600]
                                    : grey,
                              ),
                            ),
                          ));
                    }),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: (() {
                      Navigator.of(context1).pushReplacement(MaterialPageRoute(
                          builder: (context) => const TripsPage()));
                    }),
                    child: const Icon(
                      Icons.collections_bookmark_outlined,
                      color: grey,
                    )),
                const SizedBox(
                  height: 15,
                ),
                FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: (() {
                      Navigator.of(context1).pushReplacement(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    }),
                    child: const Icon(
                      Icons.refresh,
                      color: grey,
                    )),
              ],
            ),
            drawer: const Drawer(
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
                        return const SizedBox();
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
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
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
                                          .collection('Drivers')
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
                        return const SizedBox();
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Something went wrong'));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox();
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
                // CustomGoogleMapMarkerBuilder(
                //     screenshotDelay: const Duration(seconds: 5),
                //     customMarkers: _customMarkers,
                //     builder: (BuildContext context, Set<Marker>? markers1) {
                //       if (markers1 == null) {
                //         return Center(child: SpinKitPulse());
                //       }
                //       return GoogleMap(
                //         buildingsEnabled: true,
                //         compassEnabled: true,
                //         myLocationButtonEnabled: true,
                //         myLocationEnabled: true,
                //         markers: markers1,
                //         mapType: MapType.normal,
                //         zoomControlsEnabled: false,
                //         initialCameraPosition: camPosition,
                //         onMapCreated: (GoogleMapController controller) {
                //           _controller.complete(controller);
                //           setState(() {
                //             myLocationMarker(lat, long);
                //             mapController = controller;
                //           });
                //         },
                //       );
                //     }),

                Builder(builder: (context) {
                  Geolocator.getCurrentPosition().then((position) {
                    FirebaseFirestore.instance
                        .collection('Drivers')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'location': {
                        'lat': position.latitude,
                        'long': position.longitude
                      },
                    });
                  }).catchError((error) {
                    print('Error getting location: $error');
                  });
                  return FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      center: LatLng(lat, long),
                      zoom: 18.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.phara_driver',
                      ),
                      MarkerLayer(
                        markers: myMarkers,
                      ),
                      CircleLayer(
                        circles: myCircles,
                      ),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Bookings')
                            .where('driverId',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.uid)
                            .where('status', isEqualTo: 'Pending')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            print('error');
                            return const Center(child: Text('Error'));
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }

                          final data = snapshot.requireData;
                          return data.docs.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    if (data.docs.isNotEmpty) {
                                      showBookingData(data);
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: data.docs.isNotEmpty
                                          ? Colors.amber
                                          : grey.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    height: 40,
                                    width: 200,
                                    child: Center(
                                      child: TextRegular(
                                          text: data.docs.length > 1
                                              ? '${data.docs.length} bookings'
                                              : '${data.docs.length} booking',
                                          fontSize: 18,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        }),
                  ),
                ),
              ],
            ),
          )
        : const Scaffold(
            body: Center(
              child: SpinKitChasingDots(
                color: grey,
              ),
            ),
          );
  }

  // myLocationMarker(double lat, double lang) async {
  //   Marker mylocationMarker = Marker(
  //       markerId: const MarkerId('currentLocation'),
  //       infoWindow: const InfoWindow(
  //         title: 'Your Current Location',
  //       ),
  //       icon: BitmapDescriptor.defaultMarker,
  //       position: LatLng(lat, lang));

  //   markers.add(mylocationMarker);
  // }

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
    });

    myCircles.clear();
    myCircles.add(
      CircleMarker(
          point: LatLng(position.latitude, position.longitude),
          radius: 5,
          borderStrokeWidth: 1,
          borderColor: Colors.black,
          useRadiusInMeter: true,
          color: Colors.blue),
    );

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

  showBookingData(dynamic data) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.grey[100],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextBold(
                          text: 'Bookings', fontSize: 18, color: Colors.amber),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 5, bottom: 5, left: 10, right: 10),
                        child: Card(
                          child: ListTile(
                            onTap: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 130,
                                      child: Column(
                                        children: [
                                          ListTile(
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              if (data.docs[index]['status'] ==
                                                  'Rejected') {
                                                showToast(
                                                    'The booking of this user was rejected! Cannot procceed');
                                              } else {
                                                mapController.move(
                                                    LatLng(
                                                        data.docs[index][
                                                                'originCoordinates']
                                                            ['lat'],
                                                        data.docs[index][
                                                                'originCoordinates']
                                                            ['long']),
                                                    18);
                                                myMarkers.add(Marker(
                                                  point: LatLng(
                                                      data.docs[index][
                                                              'originCoordinates']
                                                          ['lat'],
                                                      data.docs[index][
                                                              'originCoordinates']
                                                          ['long']),
                                                  builder: (context) =>
                                                      const Icon(
                                                    Icons
                                                        .location_history_rounded,
                                                    size: 42,
                                                  ),
                                                ));
                                                showDialog(
                                                    context: context,
                                                    builder: (context1) {
                                                      return AlertDialog(
                                                        content: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  CircleAvatar(
                                                                    minRadius:
                                                                        25,
                                                                    maxRadius:
                                                                        25,
                                                                    backgroundImage:
                                                                        NetworkImage(data.docs[index]
                                                                            [
                                                                            'userProfile']),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 15,
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      TextBold(
                                                                          text:
                                                                              'Name: ${data.docs[index]['userName']}',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child: TextRegular(
                                                                            text:
                                                                                'Destination: ${data.docs[index]['destination']}',
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                grey),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            150,
                                                                        child: TextRegular(
                                                                            text:
                                                                                'Origin: ${data.docs[index]['origin']}',
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                grey),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      TextBold(
                                                                          text:
                                                                              'Fare: ₱${NumberFormat('#,##0.00', 'en_US').format(double.parse(data.docs[index]['fare']))}',
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.green),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ]),
                                                        actions: [
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.pop(
                                                                  context1);
                                                              setState(() {
                                                                myMarkers
                                                                    .clear();
                                                              });
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Bookings')
                                                                  .doc(data
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .update({
                                                                'status':
                                                                    'Rejected'
                                                              });
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(data.docs[
                                                                          index]
                                                                      [
                                                                      'userId'])
                                                                  .update({
                                                                'notif': FieldValue
                                                                    .arrayUnion([
                                                                  {
                                                                    'notif':
                                                                        'Youre booking was rejected!',
                                                                    'read':
                                                                        false,
                                                                    'date':
                                                                        DateTime
                                                                            .now(),
                                                                  }
                                                                ]),
                                                              });

                                                              mapController.move(
                                                                  LatLng(
                                                                      data.docs[index]
                                                                              [
                                                                              'originCoordinates']
                                                                          [
                                                                          'lat'],
                                                                      data.docs[index]
                                                                              [
                                                                              'originCoordinates']
                                                                          [
                                                                          'long']),
                                                                  18);
                                                            },
                                                            child: TextRegular(
                                                                text:
                                                                    'Reject Booking',
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          ButtonWidget(
                                                              opacity: 1,
                                                              color:
                                                                  Colors.green,
                                                              radius: 5,
                                                              fontSize: 14,
                                                              width: 100,
                                                              height: 30,
                                                              label:
                                                                  'Accept Booking',
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context1)
                                                                    .pushReplacement(MaterialPageRoute(
                                                                        builder:
                                                                            (context1) =>
                                                                                TrackingOfUserPage(tripDetails: data.docs[index])));
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Drivers')
                                                                    .doc(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  'isActive':
                                                                      false
                                                                });

                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Bookings')
                                                                    .doc(data
                                                                        .docs[
                                                                            index]
                                                                        .id)
                                                                    .update({
                                                                  'status':
                                                                      'Accepted'
                                                                });

                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(data.docs[
                                                                            index]
                                                                        [
                                                                        'userId'])
                                                                    .update({
                                                                  'notif':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    {
                                                                      'notif':
                                                                          'Youre booking was accepted! Driver on the way',
                                                                      'read':
                                                                          false,
                                                                      'date': DateTime
                                                                          .now(),
                                                                    }
                                                                  ]),
                                                                });
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Drivers')
                                                                    .doc(data.docs[
                                                                            index]
                                                                        [
                                                                        'driverId'])
                                                                    .update({
                                                                  'history':
                                                                      FieldValue
                                                                          .arrayUnion([
                                                                    {
                                                                      'date': DateTime
                                                                          .now(),
                                                                      'destination':
                                                                          data.docs[index]
                                                                              [
                                                                              'destination'],
                                                                      'distance':
                                                                          data.docs[index]
                                                                              [
                                                                              'distance'],
                                                                      'fare': data
                                                                              .docs[index]
                                                                          [
                                                                          'fare'],
                                                                      'origin':
                                                                          data.docs[index]
                                                                              [
                                                                              'origin'],
                                                                    }
                                                                  ]),
                                                                });

                                                                // To Do: Booking - to show booking modal sheet
                                                              })
                                                        ],
                                                      );
                                                    });
                                              }
                                            },
                                            leading: TextRegular(
                                                text: 'View on map',
                                                fontSize: 14,
                                                color: Colors.green),
                                            trailing: const Icon(
                                              Icons.remove_red_eye,
                                              color: Colors.green,
                                            ),
                                          ),
                                          const Divider(),
                                          ListTile(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                          'Decline confirmation',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'QBold',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to Decline this booking?',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'QRegular'),
                                                        ),
                                                        actions: <Widget>[
                                                          MaterialButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(true),
                                                            child: const Text(
                                                              'Close',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'QRegular',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          MaterialButton(
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Bookings')
                                                                  .doc(data
                                                                      .docs[
                                                                          index]
                                                                      .id)
                                                                  .update({
                                                                'status':
                                                                    'Rejected'
                                                              });
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(data.docs[
                                                                          index]
                                                                      [
                                                                      'userId'])
                                                                  .update({
                                                                'notif': FieldValue
                                                                    .arrayUnion([
                                                                  {
                                                                    'notif':
                                                                        'Youre booking was rejected!',
                                                                    'read':
                                                                        false,
                                                                    'date':
                                                                        DateTime
                                                                            .now(),
                                                                  }
                                                                ]),
                                                              });
                                                            },
                                                            child: const Text(
                                                              'Continue',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'QRegular',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ],
                                                      ));
                                            },
                                            leading: TextRegular(
                                                text: 'Reject Booking',
                                                fontSize: 14,
                                                color: Colors.red),
                                            trailing: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            leading: CircleAvatar(
                              minRadius: 15,
                              maxRadius: 15,
                              backgroundImage:
                                  NetworkImage(data.docs[index]['userProfile']),
                            ),
                            title: TextBold(
                                text: 'To: ${data.docs[index]['destination']}',
                                fontSize: 12,
                                color: Colors.black),
                            subtitle: TextRegular(
                                text: 'From: ${data.docs[index]['origin']}',
                                fontSize: 11,
                                color: Colors.grey),
                            trailing: TextRegular(
                                text: DateFormat.jm().format(
                                    data.docs[index]['dateTime'].toDate()),
                                fontSize: 12,
                                color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'isActive': false,
      });
    }

    if (state == AppLifecycleState.inactive) {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'isActive': false,
      });
    }

    if (state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'isActive': false,
      });
    }

    if (state == AppLifecycleState.resumed) {
      FirebaseFirestore.instance
          .collection('Drivers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'isActive': true,
      });
    }

    /* if (isBackground) {
      // service.stop();
    } else {
      // service.start();
    }*/
  }

  getDrivers() {
    FirebaseFirestore.instance
        .collection('Drivers')
        .get()
        .then((QuerySnapshot querySnapshot) async {
      for (var doc in querySnapshot.docs) {
        setState(() {
          myMarkers.add(Marker(
            point: LatLng(doc['location']['lat'], doc['location']['long']),
            builder: (context) => const Icon(
              Icons.location_history_rounded,
              size: 42,
            ),
          ));
        });
      }
    });

    setState(() {
      hasLoaded = true;
    });
  }

  @override
  void dispose() {
    // mapController!.dispose();
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
