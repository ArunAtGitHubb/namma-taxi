import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../services/driver_api_service.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() =>
      _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  DocumentType _selectedType = DocumentType.license;
  File? _selectedFile;
  bool _isUploading = false;
  String? _uploadMessage;

  Future<void> _pickImage() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _selectedFile = File(picked.path);
          _uploadMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to pick image', isError: true);
      }
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      context.showSnackBar('Please select a document image first', isError: true);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadMessage = null;
    });

    try {
      final service = ref.read(driverApiServiceProvider);
      final result = await service.uploadDocument(
        documentType: _selectedType,
        file: _selectedFile!,
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadMessage = result != null
              ? 'Document uploaded. Status: ${result.status}'
              : 'Upload failed';
        });

        if (result != null) {
          context.showSnackBar('Document uploaded successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadMessage = 'Upload failed: $e';
        });
        context.showSnackBar('Upload failed', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Document Type',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<DocumentType>(
              segments: const [
                ButtonSegment(
                  value: DocumentType.license,
                  label: Text('License'),
                  icon: Icon(Icons.badge_outlined),
                ),
                ButtonSegment(
                  value: DocumentType.vehicleRegistration,
                  label: Text('Vehicle'),
                  icon: Icon(Icons.directions_car_outlined),
                ),
                ButtonSegment(
                  value: DocumentType.insurance,
                  label: Text('Insurance'),
                  icon: Icon(Icons.security),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<DocumentType> selected) {
                setState(() {
                  _selectedType = selected.first;
                  _selectedFile = null;
                  _uploadMessage = null;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Document Image',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.grey300,
                    width: 2,
                  ),
                ),
                child: _selectedFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to select from camera or gallery',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_uploadMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _uploadMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            AppButton(
              label: _isUploading ? 'Uploading...' : 'Upload Document',
              icon: Icons.cloud_upload,
              onPressed: _isUploading ? null : _upload,
            ),
          ],
        ),
      ),
    );
  }
}
