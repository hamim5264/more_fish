import 'package:get/get.dart';
import '../../../service/local_storage.dart';

class CattleIndexController extends GetxController {
  final selectedIndex = 0.obs;
  var isLoggedIn = ''.obs;

  var listItemsEnglish1 = [
    'Live Data\nmonitoring',
    'Farm\nManagement',
    'Feed\nManagement',
    'Cattle Disease\nTreatment',
    'Cattle\nMarketplace',
    'Cattle Feed\nMarketplace',
    'Auto Feeder',
    'Weather\nForecast',
    'Live\nConsultancy',
    'Auto Water\nSystem',
    'Financial\nManagement',
  ].obs;

  var iconList1 = [
    "assets/icons/water_quality_check.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/farm_management/cow_feed.png",
    "assets/icons/feed_management.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/doctor_service.png",
    "assets/icons/fish_farm_materials.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/farm_management/cow.png",
    "assets/icons/fish_medicine.png",
    "assets/icons/feed_management.png",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    final loginTokenStorage = Get.find<LoginTokenStorage>();
    // ✅ Check specifically for Cattle token
    if (loginTokenStorage.hasValidCattleToken()) {
      isLoggedIn.value = loginTokenStorage.getCattleToken()!;
    } else {
      isLoggedIn.value = '';
    }
  }
}
