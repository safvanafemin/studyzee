// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

// Add progress callback support to your CloudinaryUploader
class CloudinaryUploader {
  final String cloudinaryCloudName = 'daai1jedw';
  final String cloudinaryUploadPreset = 'studyzee';
  Future<String?> uploadFile(
    XFile file, {
    Function(double progress)? onProgress,
  }) async {
    try {
      final mimeTypeData = lookupMimeType(file.path)?.split('/');

      String resourceType = 'image';
      if (mimeTypeData != null) {
        if (mimeTypeData[0] == 'application' && mimeTypeData[1] == 'pdf') {
          resourceType = 'raw';
        } else if (mimeTypeData[0] == 'video') {
          resourceType = 'video';
        }
      }

      final uploadUrl =
          "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/$resourceType/upload";

      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
        ..fields['upload_preset'] = cloudinaryUploadPreset
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            contentType: mimeTypeData != null
                ? MediaType(mimeTypeData[0], mimeTypeData[1])
                : null,
          ),
        );

      // Send the request and get the full response
      final response = await request.send();

      // Track upload progress
      var totalBytes = 0;
      final contentLength = request.contentLength ?? 0;

      // Process the response stream properly
      final stream = response.stream;
      final chunks = <List<int>>[];

      // Listen to stream only once and collect data
      await for (final chunk in stream) {
        chunks.add(chunk);
        totalBytes += chunk.length;

        // Report progress if callback provided
        if (onProgress != null && contentLength > 0) {
          onProgress(totalBytes / contentLength);
        }
      }

      // Combine all chunks into a single byte array
      final bytes = chunks.expand((x) => x).toList();

      // Parse the response
      final result = utf8.decode(bytes);
      final data = jsonDecode(result);

      if (response.statusCode == 200) {
        log("✅ Upload success ($resourceType): ${data['secure_url']}");
        return data['secure_url'];
      } else {
        log("❌ Upload failed: ${data['error']?.toString() ?? result}");
        return null;
      }
    } catch (e) {
      log("❌ Upload error: $e");
      return null;
    }
  }
}
