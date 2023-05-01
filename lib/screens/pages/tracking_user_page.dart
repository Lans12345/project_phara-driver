import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:phara_driver/screens/home_screen.dart';
import 'package:phara_driver/widgets/button_widget.dart';

import '../../plugins/my_location.dart';
import '../../utils/colors.dart';
import '../../widgets/text_widget.dart';
import 'chat_page.dart';

class TrackingOfUserPage extends StatefulWidget {
  final tripDetails;

  const TrackingOfUserPage({super.key, required this.tripDetails});

  @override
  State<TrackingOfUserPage> createState() => _TrackingOfUserPageState();
}

class _TrackingOfUserPageState extends State<TrackingOfUserPage> {
  late StreamSubscription<loc.LocationData> subscription;

  @override
  void initState() {
    super.initState();
    determinePosition();
    getLocation();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      getDrivers();
    });
  }

  var hasLoaded = false;

  bool passengerOnBoard = false;

  GoogleMapController? mapController;

  Set<Marker> markers = {};

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late double lat = 0;
  late double long = 0;

  @override
  Widget build(BuildContext context) {
    final CameraPosition camPosition = CameraPosition(
        target: LatLng(lat, long), zoom: 16, bearing: 45, tilt: 40);
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 75),
        child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: (() {
              mapController?.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      bearing: 45,
                      tilt: 40,
                      target: LatLng(lat, long),
                      zoom: 16)));
            }),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.red,
            )),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Are you sure?'),
                content: const Text('Do you want to close this ride?'),
                actions: <Widget>[
                  MaterialButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: TextRegular(text: 'No', fontSize: 12, color: grey),
                  ),
                  MaterialButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const HomeScreen())),
                    child: TextBold(
                        text: 'Yes', fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.exit_to_app),
        ),
        foregroundColor: grey,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const CircleAvatar(
              minRadius: 17.5,
              maxRadius: 17.5,
              backgroundImage: AssetImage('assets/images/profile.png'),
            ),
            const SizedBox(
              width: 20,
            ),
            TextRegular(text: 'Lance Olana', fontSize: 20, color: grey),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ChatPage(
                        userId: widget.tripDetails['userId'],
                        userName: widget.tripDetails['userName'],
                      )));
            },
            icon: const Icon(
              Icons.message_outlined,
              color: grey,
            ),
          ),
        ],
      ),
      body: hasLoaded
          ? Stack(
              children: [
                GoogleMap(
                  polylines: {_poly},
                  zoomControlsEnabled: false,
                  buildingsEnabled: true,
                  compassEnabled: true,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  markers: markers,
                  mapType: MapType.normal,
                  initialCameraPosition: camPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    setState(() {
                      mapController = controller;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      height: 50,
                      width: 200,
                      child: Center(
                        child: TextRegular(
                            text: 'Passenger is waiting',
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: !passengerOnBoard,
                      child: ButtonWidget(
                          radius: 100,
                          color: Colors.green,
                          opacity: 1,
                          label: 'Confirm Pickup',
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Passenger onboard?',
                                        style: TextStyle(
                                            fontFamily: 'QBold',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      actions: <Widget>[
                                        MaterialButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text(
                                            'Close',
                                            style: TextStyle(
                                                fontFamily: 'QRegular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                            setState(() {
                                              passengerOnBoard = true;

                                              markers.clear();
                                            });

                                            Timer.periodic(
                                                const Duration(seconds: 2),
                                                (timer) {
                                              Geolocator.getCurrentPosition()
                                                  .then((position) {
                                                onboard(position);
                                              }).catchError((error) {
                                                print(
                                                    'Error getting location: $error');
                                              });
                                            });
                                          },
                                          child: const Text(
                                            'Continue',
                                            style: TextStyle(
                                                fontFamily: 'QRegular',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ));
                          }),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
  }

  late Polyline _poly;

  getDrivers() async {
    if (passengerOnBoard == false) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      FirebaseFirestore.instance
          .collection('Users')
          .where('id', isEqualTo: widget.tripDetails['userId'])
          .get()
          .then((QuerySnapshot querySnapshot) async {
        for (var doc in querySnapshot.docs) {
          Marker driverMarker = Marker(
              markerId: MarkerId(doc['name']),
              infoWindow: InfoWindow(
                title: doc['name'],
                snippet: doc['number'],
              ),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(widget.tripDetails['originCoordinates']['lat'],
                  widget.tripDetails['originCoordinates']['long']));

          setState(() {
            _poly = Polyline(
                color: Colors.red,
                polylineId: const PolylineId('route'),
                points: [
                  // User Location
                  LatLng(position.latitude, position.longitude),
                  LatLng(widget.tripDetails['originCoordinates']['lat'],
                      widget.tripDetails['originCoordinates']['long']),
                ],
                width: 4);
            markers.add(driverMarker);
            hasLoaded = true;
          });
        }

        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                bearing: 45,
                tilt: 40,
                target: LatLng(position.latitude, position.longitude),
                zoom: 16)));
      });
    }
  }

  onboard(position) async {
    Marker driverMarker = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: InfoWindow(
          title: widget.tripDetails['destination'],
          snippet: 'Your destination',
        ),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(widget.tripDetails['destinationCoordinates']['lat'],
            widget.tripDetails['destinationCoordinates']['long']));

    setState(() {
      _poly = Polyline(
          color: Colors.blue,
          polylineId: const PolylineId('route'),
          points: [
            // User Location
            LatLng(position.latitude, position.longitude),
            LatLng(widget.tripDetails['destinationCoordinates']['lat'],
                widget.tripDetails['destinationCoordinates']['long']),
          ],
          width: 4);
      markers.add(driverMarker);
    });
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        bearing: 45,
        tilt: 40,
        target: LatLng(position.latitude, position.longitude),
        zoom: 16)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    mapController!.dispose();
  }
}
