// import 'package:flutter/material.dart';
// import 'package:phara_driver/widgets/text_widget.dart';
// import 'package:phara_driver/widgets/trackbooking_bottomsheet_widget.dart';

// import '../utils/colors.dart';
// import 'button_widget.dart';

// class BookBottomSheetWidget extends StatelessWidget {
//   final destinationController = TextEditingController();

//   BookBottomSheetWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       reverse: true,
//       child: SizedBox(
//         height: 560,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   TextBold(text: 'Passenger', fontSize: 15, color: grey),
//                   IconButton(
//                     onPressed: (() {
//                       Navigator.pop(context);
//                     }),
//                     icon: const Icon(
//                       Icons.close_rounded,
//                       color: Colors.red,
//                       size: 32,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   const CircleAvatar(
//                     minRadius: 50,
//                     maxRadius: 50,
//                     backgroundImage: NetworkImage(
//                         'https://i.pinimg.com/originals/45/e1/9c/45e19c74f5c293c27a7ec8aee6a92936.jpg'),
//                   ),
//                   const SizedBox(
//                     width: 15,
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextBold(
//                           text: 'Name: Lance Olana', fontSize: 15, color: grey),
//                       TextRegular(
//                           text: '0909014355', fontSize: 14, color: grey),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               const Divider(
//                 color: grey,
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextBold(text: 'Current Location', fontSize: 15, color: grey),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.my_location,
//                     color: grey,
//                     size: 32,
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   TextBold(
//                       text: 'Sample current location',
//                       fontSize: 22,
//                       color: grey),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(
//                 children: [
//                   TextRegular(text: 'To:', fontSize: 18, color: grey),
//                   const SizedBox(
//                     width: 20,
//                   ),
//                   SizedBox(
//                     width: 250,
//                     height: 42,
//                     child: TextFormField(
//                       controller: destinationController,
//                       style: const TextStyle(
//                           color: Colors.black, fontFamily: 'QRegular'),
//                       decoration: InputDecoration(
//                         suffixIcon: const Icon(
//                           Icons.pin_drop_sharp,
//                           color: Colors.red,
//                         ),
//                         fillColor: Colors.white,
//                         filled: true,
//                         enabledBorder: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(width: 1, color: Colors.grey),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide:
//                               const BorderSide(width: 1, color: Colors.black),
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextRegular(text: 'Distance: 1.3km', fontSize: 15, color: grey),
//               const SizedBox(
//                 height: 5,
//               ),
//               TextRegular(
//                   text: 'Estimated time: 30mins', fontSize: 15, color: grey),
//               const SizedBox(
//                 height: 5,
//               ),
//               TextRegular(text: 'Fare: ₱250.00', fontSize: 15, color: grey),
//               const SizedBox(
//                 height: 10,
//               ),
//               const Divider(
//                 color: grey,
//               ),
//               const SizedBox(
//                 height: 20,
//               ),
//               Center(
//                 child: ButtonWidget(
//                     width: 250,
//                     radius: 100,
//                     opacity: 1,
//                     color: Colors.green,
//                     label: 'Accept booking',
//                     onPressed: (() {
//                       Navigator.pop(context);
//                       showModalBottomSheet(
//                           isScrollControlled: true,
//                           context: context,
//                           builder: ((context) {
//                             return const TrackBookingBottomSheetWidget();
//                           }));
//                     })),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               Center(
//                 child: ButtonWidget(
//                     width: 250,
//                     radius: 100,
//                     opacity: 1,
//                     color: Colors.red,
//                     label: 'Decline booking',
//                     onPressed: (() {
//                       showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                                 title: const Text(
//                                   'Decline confirmation',
//                                   style: TextStyle(
//                                       fontFamily: 'QBold',
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 content: const Text(
//                                   'Are you sure you want to Decline this booking?',
//                                   style: TextStyle(fontFamily: 'QRegular'),
//                                 ),
//                                 actions: <Widget>[
//                                   MaterialButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(true),
//                                     child: const Text(
//                                       'Close',
//                                       style: TextStyle(
//                                           fontFamily: 'QRegular',
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   MaterialButton(
//                                     onPressed: () async {
//                                       Navigator.of(context).pop();
//                                       Navigator.of(context).pop();
//                                     },
//                                     child: const Text(
//                                       'Continue',
//                                       style: TextStyle(
//                                           fontFamily: 'QRegular',
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ],
//                               ));
//                     })),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
