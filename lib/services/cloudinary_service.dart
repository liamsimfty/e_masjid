import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class CloudinaryService {
  // Your Cloudinary credentials
  static const String cloudName = 'dos3ayqz1';
  static const String uploadPreset = 'e_masjid';
  
  final cloudinary = CloudinaryPublic(
    cloudName,
    uploadPreset,
    cache: false,
  );

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        print('Error: Image file does not exist');
        return null;
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        print('Error: Image file is too large (max 10MB)');
        return null;
      }

      print('Uploading image to Cloudinary...');
      print('Cloud Name: $cloudName');
      print('Upload Preset: $uploadPreset');
      print('File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Upload to Cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'e_masjid', // This folder will be created automatically
        ),
      );

      if (response.secureUrl.isNotEmpty) {
        print('✅ Successfully uploaded image to Cloudinary');
        print('🔗 URL: ${response.secureUrl}');
        print('📁 Public ID: ${response.publicId}');
        return response.secureUrl;
      } else {
        print('❌ Error: No secure URL returned from Cloudinary');
        return null;
      }
    } catch (e) {
      print('❌ Error uploading image to Cloudinary: $e');
      
      if (e is DioException) {
        print('📊 DioError Status Code: ${e.response?.statusCode}');
        print('📋 DioError Response Data: ${e.response?.data}');
        print('🔍 DioError Message: ${e.message}');
        
        // Handle specific error cases
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          if (errorData != null && errorData.toString().contains('Upload preset not found')) {
            print('🚨 Upload preset "$uploadPreset" not found!');
            print('💡 Please check your Cloudinary dashboard and ensure:');
            print('   1. Upload preset "$uploadPreset" exists');
            print('   2. Upload preset is set to "Unsigned" mode');
            print('   3. Cloud name "$cloudName" is correct');
          }
        }
      }
      return null;
    }
  }

  Future<File?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );
      
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        print('📷 Image picked successfully');
        print('📏 Size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  // Method to test connection and preset
  Future<bool> testUploadPreset() async {
    try {
      // Create a simple test image data
      final testData = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';
      
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromBytesData(
          testData.codeUnits,
          identifier: 'test_image',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('✅ Upload preset test successful!');
      return true;
          return false;
    } catch (e) {
      print('❌ Upload preset test failed: $e');
      return false;
    }
  }
}