import 'dart:async';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:phara_driver/screens/home_screen.dart';
import 'package:phara_driver/widgets/button_widget.dart';

import '../../plugins/my_location.dart';
import '../../utils/colors.dart';
import '../../utils/keys.dart';
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

  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = kGoogleApiKey;

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
            CircleAvatar(
              minRadius: 17.5,
              maxRadius: 17.5,
              backgroundImage: NetworkImage(widget.tripDetails['userProfile']),
            ),
            const SizedBox(
              width: 20,
            ),
            TextRegular(
                text: widget.tripDetails['userName'],
                fontSize: 20,
                color: grey),
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
                      width: passengerOnBoard ? 250 : 200,
                      child: Center(
                        child: passengerOnBoard
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: TextRegular(
                                    text: passengerOnBoard
                                        ? 'To: ${widget.tripDetails['destination']}'
                                        : 'Passenger is waiting',
                                    fontSize: passengerOnBoard ? 12 : 18,
                                    color: Colors.white),
                              )
                            : TextRegular(
                                text: passengerOnBoard
                                    ? 'To: ${widget.tripDetails['destination']}'
                                    : 'Passenger is waiting',
                                fontSize: passengerOnBoard ? 12 : 18,
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

  String userProfile = '';

  getDrivers() async {
    Geolocator.getCurrentPosition().then((position) {
      onboard(position);
    }).catchError((error) {
      print('Error getting location: $error');
    });

    setState(() {
      hasLoaded = true;
    });
  }

  onboard(position) async {
    Marker driverMarker = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: InfoWindow(
          title: passengerOnBoard
              ? widget.tripDetails['destination']
              : widget.tripDetails['origin'],
          snippet: 'Your destination',
        ),
        icon: BitmapDescriptor.defaultMarker,
        position: passengerOnBoard == false
            ? LatLng(widget.tripDetails['originCoordinates']['lat'],
                widget.tripDetails['originCoordinates']['long'])
            : LatLng(widget.tripDetails['destinationCoordinates']['lat'],
                widget.tripDetails['destinationCoordinates']['long']));

    Geolocator.getCurrentPosition().then(
      (value) async {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            googleAPIKey,
            PointLatLng(value.latitude, value.longitude),
            passengerOnBoard == false
                ? PointLatLng(widget.tripDetails['originCoordinates']['lat'],
                    widget.tripDetails['originCoordinates']['long'])
                : PointLatLng(
                    widget.tripDetails['destinationCoordinates']['lat'],
                    widget.tripDetails['destinationCoordinates']['long']));
        if (result.points.isNotEmpty) {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
        setState(() {
          _poly = Polyline(
              color: passengerOnBoard == false ? Colors.red : Colors.blue,
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              width: 4);
          markers.add(driverMarker);
        });
        mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                bearing: 45,
                tilt: 40,
                target: LatLng(position.latitude, position.longitude),
                zoom: 18)));
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    mapController!.dispose();
  }
}
