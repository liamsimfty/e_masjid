import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImageUploaded;
  final String? initialImageUrl;
  final String? label;

  const ImagePickerWidget({
    super.key,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.label,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _imageFile;
  String? _imageUrl;
  bool _isUploading = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  Future<bool> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      // Request camera permission
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus.isGranted) {
        return true;
      }
      // If permanently denied, show settings dialog
      if (cameraStatus.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Camera Permission Required'),
              content: const Text('Please enable camera access in settings to take photos.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
      }
      return false;
    } else {
      // For gallery access
      if (Platform.isAndroid) {
        // For Android 13 and above
        if (await Permission.photos.status.isDenied) {
          final status = await Permission.photos.request();
          return status.isGranted;
        }
        // For older Android versions
        if (await Permission.storage.status.isDenied) {
          final status = await Permission.storage.request();
          return status.isGranted;
        }
        return true;
      } else {
        // For iOS
        final status = await Permission.photos.request();
        if (status.isPermanentlyDenied) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Photo Library Permission Required'),
                content: const Text('Please enable photo library access in settings to select images.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
        }
        return status.isGranted;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final hasPermission = await _requestPermission(source);
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission denied. Please enable access in settings.'),
            ),
          );
        }
        return;
      }

      // Pick image using ImagePicker
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        // Convert XFile to File
        final File imageFile = File(pickedFile.path);
        
        // Upload image to Cloudinary
        final String? uploadedUrl = await _cloudinaryService.uploadImage(imageFile);
        if (uploadedUrl != null) {
          setState(() {
            _imageUrl = uploadedUrl;
            _isUploading = false;
          });
          widget.onImageUploaded(uploadedUrl);
        } else {
          setState(() {
            _isUploading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image. Please try again.')),
            );
          }
        }
      }
    } catch (e) {
      print('Error in _pickImage: $e'); // Add debug print
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        GestureDetector(
          onTap: _isUploading ? null : _showImageSourceDialog,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: _isUploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tekan untuk tambah image',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }
} 