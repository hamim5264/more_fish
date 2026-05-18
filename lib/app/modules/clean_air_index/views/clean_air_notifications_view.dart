import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../controllers/clean_air_header_controller.dart';
import '../controllers/clean_air_notifications_controller.dart';

class CleanAirNotificationsView
    extends GetView<CleanAirNotificationsController> {
  const CleanAirNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<CleanAirHeaderController>();
    controller.checkLogin();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd4fcfd),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.backGround,
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
                  backgroundColor: const Color(0xff3B73A5)
                ),
              ),
              Expanded(
                child: Obx(() {
                  final data = controller.notificationResponse.value;
                  return controller.isLoggedIn.value.isEmpty
                      ? const SizedBox()
                      : data != null
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          itemCount: data.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final item = data.data![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: _decoration(),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xffebffff),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CommonText(
                                          item.notTime == null
                                              ? ''
                                              : DateFormat('dd:MM:yyyy').format(
                                                  item.notTime!.toLocal(),
                                                ),
                                          color: const Color(0xff0d66a8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        CommonText(
                                          item.notTime == null
                                              ? ''
                                              : DateFormat('hh:mm a').format(
                                                  item.notTime!.toLocal(),
                                                ),
                                          color: const Color(0xff0d66a8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: CommonText(
                                      '${item.notFinal ?? ''}',
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      textAlign: TextAlign.justify,
                                      maxLines: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text('No cached notifications yet.'),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _decoration() => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xfffbffff), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.blueGrey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 1,
        offset: const Offset(.2, .2),
      ),
    ],
  );
}
