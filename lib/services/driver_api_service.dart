import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/utils/logger.dart';

/// Response model for document upload
class DocumentUploadResult {
  final String documentId;
  final String documentType;
  final String status;
  final DateTime uploadedAt;

  const DocumentUploadResult({
    required this.documentId,
    required this.documentType,
    required this.status,
    required this.uploadedAt,
  });

  factory DocumentUploadResult.fromJson(Map<String, dynamic> json) {
    return DocumentUploadResult(
      documentId: json['document_id'] as String,
      documentType: json['document_type'] as String,
      status: json['status'] as String,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
}

/// Document types per API spec
enum DocumentType {
  license('license'),
  vehicleRegistration('vehicle_registration'),
  insurance('insurance');

  final String value;
  const DocumentType(this.value);
}

class DriverApiService {
  final ApiClient _apiClient;

  DriverApiService(this._apiClient);

  /// REST fallback for location update when WebSocket is disconnected
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.driverLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'heading': heading,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      logger.e('REST location update failed', error: e);
    }
  }

  /// Upload driver document (license, vehicle_registration, insurance)
  Future<DocumentUploadResult?> uploadDocument({
    required DocumentType documentType,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document_type': documentType.value,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });

      final response = await _apiClient.postMultipart(
        ApiEndpoints.driverDocuments,
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      return DocumentUploadResult.fromJson(data);
    } on DioException catch (e) {
      logger.e('Document upload failed', error: e);
      rethrow;
    }
  }
}

final driverApiServiceProvider = Provider<DriverApiService>((ref) {
  return DriverApiService(ref.read(apiClientProvider));
});
