class Guest {
  Guest({
    required this.id,
    required this.name,
    required this.phone,
    required this.paxCount,
    required this.rsvpStatus,
    required this.inviteCode,
    required this.qrCodeString,
    required this.checkedInAt,
    required this.createdAt,
    required this.updatedAt,
    required this.raw,
  });

  final String id;
  final String name;
  final String phone;
  final int paxCount;
  final String rsvpStatus;
  final String inviteCode;
  final String qrCodeString;
  final String checkedInAt;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> raw;

  bool get checkedIn => checkedInAt.isNotEmpty;

  bool get isConfirmed => rsvpStatus.toLowerCase() == 'confirmed';

  bool get isDeclined => rsvpStatus.toLowerCase() == 'declined';

  bool get isPending => rsvpStatus.toLowerCase() == 'pending';

  factory Guest.fromJson(Map<String, dynamic> json) {
    final source = _readMap(json, ['data', 'guest'])..addAll(json);

    return Guest(
      id: _readString(source, 'id'),
      name: _firstNonEmpty([
        _readString(source, 'name'),
        _readString(source, 'guest_name'),
      ]),
      phone: _readString(source, 'phone'),
      paxCount: _readInt(source, ['pax_count', 'pax', 'guest_count']) ?? 0,
      rsvpStatus: _firstNonEmpty([
        _readString(source, 'rsvp_status'),
        _readString(source, 'rsvp'),
      ]),
      inviteCode: _firstNonEmpty([
        _readString(source, 'invite_code'),
        _readString(source, 'code'),
      ]),
      qrCodeString: _firstNonEmpty([
        _readString(source, 'qr_code_string'),
        _readString(source, 'qr_code'),
      ]),
      checkedInAt: _firstNonEmpty([
        _readString(source, 'checked_in_at'),
        _readString(source, 'checkin_at'),
      ]),
      createdAt: _readString(source, 'created_at'),
      updatedAt: _readString(source, 'updated_at'),
      raw: source,
    );
  }

  String get coupleName => _firstNonEmpty([
    _readString(_readMap(raw, ['data', 'couple']), 'display_name'),
    _readString(_readMap(raw, ['data', 'couple']), 'couple_name'),
    _readString(_readMap(raw, ['couple', 'host', 'owner']), 'display_name'),
    _readString(_readMap(raw, ['couple', 'host', 'owner']), 'couple_name'),
    _readString(raw, 'couple_name'),
  ]);

  String get qrImageUrl => _firstNonEmpty([
    _readString(raw, 'qr_image_url'),
    _readString(_readMap(raw, ['data']), 'qr_image_url'),
  ]);

  Guest copyWith({
    String? id,
    String? name,
    String? phone,
    int? paxCount,
    String? rsvpStatus,
    String? inviteCode,
    String? qrCodeString,
    String? checkedInAt,
    String? createdAt,
    String? updatedAt,
    Map<String, dynamic>? raw,
  }) {
    return Guest(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      paxCount: paxCount ?? this.paxCount,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      inviteCode: inviteCode ?? this.inviteCode,
      qrCodeString: qrCodeString ?? this.qrCodeString,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      raw: raw ?? this.raw,
    );
  }
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value;
  }
  return '';
}

String _readString(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is String) return value.trim();
  if (value != null) return value.toString().trim();
  return '';
}

int? _readInt(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

Map<String, dynamic> _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Map) {
      return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
  }
  return <String, dynamic>{};
}
