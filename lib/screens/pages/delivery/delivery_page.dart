import 'package:flutter/material.dart';

import '../../../utils/colors.dart';
import '../../../widgets/text_widget.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: grey,
        backgroundColor: Colors.white,
        title: TextRegular(text: 'Delivery', fontSize: 24, color: grey),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.history,
              color: grey,
            ),
          ),
        ],
      ),
    );
  }
}
