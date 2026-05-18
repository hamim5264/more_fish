import 'package:get/get.dart';
import '../../../repo/cattle_live_repo.dart';
import '../../../response/cattle_notifications_response.dart';

class CattleNotificationsController extends GetxController {
  final CattleLiveDataRepository _repository = CattleLiveDataRepository();

  final notifications = <NotificationData>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    error.value = '';
    final result = await _repository.getNotifications();
    result.fold(
      (l) => error.value = l.message,
      (r) => notifications.assignAll(r.data ?? []),
    );
    isLoading.value = false;
  }
}
