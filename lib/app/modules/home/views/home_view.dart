import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:more_fish/app/common_widgets/common_alert_dialog.dart';
import 'package:more_fish/app/common_widgets/common_app_bar.dart';
import 'package:more_fish/app/common_widgets/common_container.dart';
import 'package:more_fish/app/res/colors/colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
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
                  title: 'title'.tr,
                  cityName: "dhaka".tr,
                  date: '${controller.formattedDate}',
                  time: '${controller.formattedTime}',
                  temp: '${controller.weatherData['main']?['temp'] ?? ''}°C',
                  humidity: '${controller.weatherData['main']?['humidity'] ?? ''}%',
                );
              }),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 14),
/*                      SizedBox(
                        height: 180,
                        child: PageView.builder(
                          controller: controller.pageController,
                          itemCount: controller.bannerList.length,
                          onPageChanged: (index) {
                            controller.currentPage.value = index;
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  controller.bannerList[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),*/
                      const SizedBox(height: 14),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.listItemsEnglish1.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (index == 0) {
                                controller.checkLogin();
                                if (controller.isLoggedIn.value.isEmpty) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => WillPopScope(
                                      onWillPop: () async => false,
                                      child: CommonAlertDialog(
                                        notNow: () => Get.back(),
                                        login: () => Get.toNamed(Routes.LOGIN),
                                      ),
                                    ),
                                  );
                                } else {
                                  Get.toNamed(Routes.WATER_QUALITY_DEVICE);
                                }
                              } else {
                                Get.toNamed(Routes.COMING_SOON);
                              }
                            },
                            child: CommonContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    controller.iconList1[index],
                                    height: 50,
                                    width: 50,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    controller.listItemsEnglish1[index].tr,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.listItemsEnglish2.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              if (index == 5) {
                                Get.toNamed(Routes.WEATHER_FORECAST);
                              } else {
                                Get.toNamed(Routes.COMING_SOON);
                              }
                            },
                            child: CommonContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    controller.iconList2[index],
                                    height: 50,
                                    width: 50,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    controller.listItemsEnglish2[index].tr,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
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
