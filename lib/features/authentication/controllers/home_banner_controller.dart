import 'package:get/get.dart';
import 'package:jewello/data/services/home_banner_service.dart';
import 'package:jewello/features/authentication/models/home_banner_model.dart';

class HomeBannerController extends GetxController {
  static HomeBannerController get instance => Get.find();

  final _bannerService = Get.isRegistered<HomeBannerService>()
      ? Get.find<HomeBannerService>()
      : Get.put(HomeBannerService());

  final RxList<HomeBannerModel> banners = <HomeBannerModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;
      final response = await _bannerService.getActiveBanners();
      banners.assignAll(response);
    } catch (_) {
      banners.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
