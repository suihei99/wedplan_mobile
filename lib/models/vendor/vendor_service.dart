import 'package:wedplan_mobile/core/router/app_router.dart';

class VendorService {
  VendorService({
    required this.id,
    required this.serviceName,
    required this.typeService,
    required this.priceEstimate,
    required this.description,
    required this.imageUrl,
    required this.raw,
  });

  final dynamic id;
  final String serviceName;
  final String typeService;
  final double priceEstimate;
  final String description;
  final String imageUrl;
  final Map<String, dynamic> raw;

  bool get hasImage => imageUrl.trim().isNotEmpty;

  String get serviceTypeLabel => _titleCase(typeService);

  String get priceLabel => 'RM ${priceEstimate.toStringAsFixed(2)}';

  String get descriptionLabel => description.trim().isNotEmpty
      ? description.trim()
      : 'No description provided by the vendor yet.';

  String get resolvedImageUrl => _resolveImageUrl(imageUrl);

  factory VendorService.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    return VendorService(
      id: data['id'] ?? data['service_id'],
      serviceName: _firstString([
        data['service_name'],
        data['name'],
        data['title'],
      ], fallback: 'Service'),
      typeService: _firstString([
        data['type_service'],
        data['service_type'],
        data['category'],
      ]),
      priceEstimate: _firstDouble([
        data['price_estimate'],
        data['price'],
        data['starting_price'],
      ]),
      description: _firstString([
        data['description'],
        data['summary'],
        data['details'],
      ]),
      imageUrl: _firstString([
        data['image_url'],
        data['image'],
        data['photo_url'],
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
