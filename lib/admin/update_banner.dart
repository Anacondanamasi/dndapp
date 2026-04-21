import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jewello/data/services/home_banner_service.dart';
import 'package:jewello/features/authentication/models/home_banner_model.dart';
import 'package:jewello/utils/theme/appbar_theme.dart';

class UpdateBannerScreen extends StatefulWidget {
  final HomeBannerModel initialBanner;

  const UpdateBannerScreen({
    super.key,
    required this.initialBanner,
  });

  @override
  State<UpdateBannerScreen> createState() => _UpdateBannerScreenState();
}

class _UpdateBannerScreenState extends State<UpdateBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _bannerService = Get.isRegistered<HomeBannerService>()
      ? Get.find<HomeBannerService>()
      : Get.put(HomeBannerService());

  late TextEditingController _orderController;
  late bool _isActive;
  late String _imageUrl;
  XFile? _replacementImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _orderController =
        TextEditingController(text: widget.initialBanner.sortOrder.toString());
    _isActive = widget.initialBanner.isActive;
    _imageUrl = widget.initialBanner.imageUrl;
  }

  @override
  void dispose() {
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickReplacement() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    setState(() {
      _replacementImage = image;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _bannerService.updateBanner(
        bannerId: widget.initialBanner.id,
        sortOrder: int.parse(_orderController.text.trim()),
        isActive: _isActive,
        currentImageUrl: _imageUrl,
        replacementImage: _replacementImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner updated successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating banner: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteBanner() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);
    try {
      await _bannerService.deleteBanner(widget.initialBanner);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting banner: $e')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarThemeStyle(title: 'Update Banner'),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF003049)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 190,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _replacementImage != null
                            ? _PickedPreview(image: _replacementImage!)
                            : Image.network(
                                _imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _pickReplacement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003049),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('REPLACE IMAGE'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sort Order',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _orderController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter sort order';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Sort order must be a number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Banner Active',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() {
                          _isActive = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('UPDATE BANNER'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _deleteBanner,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text(
                          'DELETE BANNER',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PickedPreview extends StatelessWidget {
  final XFile image;

  const _PickedPreview({required this.image});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        if (!snapshot.hasData || snapshot.hasError) {
          return const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          );
        }

        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        );
      },
    );
  }
}
