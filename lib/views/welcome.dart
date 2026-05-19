import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/auth/login.dart';
import 'package:wedplan_mobile/views/auth/register/couple_register.dart';
import 'package:wedplan_mobile/views/auth/register/vendor_register.dart';
import 'package:wedplan_mobile/views/guest/guest_invitation_screen.dart';
import 'package:wedplan_mobile/views/shared/welcome/action_buttons.dart';
import 'package:wedplan_mobile/views/shared/welcome/background_decor.dart';
import 'package:wedplan_mobile/views/shared/welcome/brand_mark.dart';
import 'package:wedplan_mobile/views/shared/welcome/feature_slide.dart';
import 'package:wedplan_mobile/views/shared/welcome/hero_card.dart';
import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _animationController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  final List<WelcomeFeatureSlide> _slides = const <WelcomeFeatureSlide>[
    WelcomeFeatureSlide(
      subtitle: 'Welcome To WedPlan',
      title: 'Plan every detail in one place',
      description:
          'Stay on top of budget, guests, tasks, and vendors with a calm, mobile-first flow.',
      icon: Icons.event_note_rounded,
    ),
    WelcomeFeatureSlide(
      title: 'Couple and vendor journeys',
      description:
          'Choose the path that matches your role and get the right experience from the start.',
      icon: Icons.favorite_rounded,
    ),
    WelcomeFeatureSlide(
      title: 'Fast registration with API sync',
      description:
          'The welcome actions talk directly to the auth endpoints so onboarding stays connected.',
      icon: Icons.api_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients || _slides.length < 2) {
        return;
      }

      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      body: Stack(
        children: [
          const WelcomeBackgroundDecor(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: SizedBox(
                    height:
                        size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        24,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 4),
                                Center(
                                  child: Column(
                                    children: [
                                      WelcomeBrandMark(
                                        primary: welcomePrimaryColor,
                                        primaryDeep: welcomePrimaryDeepColor,
                                        textColor: welcomeTextColor,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Forever memories, beautifully planned.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.manrope(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: welcomeTextColor.withValues(
                                            alpha: 0.76,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: size.height * 0.39,
                                  child: WelcomeHeroCard(
                                    primary: welcomePrimaryColor,
                                    primaryDeep: welcomePrimaryDeepColor,
                                    pageController: _pageController,
                                    slides: _slides,
                                    onPageChanged: (index) {
                                      setState(() => _currentPage = index);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List<Widget>.generate(
                                    _slides.length,
                                    (index) {
                                      final selected = index == _currentPage;
                                      return GestureDetector(
                                        onTap: () =>
                                            _pageController.animateToPage(
                                              index,
                                              duration: const Duration(
                                                milliseconds: 350,
                                              ),
                                              curve: Curves.easeOutCubic,
                                            ),
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 250,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: selected ? 18 : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? welcomePrimaryDeepColor
                                                : welcomePrimaryColor
                                                      .withValues(alpha: 0.25),
                                            borderRadius: BorderRadius.circular(
                                              99,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                WelcomeRegisterButtons(
                                  primaryDeep: welcomePrimaryDeepColor,
                                  onCouple: _openCoupleRegister,
                                  onVendor: _openVendorRegister,
                                  busy: false,
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: TextButton(
                                    onPressed: _openLogin,
                                    child: Text(
                                      'Already have an account? Login',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: welcomePrimaryDeepColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                WelcomeGuestInviteCard(
                                  onPressed: _openGuestInvitation,
                                  busy: false,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openGuestInvitation() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuestInvitationScreen()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  void _openCoupleRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CoupleRegisterScreen()));
  }

  void _openVendorRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const VendorRegisterScreen()));
  }
}
