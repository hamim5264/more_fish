import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../cattle_index/controllers/cattle_header_controller.dart';
import '../controllers/about_devices_controller.dart';

class AboutDevicesView extends GetView<AboutDevicesController> {
  const AboutDevicesView({super.key});
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    final bool isCattle = Get.isRegistered<CattleHeaderController>();

    return Scaffold(
      backgroundColor: AppColors.backGround,
      body: Column(
        children: [
          Obx(() {
            if (isCattle) {
              final cattleHeader = Get.find<CattleHeaderController>();
              return _CattleCareHeader(header: cattleHeader);
            }

            final weather = homeController.weatherData.value;
            final main = (weather.isNotEmpty && weather.containsKey('main'))
                ? weather['main']
                : null;
            return CommonAppBar(
              title: 'title'.tr,
              cityName: "dhaka".tr,
              date: homeController.formattedDate.value,
              time: homeController.formattedTime.value,
              temp: main != null ? '${main['temp']}°C' : '',
              humidity: main != null ? '${main['humidity']}%' : '',
            );
          }),
          Expanded(
              child: ListView.builder(
            padding: const EdgeInsets.only(top: 16),
            itemCount: controller.titleList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(Routes.FAQ_DETAILS, arguments: {
                    "title": controller.titleList[index],
                    "data": controller.dataList[index]
                  });
                },
                child: CommonContainer(
                  margin:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CommonText(
                              controller.titleList[index].tr,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class _CattleCareHeader extends StatelessWidget {
  const _CattleCareHeader({required this.header});
  final CattleHeaderController header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      height: 120,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.black12))),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/icons/dma_cattle_care.png',
                      height: 50,
                      width: 50,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          header.district.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          header.description.value,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff546e7a),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (header.sunlight.value.isNotEmpty)
                          Text(
                            "Sunlight: ${header.sunlight.value}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          header.tempText.value,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const Text("  |  ",
                            style: TextStyle(color: Colors.black26)),
                        Text(
                          header.humidityText.value,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    header.formattedDate.value,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  Text(
                    header.formattedTime.value,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
