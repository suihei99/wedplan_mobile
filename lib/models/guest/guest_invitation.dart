class GuestInvitation {
  GuestInvitation({
    required this.code,
    required this.title,
    required this.coupleName,
    required this.eventName,
    required this.venue,
    required this.message,
    required this.invitationId,
    required this.checkedIn,
    required this.rsvpStatus,
    required this.raw,
  });

  final String code;
  final String title;
  final String coupleName;
  final String eventName;
  final String venue;
  final String message;
  final String invitationId;
  final bool checkedIn;
  final String rsvpStatus;
  final Map<String, dynamic> raw;

  String get guestName => _firstNonEmpty([
    _readString(raw, 'guest_name'),
    _readString(_readMap(raw, ['data']), 'guest_name'),
    _readString(_readMap(raw, ['data', 'guest']), 'guest_name'),
    _readString(_readMap(raw, ['data', 'guest']), 'name'),
    _readString(raw, 'name'),
  ]);

  int? get paxCount => _firstInt([
    _readInt(_readMap(raw, ['data']), [
      'pax_count',
      'pax',
      'guest_count',
      'guest_pax',
    ]),
    _readInt(raw, ['pax_count', 'pax', 'guest_count', 'guest_pax']),
    _readInt(_readMap(raw, ['data', 'guest']), [
      'pax_count',
      'pax',
      'guest_count',
      'guest_pax',
    ]),
  ]);

  String get weddingDate => _firstNonEmpty([
    _readString(_readMap(raw, ['data', 'wedding']), 'date'),
    _readString(raw, 'wedding_date'),
    _readString(_readMap(raw, ['data']), 'wedding_date'),
    _readString(_readMap(raw, ['event', 'wedding']), 'date'),
    _readString(_readMap(raw, ['event', 'wedding']), 'wedding_date'),
  ]);

  String get weddingTime => _firstNonEmpty([
    _readString(_readMap(raw, ['data', 'wedding']), 'time'),
    _readString(raw, 'wedding_time'),
    _readString(_readMap(raw, ['data']), 'wedding_time'),
    _readString(_readMap(raw, ['event', 'wedding']), 'time'),
    _readString(_readMap(raw, ['event', 'wedding']), 'wedding_time'),
  ]);

  factory GuestInvitation.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys, {String fallback = ''}) {
      for (final key in keys) {
        final value = _readString(json, key);
        if (value.isNotEmpty) return value;
      }
      return fallback;
    }

    final data = _readMap(json, ['data']);
    final invitation = _readMap(json, ['data', 'invitation', 'guest']);
    final wedding = _readMap(data, ['wedding']);
    final event = _readMap(json, ['event', 'wedding']);
    final couple = _readMap(json, ['couple', 'host', 'owner']);
    final dataCouple = _readMap(data, ['couple']);

    return GuestInvitation(
      code: _firstNonEmpty([
        pickString(['code', 'qr_code', 'invite_code'], fallback: ''),
        _readString(data, 'invite_code'),
      ]),
      title: _firstNonEmpty([
        pickString(['title', 'event_title', 'name']),
        _readString(data, 'title'),
        _readString(wedding, 'title'),
        _readString(event, 'title'),
        'Guest Invitation',
      ]),
      coupleName: _firstNonEmpty([
        _readString(dataCouple, 'display_name'),
        _firstNonEmpty([
              _readString(dataCouple, 'partner_1_name'),
              _readString(dataCouple, 'partner_2_name'),
            ]).isNotEmpty
            ? '${_readString(dataCouple, 'partner_1_name')} & ${_readString(dataCouple, 'partner_2_name')}'
            : '',
        _readString(couple, 'name'),
        _readString(couple, 'couple_name'),
        _readString(json, 'couple_name'),
      ]),
      eventName: _firstNonEmpty([
        _readString(data, 'event_name'),
        _readString(wedding, 'name'),
        _readString(event, 'name'),
        _readString(event, 'title'),
        _readString(json, 'event_name'),
      ]),
      venue: _firstNonEmpty([
        _readString(wedding, 'venue'),
        _readString(data, 'wedding_venue'),
        _readString(event, 'venue'),
        _readString(event, 'location'),
        _readString(json, 'venue'),
        _readString(json, 'location'),
      ]),
      message: _firstNonEmpty([
        _readString(json, 'message'),
        _readString(invitation, 'message'),
        'You are invited to celebrate with us.',
      ]),
      invitationId: _firstNonEmpty([
        _readString(_readMap(data, ['guest']), 'id'),
        _readString(data, 'id'),
        _readString(data, 'guest_id'),
        _readString(data, 'invitation_id'),
        _readString(invitation, 'id'),
        _readString(json, 'id'),
        _readString(json, 'guest_id'),
        _readString(json, 'invitation_id'),
        _firstNonEmpty([
          pickString(['code', 'qr_code', 'invite_code'], fallback: ''),
          _readString(data, 'invite_code'),
        ]),
      ]),
      checkedIn:
          _readBool(json, [
            'checked_in',
            'check_in',
            'is_checked_in',
            'has_checked_in',
          ]) ||
          _readBool(invitation, [
            'checked_in',
            'check_in',
            'is_checked_in',
            'has_checked_in',
          ]),
      rsvpStatus: _firstNonEmpty([
        _readString(json, 'rsvp_status'),
        _readString(json, 'rsvp'),
        _readString(invitation, 'rsvp_status'),
        _readString(invitation, 'rsvp'),
      ]),
      raw: json,
    );
  }

  GuestInvitation copyWith({
    String? code,
    String? title,
    String? coupleName,
    String? eventName,
    String? venue,
    String? message,
    String? invitationId,
    bool? checkedIn,
    String? rsvpStatus,
    Map<String, dynamic>? raw,
  }) {
    return GuestInvitation(
      code: code ?? this.code,
      title: title ?? this.title,
      coupleName: coupleName ?? this.coupleName,
      eventName: eventName ?? this.eventName,
      venue: venue ?? this.venue,
      message: message ?? this.message,
      invitationId: invitationId ?? this.invitationId,
      checkedIn: checkedIn ?? this.checkedIn,
      rsvpStatus: rsvpStatus ?? this.rsvpStatus,
      raw: raw ?? this.raw,
    );
  }

  bool get isRejected =>
      rsvpStatus.toLowerCase() == 'rejected' ||
      rsvpStatus.toLowerCase() == 'declined';
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

Map<String, dynamic> _readMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    }
  }
  return <String, dynamic>{};
}

bool _readBool(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
    }
    if (value is num) return value != 0;
  }
  return false;
}

int? _firstInt(List<int?> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
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
