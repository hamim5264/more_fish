import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_app_bar.dart';

import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/aerator_connection_controller.dart';

class AeratorConnectionView extends GetView<AeratorConnectionController> {
  const AeratorConnectionView({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
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
              Obx(() {
                return CommonAppBar(
                  title: 'Aerator Connection',
                  cityName: 'Dhaka',
                  date: '${homeController.formattedDate}',
                  time: '${homeController.formattedTime}',
                  temp: '${homeController.weatherData['main']['temp']}°C',
                  humidity:
                      '${homeController.weatherData['main']['humidity']}%',
                );
              }),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.aerators.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.aerators.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CommonText(
                          'No aerator data found',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      await controller.forceRefresh();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.aerators.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final aerator = controller.aerators[index];
                        return _AeratorStatusCard(aerator: aerator);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AeratorStatusCard extends StatelessWidget {
  const _AeratorStatusCard({required this.aerator});

  final dynamic aerator;

  @override
  Widget build(BuildContext context) {
    final bool isOnline = aerator.isOnline == true;

    return CommonContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 58,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xff2fbf71)
                  : const Color(0xffe74c3c),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  aerator.aeratorName ?? 'Aerator',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                const SizedBox(height: 4),
                CommonText(
                  aerator.aeratorId ?? '',
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Switch(
                value: isOnline,
                onChanged: null,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.grey,
              ),
              CommonText(
                isOnline ? 'Online' : 'Offline',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isOnline
                    ? const Color(0xff2fbf71)
                    : const Color(0xffe74c3c),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
/*CommonContainer(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonText(
                            'Aerator-1',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 20,),
                          Switch(
                            value: controller.isSwitched1.value,
                            onChanged: (bool value) {

                              controller.isSwitched1.value = value;

                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    CommonContainer(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonText(
                            'Aerator-2',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 20,),
                          Switch(
                            value: controller.isSwitched2.value,
                            onChanged: (bool value) {

                              controller.isSwitched2.value = value;

                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    CommonContainer(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonText(
                            'Aerator-3',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 20,),
                          Switch(
                            value: controller.isSwitched3.value,
                            onChanged: (bool value) {

                              controller.isSwitched3.value = value;

                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    CommonContainer(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CommonText(
                            'Aerator-4',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(width: 20,),
                          Switch(
                            value: controller.isSwitched4.value,
                            onChanged: (bool value) {

                              controller.isSwitched4.value = value;

                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),*/