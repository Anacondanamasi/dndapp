import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jewello/admin/add_banners.dart';
import 'package:jewello/admin/update_banner.dart';
import 'package:jewello/data/services/home_banner_service.dart';
import 'package:jewello/features/authentication/models/home_banner_model.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class AllBannersScreen extends StatefulWidget {
  const AllBannersScreen({super.key});

  @override
  State<AllBannersScreen> createState() => _AllBannersScreenState();
}

class _AllBannersScreenState extends State<AllBannersScreen> {
  final _bannerService = Get.isRegistered<HomeBannerService>()
      ? Get.find<HomeBannerService>()
      : Get.put(HomeBannerService());

  List<HomeBannerModel> _banners = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    setState(() => _isLoading = true);
    try {
      final banners = await _bannerService.getAllBanners();
      if (!mounted) return;
      setState(() {
        _banners = banners;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banners: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Home Banners'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _banners.isEmpty
              ? const Center(
                  child: Text(
                    'No banners found.\nAdd banners to show on the home slider.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBanners,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: _banners.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  UpdateBannerScreen(initialBanner: banner),
                            ),
                          );
                          if (updated == true) {
                            _fetchBanners();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(12),
                                ),
                                child: Image.network(
                                  banner.imageUrl,
                                  width: 140,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 140,
                                    height: 90,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Order: ${banner.sortOrder}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        banner.isActive
                                            ? 'Status: Active'
                                            : 'Status: Hidden',
                                        style: TextStyle(
                                          color: banner.isActive
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 20),
        child: ElevatedButton(
          onPressed: () async {
            final created = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBannersScreen()),
            );
            if (created == true) {
              _fetchBanners();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003049),
            foregroundColor: Colors.white,
            minimumSize: const Size(170, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'ADD BANNERS',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
