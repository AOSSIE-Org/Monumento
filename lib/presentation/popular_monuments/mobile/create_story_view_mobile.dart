import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monumento/domain/repositories/social_repository.dart';
import 'package:monumento/service_locator.dart';
import 'package:monumento/utils/app_colors.dart';
import 'package:monumento/utils/app_text_styles.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({Key? key}) : super(key: key);

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final SocialRepository _socialRepository = locator<SocialRepository>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85, // Compress image
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _uploadStory() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _socialRepository.addStory(
        imageFile: _selectedImage!,
        caption: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
      );

      _showSuccessSnackBar('Story uploaded successfully!');

      // Pop after short delay to show success message
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to upload story: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.appWarningRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColor.appPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.appSecondary,
        title: Text(
          'Create Story',
          style: AppTextStyles.textStyle(
            fontType: FontType.MEDIUM,
            size: 18,
            isBody: true,
            color: AppColor.appWhite,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColor.appWhite),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image preview or placeholder
            Container(
              height: 400,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.appGreyAccent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColor.appPrimary,
                  width: 2,
                ),
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: AppColor.appLightGrey.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No image selected',
                          style: AppTextStyles.textStyle(
                            fontType: FontType.REGULAR,
                            size: 16,
                            isBody: true,
                            color: AppColor.appLightGrey,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            // Image selection buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.appSecondary,
                        foregroundColor: AppColor.appWhite,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.appPrimary,
                        foregroundColor: AppColor.appBlack,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Caption input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Caption (Optional)',
                    style: AppTextStyles.textStyle(
                      fontType: FontType.MEDIUM,
                      size: 14,
                      isBody: true,
                      color: AppColor.appSecondaryBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Share something about this moment...',
                      hintStyle: AppTextStyles.textStyle(
                        fontType: FontType.REGULAR,
                        size: 14,
                        isBody: true,
                        color: AppColor.appLightGrey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColor.appGreyAccent,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColor.appGreyAccent,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColor.appPrimary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: AppColor.appBackground,
                    ),
                    style: AppTextStyles.textStyle(
                      fontType: FontType.REGULAR,
                      size: 14,
                      isBody: true,
                      color: AppColor.appSecondaryBlack,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Story info box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.appPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColor.appPrimary,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColor.appPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your story will disappear in 24 hours',
                        style: AppTextStyles.textStyle(
                          fontType: FontType.REGULAR,
                          size: 12,
                          isBody: true,
                          color: AppColor.appSecondaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Upload button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _uploadStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.appPrimary,
                    foregroundColor: AppColor.appBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor:
                        AppColor.appGreyAccent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColor.appBlack,
                            ),
                          ),
                        )
                      : Text(
                          'Upload Story',
                          style: AppTextStyles.textStyle(
                            fontType: FontType.MEDIUM,
                            size: 16,
                            isBody: true,
                            color: AppColor.appBlack,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
