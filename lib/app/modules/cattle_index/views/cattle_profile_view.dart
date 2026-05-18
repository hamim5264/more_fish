import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common_widgets/common_container.dart';
import '../../../common_widgets/common_text.dart';
import '../../../routes/app_pages.dart';
import '../controllers/cattle_index_controller.dart';
import '../controllers/cattle_profile_controller.dart';

class CattleProfileView extends GetView<CattleIndexController> {
  const CattleProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final cattleProfileController = Get.find<CattleProfileController>();
    cattleProfileController.checkLogin();

    return Scaffold(
      backgroundColor: const Color(0xffebffff),
      body: Obx(() {
        var data = cattleProfileController.profileResponse.value;
        return cattleProfileController.isLoggedIn.isEmpty
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CommonText(
                                  "${data.data?.firstName ?? ''} ${data.data?.lastName ?? ''} ",
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
                                const SizedBox(height: 4),
                                data.data?.userPhone != null
                                    ? CommonText(
                                        "${data.data?.userPhone?.phnCell ?? ''}",
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      )
                                    : const CommonText(""),
                                const SizedBox(height: 50),
                              ],
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
                              Get.toNamed(Routes.PASSWORD_CHANGE);
                            },
                            child: const CommonContainer(
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 16,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Change Password",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              // ✅ Logout only from Cattle Care
                              await cattleProfileController.loginTokenStorage
                                  .clearCattleSession();
                              cattleProfileController.isLoggedIn.value = '';
                              Get.offAllNamed(Routes.CATTLE_INDEX);
                            },
                            child: const CommonContainer(
                              height: 50,
                              margin: EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 16,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.justify,
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
    );
  }
}
