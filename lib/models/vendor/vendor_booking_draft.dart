class VendorBookingDraft {
  const VendorBookingDraft({
    required this.coupleId,
    required this.typeService,
    required this.bookingDate,
    required this.status,
    required this.notes,
  });

  final String coupleId;
  final String typeService;
  final DateTime bookingDate;
  final bool status;
  final String notes;

  Map<String, dynamic> toCreateJson() {
    return <String, dynamic>{
      'couple_id': int.tryParse(coupleId.trim()) ?? coupleId.trim(),
      'type_service': typeService.trim(),
      'booking_date': bookingDate.toIso8601String().split('T').first,
      'status': status,
      'notes': notes.trim(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return <String, dynamic>{
      'booking_date': bookingDate.toIso8601String().split('T').first,
      'status': status,
      'notes': notes.trim(),
    };
  }
}
