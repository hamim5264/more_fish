import 'package:get/get.dart';
import '../../../repo/auth.dart';
import '../../../response/profile_response.dart';
import '../../../service/local_storage.dart';

class CattleProfileController extends GetxController {
  final loginTokenStorage = Get.find<LoginTokenStorage>();
  final authRepository = AuthRepository();
  final profileResponse = Rxn<ProfileResponse>();
  var isLoggedIn = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  void checkLogin() {
    if (loginTokenStorage.hasValidCattleToken()) {
      isLoggedIn.value = loginTokenStorage.getCattleToken()!;
      getProfile();
    } else {
      isLoggedIn.value = '';
    }
  }

  void getProfile() async {
    var response = await authRepository.getProfile(isCattleFlow: true);
    response.fold(
      (l) => print("Profile error: ${l.message}"),
      (r) => profileResponse.value = r,
    );
  }
}
