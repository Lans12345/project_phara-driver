import 'package:flutter/material.dart';
import 'package:phara_driver/widgets/text_widget.dart';

import '../../widgets/appbar_widget.dart';
import '../../widgets/drawer_widget.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppbarWidget('Earnings report'),
      body: Column(
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
                      text: 'Total:', fontSize: 14, color: Colors.white),
                  const SizedBox(
                    width: 10,
                  ),
                  TextBold(text: '₱12,000', fontSize: 42, color: Colors.white),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 10),
            child: TextRegular(
                text: 'Average: ₱500', fontSize: 16, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
            child: TextRegular(
                text: 'Today: ₱500', fontSize: 16, color: Colors.black),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
