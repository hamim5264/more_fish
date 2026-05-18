import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_alert_dialog.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_header_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';
import 'cattle_home_view.dart';
import 'cattle_more_view.dart';
import 'cattle_notifications_view.dart';
import 'cattle_profile_view.dart';

class CattleIndexView extends GetView<CattleIndexController> {
  const CattleIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    final header = Get.find<CattleHeaderController>();


    const pages = [
      CattleHomeView(),
      CattleNotificationsView(),
      CattleProfileView(),
      CattleMoreView(),
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 243),
      body: Column(
        children: [
          _GlobalCattleHeader(header: header),
          Expanded(
            child: Obx(() {
              return pages[controller.selectedIndex.value];
            }),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          backgroundColor: const Color(0xffebffff),
          currentIndex: controller.selectedIndex.value,
          onTap: (index) async {
            if ((index == 1 || index == 2) && controller.isLoggedIn.isEmpty) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: CommonAlertDialog(
                    notNow: () {
                      Get.back();
                    },
                    login: () async {
                      Get.back(); // Close dialog
                      final result = await Get.toNamed(
                        Routes.CATTLE_LOGIN,
                        arguments: {'fromGuard': true},
                      );
                      
                      // ✅ Always refresh state after returning from login
                      controller.checkLogin();
                      if (result == true) {
                        controller.selectedIndex.value = index;
                        // ✅ Refresh monitoring data if it has been instantiated
                        if (Get.isRegistered<CattleLiveMonitoringController>()) {
                          Get.find<CattleLiveMonitoringController>().refreshLiveData();
                        }
                      }
                    },
                  ),
                ),
              );
              return;
            }
            controller.selectedIndex.value = index;
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff0370c3),
          unselectedItemColor: Colors.blueGrey,
          elevation: 4,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
          ],
        );
      }),
    );
  }
}

class _GlobalCattleHeader extends StatelessWidget {
  const _GlobalCattleHeader({required this.header});

  final CattleHeaderController header;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      height: 120,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
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
                        Obx(
                          () => Text(
                            header.district.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Obx(
                          () => Text(
                            header.description.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff546e7a),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Obx(
                          () => header.sunlight.value.isNotEmpty
                              ? Text(
                                  "Sunlight: ${header.sunlight.value}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.orange,
                                  ),
                                )
                              : const SizedBox.shrink(),
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
                        Obx(
                          () => Text(
                            header.tempText.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Text(
                          "  |  ",
                          style: TextStyle(color: Colors.black26),
                        ),
                        Obx(
                          () => Text(
                            header.humidityText.value,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      header.formattedDate.value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      header.formattedTime.value,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
