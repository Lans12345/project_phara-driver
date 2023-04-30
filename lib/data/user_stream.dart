import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseData {
  final Stream<DocumentSnapshot> userData = FirebaseFirestore.instance
      .collection('Drivers')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .snapshots();
}
