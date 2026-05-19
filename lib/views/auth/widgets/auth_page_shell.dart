import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/views/shared/welcome_theme.dart';

class AuthPageShell extends StatelessWidget {
  const AuthPageShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.busy,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool busy;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: welcomeBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: welcomeBackgroundColor),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            if (onBack != null)
                              IconButton(
                                onPressed: onBack,
                                icon: const Icon(Icons.arrow_back_rounded),
                                color: welcomeTextColor,
                              )
                            else
                              const SizedBox(width: 48),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: welcomeTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: welcomeTextColor.withValues(alpha: 0.76),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            color: welcomeSurfaceColor,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: welcomePrimaryDeepColor.withValues(
                                alpha: 0.10,
                              ),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x11000000),
                                blurRadius: 24,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(18),
                          child: child,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (busy)
            Container(
              color: Colors.black.withValues(alpha: 0.16),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 54,
                height: 54,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
