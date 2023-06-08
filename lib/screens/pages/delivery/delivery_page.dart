import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phara_driver/screens/pages/delivery/delivery_history_page.dart';
import 'package:phara_driver/screens/pages/delivery/delivery_map.dart';
import 'package:phara_driver/widgets/drawer_widget.dart';

import '../../../utils/colors.dart';
import '../../../widgets/text_widget.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: grey,
        backgroundColor: Colors.white,
        title: TextRegular(text: 'Delivery', fontSize: 24, color: grey),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const DeliveryHistoryPage()));
            },
            icon: const Icon(
              Icons.history,
              color: grey,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Delivery')
              .where('driverId',
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid)
              .where('status', isEqualTo: 'Pending')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              print('error');
              return const Center(child: Text('Error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox();
            }

            final data = snapshot.requireData;
            return ListView.builder(
              itemCount: data.docs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DeliveryMap(
                                  bookingData: data.docs[index],
                                )));
                      },
                      leading: CircleAvatar(
                        minRadius: 18,
                        maxRadius: 18,
                        backgroundImage:
                            NetworkImage(data.docs[index]['userProfile']),
                      ),
                      title: TextBold(
                          text: 'To: ${data.docs[index]['destination']}',
                          fontSize: 15,
                          color: Colors.black),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextRegular(
                              text: 'From: ${data.docs[index]['origin']}',
                              fontSize: 15,
                              color: Colors.grey),
                          TextRegular(
                              text: 'Payment: ₱${data.docs[index]['fare']}',
                              fontSize: 15,
                              color: Colors.grey),
                          TextRegular(
                              text: DateFormat.yMMMd().add_jm().format(
                                  data.docs[index]['dateTime'].toDate()),
                              fontSize: 15,
                              color: Colors.grey),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 65,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => DeliveryMap(
                                          bookingData: data.docs[index],
                                        )));
                              },
                              child: const Icon(
                                Icons.remove_red_eye_outlined,
                                color: grey,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Declined Confirmation',
                                            style: TextStyle(
                                                fontFamily: 'QBold',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          content: const Text(
                                            'Are you sure you want to decline this booking?',
                                            style: TextStyle(
                                                fontFamily: 'QRegular'),
                                          ),
                                          actions: <Widget>[
                                            MaterialButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            MaterialButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                await FirebaseFirestore.instance
                                                    .collection('Delivery')
                                                    .doc(data.docs[index].id)
                                                    .update(
                                                        {'status': 'Rejected'});
                                              },
                                              child: const Text(
                                                'Continue',
                                                style: TextStyle(
                                                    fontFamily: 'QRegular',
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ));
                              },
                              child: const Icon(
                                Icons.delete_outline_outlined,
                                color: grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
