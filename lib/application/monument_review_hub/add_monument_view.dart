import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:monumento/application/monument_review_hub/review_hub_provider.dart';
import 'package:monumento/data/models/monument_approval_status.dart';
import 'package:monumento/data/models/monument_model.dart';
import 'package:monumento/utils/app_colors.dart';

class AddMonumentScreen extends StatefulWidget {
  const AddMonumentScreen({super.key});

  @override
  State<AddMonumentScreen> createState() => _AddMonumentScreenState();
}

class _AddMonumentScreenState extends State<AddMonumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _wikipediaLinkController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Additional images list
  final List<String> _additionalImages = [];
  final _additionalImageController = TextEditingController();

  double _latitude = 0.0;
  double _longitude = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _wikipediaLinkController.dispose();
    _imageUrlController.dispose();
    _additionalImageController.dispose();
    super.dispose();
  }

  void _addImageUrl() {
    final imageUrl = _additionalImageController.text.trim();
    if (imageUrl.isNotEmpty && _isValidUrl(imageUrl)) {
      setState(() {
        _additionalImages.add(imageUrl);
        _additionalImageController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image added successfully!'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid image URL'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _additionalImages.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Monument'),
        backgroundColor: AppColor.appPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Community Review',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your submission will be reviewed by the community. You\'ll earn 10 points when approved!',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Monument Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Monument Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter monument name' : null,
            ),
            const SizedBox(height: 16),

            // City
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: 16),

            // Country
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Country *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flag),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter country' : null,
            ),
            const SizedBox(height: 16),

            // Coordinates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    onChanged: (value) =>
                        _latitude = double.tryParse(value) ?? 0.0,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    onChanged: (value) =>
                        _longitude = double.tryParse(value) ?? 0.0,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Wikipedia Link
            TextFormField(
              controller: _wikipediaLinkController,
              decoration: const InputDecoration(
                labelText: 'Wikipedia Link',
                hintText: 'https://en.wikipedia.org/wiki/...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),

            // Main Image URL
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Main Image URL *',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
                helperText: 'This will be the primary image',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter main image URL';
                }
                if (!_isValidUrl(value!)) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Additional Images Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_library, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Additional Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_additionalImages.length} images',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add more images to showcase different angles and details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add Image URL Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _additionalImageController,
                            decoration: const InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'https://...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.add_photo_alternate),
                            ),
                            onSubmitted: (_) => _addImageUrl(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addImageUrl,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Display Added Images
                    if (_additionalImages.isNotEmpty) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Added Images:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _additionalImages.length,
                          itemBuilder: (context, index) {
                            return _buildImagePreview(
                              _additionalImages[index],
                              index,
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitMonument,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.appPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Submit for Review',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),

            // Summary Text
            if (_additionalImages.isNotEmpty)
              Center(
                child: Text(
                  'Total: 1 main image + ${_additionalImages.length} additional images',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl, int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey[600]),
                      const SizedBox(height: 4),
                      Text(
                        'Failed to load',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => _removeImage(index),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitMonument() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate that we have at least the main image
      if (_imageUrlController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one main image'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final provider = context.read<ReviewHubProvider>();

      // Combine main image with additional images
      final allImages = [
        _imageUrlController.text.trim(),
        ..._additionalImages,
      ];

      final wikiPageId =
          await getPageIdFromLink(_wikipediaLinkController.text.trim());

      final monument = MonumentModel(
        id: '',
        name: _nameController.text.trim(),
        country: _countryController.text.trim(),
        city: _cityController.text.trim(),
        coordinates: [_latitude, _longitude],
        imageUrl: _imageUrlController.text.trim(), // Main image
        has3DModel: false,
        approvalStatus: MonumentApprovalStatus.pending,
        rating: 0, // Will be set after reviews
        image_1x1_: _imageUrlController.text.trim(),
        wiki: _wikipediaLinkController.text.trim(),
        images: allImages, // All images including main
        wikiPageId: wikiPageId.toString(),

        upVotingPoints: 0,
        downVotingPoints: 0,
        upvotedBy: [],
        downvotedBy: [],
      );

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final userId = provider.currentUser?.uid ?? '';
      final success = await provider.submitMonumentModel(monument, userId);

      if (mounted) Navigator.pop(context); // Close loading dialog

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Monument submitted!',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Added ${allImages.length} ${allImages.length == 1 ? 'image' : 'images'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pop(context); // Go back to previous screen
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.error ?? 'Failed to submit monument'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: _submitMonument,
              ),
            ),
          );
        }
      }
    }
  }

  Future<int?> getPageIdFromLink(String wikipediaUrl) async {
    try {
      // Extract the title part from the URL (after /wiki/)
      final uri = Uri.parse(wikipediaUrl);
      final title = uri.pathSegments.last;

      // Call the API to get page info
      final response = await http.get(Uri.parse(
        "https://en.wikipedia.org/w/api.php?action=query&format=json&titles=$title&origin=*",
      ));

      final data = json.decode(response.body);

      final pages = data["query"]["pages"];
      final pageId = int.tryParse(pages.keys.first);

      return pageId;
    } catch (e) {
      print("Error fetching page ID: $e");
      return null;
    }
  }
}
