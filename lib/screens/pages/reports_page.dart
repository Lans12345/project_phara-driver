import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phara_driver/widgets/text_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../widgets/appbar_widget.dart';
import '../../widgets/drawer_widget.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    getTotalFare();
    super.initState();
  }

  List fares = [];

  bool hasLoaded = false;

  double total = 0;

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Monday', 5),
      ChartData('Tuesday', 5),
      ChartData('Wednesday', 5),
      ChartData('Thursday', 5),
      ChartData('Friday', 5),
      ChartData('Saturday', 5),
      ChartData('Sunday', 5),
    ];
    return Scaffold(
        drawer: DrawerWidget(),
        appBar: AppbarWidget('Earnings report'),
        body: hasLoaded
            ? SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Bookings')
                        .where('driverId',
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where('status', isEqualTo: 'Accepted')
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

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF363636),
                                    Color(0xFF363636),
                                    Color(0xFF363636),
                                  ],
                                  stops: [0.0, 0.848, 0.6],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextRegular(
                                      text: 'Total:',
                                      fontSize: 14,
                                      color: Colors.white),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  TextBold(
                                      text:
                                          '₱${NumberFormat('#,##0.00', 'en_US').format(total)}',
                                      fontSize: 42,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 10),
                            child: TextRegular(
                                text: 'Average: ₱500',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, bottom: 20),
                            child: TextRegular(
                                text: 'Today: ₱500',
                                fontSize: 16,
                                color: Colors.black),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                                left: 30, right: 30, bottom: 10),
                            child: Divider(
                              thickness: 2,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                            child: Column(
                              children: [
                                TextRegular(
                                    text: 'Number of bookings per day',
                                    fontSize: 18,
                                    color: Colors.black),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                    child: SfCartesianChart(
                                        primaryXAxis: CategoryAxis(),
                                        series: <
                                            ChartSeries<ChartData, String>>[
                                      // Renders column chart
                                      ColumnSeries<ChartData, String>(
                                          dataSource: chartData,
                                          xValueMapper: (ChartData data, _) =>
                                              data.x,
                                          yValueMapper: (ChartData data, _) =>
                                              data.y)
                                    ])),
                              ],
                            ),
                          )
                        ],
                      );
                    }),
              )
            : const Center(child: CircularProgressIndicator()));
  }

  getTotalFare() async {
    await FirebaseFirestore.instance
        .collection('Bookings')
        .where('driverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('status', isEqualTo: 'Accepted')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print(doc['fare']);
        setState(() {
          total += double.parse(doc['fare']);
        });
      }
    });

    setState(() {
      hasLoaded = true;
    });
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}

class ChartData1 {
  ChartData1(this.x, this.y);
  final String x;
  final double? y;
}
