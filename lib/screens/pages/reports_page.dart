import 'package:flutter/material.dart';

import '../../widgets/appbar_widget.dart';
import '../../widgets/drawer_widget.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppbarWidget('Earnings report'),
    );
  }
}
