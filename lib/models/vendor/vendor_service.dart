import 'package:wedplan_mobile/core/router/app_router.dart';

class VendorService {
  VendorService({
    required this.id,
    required this.serviceName,
    required this.typeService,
    required this.priceEstimate,
    required this.description,
    required this.imageUrl,
    required this.imageUrlResolved,
    required this.vendorBusinessName,
    required this.vendorAddress,
    required this.vendorContactNumber,
    required this.vendorEmail,
    required this.bookingDates,
    required this.raw,
  });

  final dynamic id;
  final String serviceName;
  final String typeService;
  final double priceEstimate;
  final String description;
  final String imageUrl;
  final String imageUrlResolved;
  final String vendorBusinessName;
  final String vendorAddress;
  final String vendorContactNumber;
  final String vendorEmail;
  final List<String> bookingDates;
  final Map<String, dynamic> raw;

  bool get hasImage => imageUrl.trim().isNotEmpty;

  String get serviceTypeLabel => _titleCase(typeService);

  String get priceLabel => 'RM ${priceEstimate.toStringAsFixed(2)}';

  String get descriptionLabel => description.trim().isNotEmpty
      ? description.trim()
      : 'No description provided by the vendor yet.';

  String get resolvedImageUrl => imageUrlResolved.trim().isNotEmpty
      ? imageUrlResolved.trim()
      : _resolveImageUrl(imageUrl);

  bool get hasVendorDetails =>
      vendorBusinessName.trim().isNotEmpty ||
      vendorContactNumber.trim().isNotEmpty ||
      vendorEmail.trim().isNotEmpty;

  factory VendorService.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    final user = _readMap(data, ['user']);
    final vendor = _readMap(data, ['vendor']);
    final nestedVendor = _readMap(user, ['vendor']);
    final serviceData = _readMap(data, ['service']);
    final source = serviceData.isNotEmpty ? serviceData : data;
    return VendorService(
      id:
          source['id'] ??
          source['service_id'] ??
          data['id'] ??
          data['service_id'],
      serviceName: _firstString([
        source['service_name'],
        source['name'],
        source['title'],
      ], fallback: 'Service'),
      typeService: _firstString([
        source['type_service'],
        source['service_type'],
        source['category'],
      ]),
      priceEstimate: _firstDouble([
        source['price_estimate'],
        source['price'],
        source['starting_price'],
      ]),
      description: _firstString([
        source['description'],
        source['summary'],
        source['details'],
      ]),
      imageUrl: _firstString([
        source['image_url'],
        source['image'],
        source['photo_url'],
      ]),
      imageUrlResolved: _firstString([
        source['image_url_resolved'],
        data['image_url_resolved'],
      ]),
      vendorBusinessName: _firstString([
        vendor['business_name'],
        nestedVendor['business_name'],
        vendor['company_name'],
        nestedVendor['company_name'],
        data['business_name'],
      ]),
      vendorAddress: _firstString([
        vendor['address'],
        nestedVendor['address'],
        data['address'],
      ]),
      vendorContactNumber: _firstString([
        vendor['contact_number'],
        nestedVendor['contact_number'],
        data['contact_number'],
      ]),
      vendorEmail: _firstString([
        user['email'],
        vendor['email'],
        data['email'],
      ]),
      bookingDates: _readStringList(data, const [
        'booking_dates',
        'bookingDates',
      ]),
      raw: json,
    );
  }
}

Map<String, dynamic> _unwrap(Map<String, dynamic> source) {
  final data = source['data'];
  if (data is Map<String, dynamic>) return data;
  if (data is Map) {
    return data.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
  return source;
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map<String, dynamic>(
        (mapKey, mapValue) => MapEntry(mapKey.toString(), mapValue),
      );
    }
  }
  return <String, dynamic>{};
}

List<String> _readStringList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
  }
  return const <String>[];
}

String _firstString(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

double _firstDouble(Iterable<dynamic> values) {
  for (final value in values) {
    if (value == null) continue;
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString().trim());
    if (parsed != null) return parsed;
  }
  return 0.0;
}

String _resolveImageUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;
  if (uri.hasScheme) return trimmed;

  final baseUri = Uri.parse(ApiRouter.baseUrl);
  final relative = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return baseUri.resolve(relative).toString();
}

String _titleCase(String value) {
  final trimmed = value.trim().replaceAll('_', ' ');
  if (trimmed.isEmpty) return 'Service';

  return trimmed
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => part.length == 1
            ? part.toUpperCase()
            : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}
