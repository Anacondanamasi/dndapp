import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/features/authentication/models/home_banner_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class HomeBannerService extends GetxController {
  static HomeBannerService get instance => Get.find();
  static const String bannerTable = 'home_banners';
  static const String bannerBucket = 'home-banners';

  final _supabase = sb.Supabase.instance.client;

  Future<List<HomeBannerModel>> getActiveBanners() async {
    try {
      final List<dynamic> response = await _supabase
          .from(bannerTable)
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      return response
          .map((row) => HomeBannerModel.fromMap(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<List<HomeBannerModel>> getAllBanners() async {
    try {
      final List<dynamic> response = await _supabase
          .from(bannerTable)
          .select()
          .order('sort_order', ascending: true)
          .order('created_at', ascending: true);

      return response
          .map((row) => HomeBannerModel.fromMap(Map<String, dynamic>.from(row)))
          .toList();
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<void> addBanners(List<XFile> images, {bool isActive = true}) async {
    if (images.isEmpty) return;
    try {
      final int startOrder = await _getNextSortOrder();

      for (int i = 0; i < images.length; i++) {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        final imageUrl = await uploadBannerImage(bannerId: id, image: images[i]);

        await _supabase.from(bannerTable).insert({
          'id': id,
          'image_url': imageUrl,
          'sort_order': startOrder + i,
          'is_active': isActive,
        });
      }
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<void> updateBanner({
    required String bannerId,
    required int sortOrder,
    required bool isActive,
    required String currentImageUrl,
    XFile? replacementImage,
  }) async {
    String finalImageUrl = currentImageUrl;
    try {
      if (replacementImage != null) {
        finalImageUrl = await uploadBannerImage(
          bannerId: bannerId,
          image: replacementImage,
        );
        await deleteBannerImage(currentImageUrl);
      }

      await _supabase.from(bannerTable).update({
        'image_url': finalImageUrl,
        'sort_order': sortOrder,
        'is_active': isActive,
      }).eq('id', bannerId);
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<void> deleteBanner(HomeBannerModel banner) async {
    try {
      await _supabase.from(bannerTable).delete().eq('id', banner.id);
      await deleteBannerImage(banner.imageUrl);
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<String> uploadBannerImage({
    required String bannerId,
    required XFile image,
  }) async {
    try {
      final fileExtension = _fileExtension(image.name);
      final path =
          '$bannerId/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final bytes = await image.readAsBytes();

      await _supabase.storage.from(bannerBucket).uploadBinary(
            path,
            bytes,
            fileOptions: const sb.FileOptions(upsert: true),
          );

      return _supabase.storage.from(bannerBucket).getPublicUrl(path);
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<void> deleteBannerImage(String imageUrl) async {
    try {
      final imagePath = _extractPathFromPublicUrl(imageUrl);
      if (imagePath == null || imagePath.isEmpty) return;

      await _supabase.storage.from(bannerBucket).remove([imagePath]);
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  Future<int> _getNextSortOrder() async {
    try {
      final List<dynamic> response = await _supabase
          .from(bannerTable)
          .select('sort_order')
          .order('sort_order', ascending: false)
          .limit(1);

      if (response.isEmpty) return 1;

      final int latest =
          int.tryParse(response.first['sort_order'].toString()) ?? 0;
      return latest + 1;
    } catch (e) {
      _throwFriendlySetupErrorIfNeeded(e);
      rethrow;
    }
  }

  String? _extractPathFromPublicUrl(String publicUrl) {
    final marker = '$bannerBucket/';
    final markerIndex = publicUrl.indexOf(marker);
    if (markerIndex == -1) return null;

    return publicUrl.substring(markerIndex + marker.length);
  }

  String _fileExtension(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == fileName.length - 1) return 'jpg';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  void _throwFriendlySetupErrorIfNeeded(Object error) {
    final text = error.toString();
    final missingTable =
        text.contains('PGRST205') && text.contains("public.home_banners");
    final missingBucket = text.toLowerCase().contains('bucket') &&
        text.contains(bannerBucket);

    if (missingTable || missingBucket) {
      throw Exception(
        'Home banners database setup is missing. Run `supabase/home_banners_setup.sql` once in Supabase SQL Editor, then try again.',
      );
    }
  }
}
