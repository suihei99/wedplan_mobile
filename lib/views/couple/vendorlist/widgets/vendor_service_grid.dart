import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wedplan_mobile/models/vendor/vendor_service.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class VendorServiceGrid extends StatelessWidget {
  const VendorServiceGrid({
    super.key,
    required this.services,
    required this.onOpenService,
  });

  final List<VendorService> services;
  final void Function(VendorService service) onOpenService;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 268,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return _VendorServiceCard(
          service: service,
          onTap: () => onOpenService(service),
        );
      },
    );
  }
}

class _VendorServiceCard extends StatelessWidget {
  const _VendorServiceCard({required this.service, required this.onTap});

  final VendorService service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE7D8DD)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB96B7D).withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  service.hasImage
                      ? CachedNetworkImage(
                          imageUrl: service.resolvedImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF9EEF1),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _fallbackImage(),
                        )
                      : _fallbackImage(),
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE54D6B), Color(0xFFF08A4B)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.luggage_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              service.serviceTypeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.serviceName,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.vendorBusinessName.isNotEmpty
                          ? service.vendorBusinessName
                          : 'Vendor business name unavailable',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: welcomePrimaryDeepColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.priceLabel,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: welcomePrimaryDeepColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (service.vendorAddress.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: Color(0xFFE54D6B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              service.vendorAddress,
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF7C6B71),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(height: 14),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: Container()),
                        const SizedBox(width: 8),
                        _WhatsAppMiniButton(
                          phoneNumber: service.vendorContactNumber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: const Color(0xFFF9EEF1),
      alignment: Alignment.center,
      child: const Icon(
        Icons.storefront_rounded,
        color: welcomePrimaryDeepColor,
        size: 36,
      ),
    );
  }
}

class _WhatsAppMiniButton extends StatelessWidget {
  const _WhatsAppMiniButton({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    final hasPhone = phoneNumber.trim().isNotEmpty;

    return SizedBox(
      height: 32,
      child: FilledButton(
        onPressed: hasPhone
            ? () async {
                final phone = _normalizeWhatsAppPhone(phoneNumber);
                if (phone.isEmpty) return;

                final uri = Uri.parse(
                  'https://api.whatsapp.com/send?phone=$phone',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE54D6B),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'WhatsApp',
          style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

String _normalizeWhatsAppPhone(String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.isEmpty) return '';

  if (digits.startsWith('+')) {
    return digits.substring(1);
  }

  if (digits.startsWith('0')) {
    return '60${digits.substring(1)}';
  }

  return digits;
}
