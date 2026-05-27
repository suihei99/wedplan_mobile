import 'package:dio/dio.dart';

class VendorServiceDraft {
  const VendorServiceDraft({
    required this.serviceName,
    required this.typeService,
    required this.priceEstimate,
    required this.description,
    this.imagePath,
  });

  final String serviceName;
  final String typeService;
  final double priceEstimate;
  final String description;
  final String? imagePath;

  Future<FormData> toFormData() async {
    final formData = FormData.fromMap(<String, dynamic>{
      'service_name': serviceName,
      'type_service': typeService,
      'price_estimate': priceEstimate,
      'description': description,
    });

    if (imagePath != null && imagePath!.trim().isNotEmpty) {
      formData.files.add(
        MapEntry('image_url', await MultipartFile.fromFile(imagePath!.trim())),
      );
    }

    return formData;
  }
}
