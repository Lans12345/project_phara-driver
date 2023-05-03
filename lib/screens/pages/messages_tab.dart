import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import '../../utils/colors.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/drawer_widget.dart';
import '../../widgets/text_widget.dart';
import 'chat_page.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  final messageController = TextEditingController();

  String filter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerWidget(),
      appBar: AppbarWidget('Messages'),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Messages')
                  .where('driverId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
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
                return Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                        itemCount: data.docs.length,
                        itemBuilder: ((context, index) {
                          return Padding(
                              padding: const EdgeInsets.all(5),
                              child: ListTile(
                                onTap: () async {
                                  await FirebaseFirestore.instance
                                      .collection('Messages')
                                      .doc(data.docs[index].id)
                                      .update({'seen': true});
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                            userId: data.docs[index]['userId'],
                                            userName: data.docs[index]
                                                    ['userName'] ??
                                                'User name',
                                          )));
                                },
                                leading: CircleAvatar(
                                  maxRadius: 25,
                                  minRadius: 25,
                                  backgroundImage: NetworkImage(
                                      data.docs[index]['userProfile']),
                                ),
                                title: data.docs[index]['seen'] == true
                                    ? TextRegular(
                                        text: data.docs[index]['userName'] ??
                                            'User name',
                                        fontSize: 15,
                                        color: grey)
                                    : TextBold(
                                        text: data.docs[index]['userName'] ??
                                            'User name',
                                        fontSize: 15,
                                        color: Colors.black),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    data.docs[index]['seen'] == true
                                        ? Text(
                                            data.docs[index]['lastMessage'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: grey,
                                                fontFamily: 'QRegular'),
                                          )
                                        : Text(
                                            data.docs[index]['lastMessage'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                                color: Colors.black,
                                                fontFamily: 'QBold'),
                                          ),
                                    data.docs[index]['seen'] == true
                                        ? TextRegular(
                                            text: DateFormat.jm().format(data
                                                .docs[index]['dateTime']
                                                .toDate()),
                                            fontSize: 12,
                                            color: grey)
                                        : TextBold(
                                            text: DateFormat.jm().format(data
                                                .docs[index]['dateTime']
                                                .toDate()),
                                            fontSize: 12,
                                            color: Colors.black),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_right,
                                  color: grey,
                                ),
                              ));
                        })),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
