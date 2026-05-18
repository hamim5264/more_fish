import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common_widgets/common_alert_dialog.dart';
import '../../../common_widgets/common_container.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_live_monitoring_controller.dart';
import 'cattle_live_monitoring_view.dart';

class CattleHomeView extends GetView<CattleIndexController> {
  const CattleHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: controller.listItemsEnglish1.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () async {
            controller.checkLogin();
            if (controller.isLoggedIn.value.isEmpty) {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: CommonAlertDialog(
                    notNow: () => Get.back(),
                    login: () async {
                      Get.back(); // Close dialog
                      final result = await Get.toNamed(
                        Routes.CATTLE_LOGIN,
                        arguments: {'fromGuard': true},
                      );
                      // ✅ Refresh login state in the controller
                      controller.checkLogin();
                      if (result == true) {
                        if (index == 0) {
                          Get.to(() => const CattleLiveMonitoringView());
                        } else {
                          Get.toNamed(Routes.COMING_SOON);
                        }
                      }
                    },
                  ),
                ),
              );
            } else {
              if (index == 0) {
                Get.to(() => const CattleLiveMonitoringView());
              } else {
                Get.toNamed(Routes.COMING_SOON);
              }
            }
          },
          child: CommonContainer(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(controller.iconList1[index], height: 70, width: 70),
                const SizedBox(height: 6),
                Text(
                  controller.listItemsEnglish1[index].tr,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
