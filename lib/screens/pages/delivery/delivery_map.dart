import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phara_driver/screens/pages/chat_page.dart';

import '../../../utils/colors.dart';
import '../../../utils/keys.dart';
import '../../../widgets/button_widget.dart';
import '../../../widgets/text_widget.dart';

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
          print('ypw');
          addPoly(
              LatLng(value.latitude, value.longitude),
              LatLng(widget.bookingData['originCoordinates']['lat'],
                  widget.bookingData['originCoordinates']['long']));
        } else {
          print('hey');
          addPoly(
              LatLng(value.latitude, value.longitude),
              LatLng(widget.bookingData['destinationCoordinates']['lat'],
                  widget.bookingData['destinationCoordinates']['long']));
        }
      });
    });
  }

  bool bookingAccepted = false;
  bool bookingAccepted1 = false;
  bool bookingAccepted2 = false;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double lat = 0;
  double long = 0;
  bool hasLoaded = false;

  Set<Marker> markers = {};

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
      _poly = Polyline(
          color: Colors.red,
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          width: 4);
    });
    mapController!
        .animateCamera(CameraUpdate.newLatLngZoom(coordinates1, 18.0));
  }

  GoogleMapController? mapController;

  addMyMarker1(lat1, long1) async {
    markers.add(Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId("pickup"),
        position: LatLng(lat1, long1),
        infoWindow: InfoWindow(
            title: 'Pick-up Location',
            snippet: 'PU: ${widget.bookingData['origin']}')));
  }

  addMyMarker12(lat1, long1) async {
    markers.add(Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId("dropOff"),
        position: LatLng(lat1, long1),
        infoWindow: InfoWindow(
            title: 'Drop-off Location',
            snippet: 'DO: ${widget.bookingData['destination']}')));

    setState(() {
      hasLoaded = true;
    });
  }

  late Polyline _poly = const Polyline(polylineId: PolylineId('new'));

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  Widget build(BuildContext context) {
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
    );
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
                GoogleMap(
                  polylines: {_poly},
                  markers: markers,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  buildingsEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  initialCameraPosition: kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    addPoly(
                        LatLng(lat, long),
                        LatLng(widget.bookingData['originCoordinates']['lat'],
                            widget.bookingData['originCoordinates']['long']));
                    mapController = controller;
                    _controller.complete(controller);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: DraggableScrollableSheet(
                      initialChildSize: 0.34,
                      minChildSize: 0.15,
                      maxChildSize: 0.34,
                      builder: (context, scrollController) {
                        return Card(
                          elevation: 3,
                          child: Container(
                            width: double.infinity,
                            height: 220,
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
                                            'Distance: ${widget.bookingData['distance']}km away',
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
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: const Text(
                                                              'Pick-up Item Confirmation',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'QBold',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            content: const Text(
                                                              'Item picked up?',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'QRegular'),
                                                            ),
                                                            actions: <Widget>[
                                                              MaterialButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(
                                                                            true),
                                                                child:
                                                                    const Text(
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
                                                                    bookingAccepted =
                                                                        true;
                                                                    bookingAccepted2 =
                                                                        true;
                                                                  });
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child:
                                                                    const Text(
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
    mapController!.dispose();
    super.dispose();
  }
}