import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/cattle_live_data_controller.dart';

class CattleLiveDataView extends GetView<CattleLiveDataController> {
  const CattleLiveDataView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CattleLiveDataView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CattleLiveDataView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
