import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:phara_driver/screens/pages/chat_page.dart';

import '../../../utils/colors.dart';
import '../../../utils/keys.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/text_widget.dart';
import 'delivery_history_page.dart';

class DeliveryMap extends StatefulWidget {
  final bookingData;

  const DeliveryMap({super.key, required this.bookingData});

  @override
  State<DeliveryMap> createState() => DeliveryMapState();
}

class DeliveryMapState extends State<DeliveryMap> {
  @override
  void initState() {
    super.initState();

    addMyMarker1(widget.bookingData['originCoordinates']['lat'],
        widget.bookingData['originCoordinates']['long']);
    addMyMarker12(widget.bookingData['destinationCoordinates']['lat'],
        widget.bookingData['destinationCoordinates']['long']);

    Geolocator.getCurrentPosition().then((value) {
      setState(() {
        lat = value.latitude;
        long = value.longitude;
      });
    });

    Timer.periodic(const Duration(seconds: 5), (timer) {
      Geolocator.getCurrentPosition().then((value) {
        setState(() {
          lat = value.latitude;
          long = value.longitude;
        });

        if (bookingAccepted == false) {
          addPoly(
              LatLng(value.latitude, value.longitude),
              LatLng(widget.bookingData['originCoordinates']['lat'],
                  widget.bookingData['originCoordinates']['long']));
        } else {
          addPoly(
              LatLng(value.latitude, value.longitude),
              LatLng(widget.bookingData['destinationCoordinates']['lat'],
                  widget.bookingData['destinationCoordinates']['long']));
        }

        myCircles.add(
          CircleMarker(
              point: LatLng(value.latitude, value.longitude),
              radius: 5,
              borderStrokeWidth: 1,
              borderColor: Colors.black,
              useRadiusInMeter: true,
              color: Colors.red),
        );
      });
    });
  }

  bool bookingAccepted = false;
  bool bookingAccepted1 = false;
  bool bookingAccepted2 = false;
  bool delivered = false;

  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  double lat = 0;
  double long = 0;
  bool hasLoaded = false;

  // Set<Marker> markers = {};

