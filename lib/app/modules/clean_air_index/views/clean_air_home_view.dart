// app/modules/clean_air_index/views/clean_air_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_app_bar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/clean_air_header_controller.dart';
import '../controllers/clean_air_index_controller.dart';

class CleanAirHomeView extends GetView<CleanAirIndexController> {
  const CleanAirHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<CleanAirHeaderController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 231, 255, 236),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 222, 255, 230),
          body: Column(
            children: [
              Obx(
                () => CommonAppBar(
                  title: 'Pharma Care',
                  cityName: 'Dhaka',
                  date: header.formattedDate.value,
                  time: header.formattedTime.value,
                  temp: header.tempText.value,
                  humidity: header.humidityText.value,
                  logoAssetPath: 'assets/icons/dma_pharmaceutical.png',
                  backgroundColor: const Color(0xff4F84B5),
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: _HomeFeatureTile(
                      title: 'Live Data Monitoring',
                      iconAssetPath: 'assets/icons/water_quality_check.png',
                      onTap: () async {
                        final canOpen = await controller.ensureLoggedIn();
                        if (!canOpen) {
                          return;
                        }
                        Get.toNamed(Routes.CLEAN_AIR_LIVE_MONITORING);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeFeatureTile extends StatelessWidget {
  const _HomeFeatureTile({
    required this.title,
    required this.iconAssetPath,
    required this.onTap,
  });

  final String title;
  final String iconAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromARGB(255, 245, 255, 246),
      elevation: 2,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 170,
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconAssetPath, height: 70, fit: BoxFit.contain),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
