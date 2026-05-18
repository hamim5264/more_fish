import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_app_bar.dart';
import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../routes/app_pages.dart';
import '../controllers/clean_air_header_controller.dart';
import '../controllers/clean_air_profile_controller.dart';

class CleanAirProfileView extends GetView<CleanAirProfileController> {
  const CleanAirProfileView({super.key});

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
          backgroundColor: const Color(0xffebffff),
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
                  backgroundColor: const Color(0xff3B73A5),
                ),
              ),
              Expanded(
                child: Obx(() {
                  final data = controller.profileResponse.value;
                  return controller.isLoggedIn.value.isEmpty
                      ? const SizedBox()
                      : data == null
                      ? const Center(child: Text('No cached profile yet.'))
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Expanded(
                                child: CommonContainer(
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CommonText(
                                        "${data.data?.firstName ?? ''} ${data.data?.lastName ?? ''}",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      CommonText(
                                        data.data?.usrEmail ?? '',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        await controller.logout();
                                        Get.offAllNamed(
                                          Routes.DMA_TECHNOLOGIES,
                                        );
                                      },
                                      child: const CommonContainer(
                                        height: 50,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 0,
                                          vertical: 16,
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Logout',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
