import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future signup(name, number, address, email, vehicle, plateNumber) async {
  final docUser = FirebaseFirestore.instance
      .collection('Drivers')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'name': name,
    'number': number,
    'address': address,
    'email': email,
    'id': docUser.id,
    'stars': 0,
    'ratings': [],
    'history': [],
    'bookmarks': [],
    'location': {'lat': 0.00, 'long': 0.00},
    'isActive': true,
    'notif': [],
    'profilePicture': 'https://cdn-icons-png.flaticon.com/256/149/149071.png',
    'vehicle': vehicle,
    'deliveryHistory': [],
    'plateNumber': plateNumber,
    'feedbacks': [],
    'type': 'motorcycle',
    'comments': [],
  };

  await docUser.set(json);
}