  addPoly(LatLng coordinates1, LatLng coordinates2) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(coordinates1.latitude, coordinates1.longitude),
        PointLatLng(coordinates2.latitude, coordinates2.longitude));
    if (result.points.isNotEmpty) {
      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    }
    setState(() {
      myPoly = Polyline(
        strokeWidth: 5,
        isDotted: true,
        useStrokeWidthInMeter: true,
        points: polylineCoordinates,
        color: Colors.red,
      );
    });
    // mapController.animateCamera(CameraUpdate.newLatLngZoom(coordinates1, 18.0));

    mapController.move(coordinates1, 18);
  }

  // GoogleMapController? mapController;

  addMyMarker1(lat1, long1) async {
    // markers.add(Marker(
    //     icon: BitmapDescriptor.defaultMarker,
    //     markerId: const MarkerId("pickup"),
    //     position: LatLng(lat1, long1),
    //     infoWindow: InfoWindow(
    //         title: 'Pick-up Location',
    //         snippet: 'PU: ${widget.bookingData['origin']}')));

    myMarkers.add(Marker(
      point: LatLng(lat1, long1),
      builder: (context) => const Icon(
        Icons.location_on_rounded,
        color: Colors.red,
        size: 42,
      ),
    ));
  }

  addMyMarker12(lat1, long1) async {
    // markers.add(Marker(
    //     icon: BitmapDescriptor.defaultMarker,
    //     markerId: const MarkerId("dropOff"),
    //     position: LatLng(lat1, long1),
    //     infoWindow: InfoWindow(
    //         title: 'Drop-off Location',
    //         snippet: 'DO: ${widget.bookingData['destination']}')));

    myMarkers.add(Marker(
      point: LatLng(lat1, long1),
      builder: (context) => const Icon(
        Icons.location_on_rounded,
        color: Colors.red,
        size: 42,
      ),
    ));

    setState(() {
      hasLoaded = true;
    });
  }

  // late Polyline _poly = const Polyline(polylineId: PolylineId('new'));

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final mapController = MapController();

  List<Marker> myMarkers = [];

  late List<CircleMarker> myCircles = [];

  late Polyline myPoly;

  @override
  Widget build(BuildContext context) {
    // CameraPosition kGooglePlex = CameraPosition(
    //   target: LatLng(lat, long),
    //   zoom: 18,
    // );
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: grey,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              minRadius: 22,
              maxRadius: 22,
              backgroundImage: NetworkImage(widget.bookingData['userProfile']),
            ),
            const SizedBox(
              width: 10,
            ),
            TextRegular(
                text: widget.bookingData['userName'],
                fontSize: 18,
                color: grey),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ChatPage(
                      userId: widget.bookingData['userId'],
                      userName: widget.bookingData['userName'])));
            },
            icon: const Icon(
              Icons.message_outlined,
            ),
          ),
        ],
      ),
      body: hasLoaded && lat != 0
          ? Stack(
              children: [
                // GoogleMap(
                //   polylines: {_poly},
                //   markers: markers,
                //   mapToolbarEnabled: false,
                //   zoomControlsEnabled: false,
                //   buildingsEnabled: true,
                //   compassEnabled: true,
                //   myLocationButtonEnabled: true,
                //   myLocationEnabled: true,
                //   mapType: MapType.normal,
                //   initialCameraPosition: kGooglePlex,
                //   onMapCreated: (GoogleMapController controller) {
                //     addPoly(
                //         LatLng(lat, long),
                //         LatLng(widget.bookingData['originCoordinates']['lat'],
                //             widget.bookingData['originCoordinates']['long']));
                //     mapController = controller;
                //     _controller.complete(controller);
                //   },
                // ),
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
                      myPoly != null
                          ? PolylineLayer(
                              polylines: [myPoly],
                            )
                          : const SizedBox()
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: DraggableScrollableSheet(
                      initialChildSize: 0.5,
                      minChildSize: 0.15,
                      maxChildSize: 0.5,
                      builder: (context, scrollController) {
                        return Card(
                          elevation: 3,
                          child: Container(
                            width: double.infinity,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TextBold(
                                        text:
                                            'Distance: ${widget.bookingData['distance']} km away',
                                        fontSize: 18,
                                        color: grey),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 35,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons
                                                .shopping_cart_checkout_outlined,
                                            color: grey,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          label: TextRegular(
                                              text:
                                                  'Item: ${widget.bookingData['item']}',
                                              fontSize: 14,
                                              color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 35,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons.account_circle_outlined,
                                            color: grey,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          label: TextRegular(
                                              text:
                                                  'Receiver: ${widget.bookingData['receiver']}',
                                              fontSize: 14,
                                              color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 35,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons.phone,
                                            color: grey,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          label: TextRegular(
                                              text:
                                                  'Contact No.: ${widget.bookingData['receiverNumber']}',
                                              fontSize: 14,
                                              color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      height: 35,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons.looks_one_outlined,
                                            color: grey,
                                          ),
                                          suffixIcon: const Icon(
                                            Icons.my_location_outlined,
                                            color: Colors.red,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          label: TextRegular(
                                              text:
                                                  'PU: ${widget.bookingData['origin']}',
                                              fontSize: 14,
                                              color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      height: 35,
                                      width: 300,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: TextFormField(
                                        enabled: false,
                                        decoration: InputDecoration(
                                          prefixIcon: const Icon(
                                            Icons.looks_two_outlined,
                                            color: grey,
                                          ),
                                          suffixIcon: const Icon(
                                            Icons.sports_score_outlined,
                                            color: Colors.red,
                                          ),
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: grey),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                width: 1, color: Colors.black),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          label: TextRegular(
                                              text:
                                                  'DO: ${widget.bookingData['destination']}',
                                              fontSize: 14,
                                              color: Colors.black),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    bookingAccepted1 == false
                                        ? ButtonWidget(
                                            width: 250,
                                            fontSize: 15,
                                            color: Colors.green,
                                            height: 40,
                                            radius: 100,
                                            opacity: 1,
                                            label: 'Accept Booking',
                                            onPressed: () async {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                          'Booking Confirmation',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'QBold',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: const Text(
                                                          'Are you sure you want to accept this booking?',
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
                                                              setState(() {
                                                                bookingAccepted1 =
                                                                    true;
                                                              });
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Delivery')
                                                                  .doc(widget
                                                                      .bookingData
                                                                      .id)
                                                                  .update({
                                                                'status':
                                                                    'Accepted'
                                                              });

                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Users')
                                                                  .doc(widget
                                                                          .bookingData[
                                                                      'userId'])
                                                                  .update({
                                                                'notif': FieldValue
                                                                    .arrayUnion([
                                                                  {
                                                                    'notif':
                                                                        'Youre delivery booking was accepted! Driver on the way',
                                                                    'read':
                                                                        false,
                                                                    'date':
                                                                        DateTime
                                                                            .now(),
                                                                  }
                                                                ]),
                                                              });

                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Drivers')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .update({
                                                                'isActive':
                                                                    false,
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
                                          )
                                        : bookingAccepted2 == false
                                            ? ButtonWidget(
                                                width: 250,
                                                fontSize: 15,
                                                color: Colors.red,
                                                height: 40,
                                                radius: 100,
                                                opacity: 1,
                                                label: 'To Drop-off Location',
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder:
                                                          (context) =>
                                                              AlertDialog(
                                                                title:
                                                                    const Text(
                                                                  'Pick-up Item Confirmation',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'QBold',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                content:
                                                                    const Text(
                                                                  'Item picked up?',
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'QRegular'),
                                                                ),
                                                                actions: <
                                                                    Widget>[
                                                                  MaterialButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(true),
                                                                    child:
                                                                        const Text(
                                                                      'Close',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'QRegular',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  MaterialButton(
                                                                    onPressed:
                                                                        () async {
                                                                      setState(
                                                                          () {
                                                                        bookingAccepted =
                                                                            true;
                                                                        bookingAccepted2 =
                                                                            true;
                                                                      });

                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();

                                                                      await FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'Drivers')
                                                                          .doc(FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid)
                                                                          .update({
                                                                        'deliveryHistory':
                                                                            FieldValue.arrayUnion([
                                                                          {
                                                                            'origin':
                                                                                widget.bookingData['origin'],
                                                                            'destination':
                                                                                widget.bookingData['destination'],
                                                                            'distance':
                                                                                widget.bookingData['distance'],
                                                                            'payment':
                                                                                widget.bookingData['fare'],
                                                                            'date':
                                                                                DateTime.now(),
                                                                          }
                                                                        ]),
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Continue',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'QRegular',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ));
                                                },
                                              )
                                            : delivered == false
                                                ? ButtonWidget(
                                                    width: 250,
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    height: 40,
                                                    radius: 100,
                                                    opacity: 1,
                                                    label: 'Confirm Delivery',
                                                    onPressed: () async {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    title:
                                                                        const Text(
                                                                      'Delivery Confirmation',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'QBold',
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    content:
                                                                        const Text(
                                                                      'Item delivered?',
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              'QRegular'),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      MaterialButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.of(context).pop(true),
                                                                        child:
                                                                            const Text(
                                                                          'Close',
                                                                          style: TextStyle(
                                                                              fontFamily: 'QRegular',
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      MaterialButton(
                                                                        onPressed:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            delivered =
                                                                                true;
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                          Navigator.of(context)
                                                                              .push(MaterialPageRoute(builder: (context) => const DeliveryHistoryPage()));

                                                                          await FirebaseFirestore
                                                                              .instance
                                                                              .collection('Drivers')
                                                                              .doc(FirebaseAuth.instance.currentUser!.uid)
                                                                              .update({
                                                                            'isActive':
                                                                                true,
                                                                          });
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Continue',
                                                                          style: TextStyle(
                                                                              fontFamily: 'QRegular',
                                                                              fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ));
                                                    },
                                                  )
                                                : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            )
          : const Center(
              child: SpinKitPulse(
                color: grey,
              ),
            ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
