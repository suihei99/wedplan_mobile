class AppSessionCache {
  AppSessionCache._();

  static final AppSessionCache instance = AppSessionCache._();

  Map<String, dynamic>? _dashboard;
  Map<String, dynamic>? _userDetail;
  Map<String, dynamic>? _coupleDetail;

  Map<String, dynamic>? get dashboard => _dashboard;
  Map<String, dynamic>? get userDetail => _userDetail;
  Map<String, dynamic>? get coupleDetail => _coupleDetail;

  String get coupleDisplayName => _displayNameFrom(_coupleDetail, _userDetail);
  String get partner1Name => _partnerNameFrom('partner_1_name');
  String get partner2Name => _partnerNameFrom('partner_2_name');

  set dashboard(Map<String, dynamic>? value) {
    _dashboard = _unwrapData(value);
  }

  set userDetail(Map<String, dynamic>? value) {
    _userDetail = _unwrapData(value);
  }

  set coupleDetail(Map<String, dynamic>? value) {
    _coupleDetail = _unwrapData(value);
  }

  void seedFromAuthResponse(dynamic payload) {
    final normalized = _toMap(payload);
    final data = _readMap(normalized, ['data']);

    var user = _readMap(normalized, ['user']);

    if (user.isEmpty && data.isNotEmpty) {
      user = _readMap(data, ['user']);
      if (user.isEmpty && _looksLikeProfile(data)) {
        user = data;
      }
    }

    var couple = _readMap(user, ['couple']);
    var vendor = _readMap(user, ['vendor']);

    if (couple.isEmpty && vendor.isEmpty) {
      couple = _readMap(normalized, ['couple']);
      vendor = _readMap(normalized, ['vendor']);
    }

    if (user.isNotEmpty) {
      _userDetail = _unwrapData(user);
    }

    if (couple.isNotEmpty) {
      _coupleDetail = _unwrapData(couple);
    } else if (vendor.isNotEmpty) {
      _coupleDetail = _unwrapData(vendor);
    }
  }

  void clear() {
    _dashboard = null;
    _userDetail = null;
    _coupleDetail = null;
  }

  String _displayNameFrom(
    Map<String, dynamic>? couple,
    Map<String, dynamic>? user,
  ) {
    final coupleFromNestedData = _unwrapData(couple);
    final userFromNestedData = _unwrapData(user);

    final coupleDisplayName = _readString(coupleFromNestedData, 'display_name');
    if (coupleDisplayName.isNotEmpty) return coupleDisplayName;

    final partner1 = _partnerNameFrom('partner_1_name');
    final partner2 = _partnerNameFrom('partner_2_name');
    if (partner1.isNotEmpty && partner2.isNotEmpty) {
      return '$partner1 & $partner2';
    }

    final userDisplayName = _readString(userFromNestedData, 'display_name');
    if (userDisplayName.isNotEmpty) return userDisplayName;

    final email = _readString(userFromNestedData, 'email');
    if (email.isNotEmpty && email.contains('@')) {
      return email.split('@').first;
    }

    return '';
  }

  String _partnerNameFrom(String key) {
    final couple = _unwrapData(_coupleDetail);
    final user = _unwrapData(_userDetail);

    final coupleValue = _readString(couple, key);
    if (coupleValue.isNotEmpty) return coupleValue;

    final nestedCouple = _readMap(user ?? <String, dynamic>{}, ['couple']);
    final userValue = _readString(nestedCouple, key);
    if (userValue.isNotEmpty) return userValue;

    return _readString(user, key);
  }

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _readMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      }
    }
    return <String, dynamic>{};
  }

  String _readString(Map<String, dynamic>? source, String key) {
    if (source == null) return '';
    final value = source[key];
    if (value is String) return value.trim();
    if (value != null) return value.toString().trim();
    return '';
  }

  Map<String, dynamic>? _unwrapData(Map<String, dynamic>? source) {
    if (source == null || source.isEmpty) return source;
    final data = source['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
    return source;
  }

  bool _looksLikeProfile(Map<String, dynamic> data) {
    return data.containsKey('email') ||
        data.containsKey('role') ||
        data.containsKey('profile_photo_path') ||
        data.containsKey('is_active');
  }
}
