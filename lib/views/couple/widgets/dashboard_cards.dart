import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/core/services/app_session_cache.dart';
import 'package:wedplan_mobile/models/couple/couple_dashboard.dart';
import 'package:wedplan_mobile/viewmodels/couple/couple_dashboard_view_model.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.vm});

  final CoupleDashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final dashboard = vm.dashboard;
    final completion = _taskProgressPercent(dashboard);
    final session = AppSessionCache.instance;
    final coupleName = dashboard?.coupleDisplayName.trim().isNotEmpty == true
        ? dashboard!.coupleDisplayName
        : session.coupleDisplayName;
    final fallbackName = session.userDetail == null
        ? ''
        : _fallbackWelcomeName(session.userDetail!);
    final resolvedName = coupleName.isNotEmpty ? coupleName : fallbackName;
    final welcomeLabel = coupleName.isNotEmpty
        ? 'Welcome Back, $coupleName'
        : resolvedName.isNotEmpty
        ? 'Welcome Back, $resolvedName'
        : 'Welcome Back';
    final title = dashboard?.weddingDateLabel.isNotEmpty == true
        ? dashboard!.weddingDateLabel
        : 'Wedding Dashboard';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    welcomeLabel,
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE04F6D),
                    ),
                  ),
                  // Venue/time removed from header — keep date only
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ProgressRing(percent: completion),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Your wedding journey is already moving. Keep the key milestones in one place.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6F6468),
          ),
        ),
        const SizedBox(height: 14),
        _CountdownCard(vm: vm),
      ],
    );
  }
}

String _fallbackWelcomeName(Map<String, dynamic> userDetail) {
  final displayName = _string(userDetail['display_name']);
  if (displayName.isNotEmpty) return displayName;

  final email = _string(userDetail['email']);
  if (email.contains('@')) {
    return email.split('@').first;
  }

  return '';
}

class _CountdownCard extends StatefulWidget {
  const _CountdownCard({required this.vm});

  final CoupleDashboardViewModel vm;

  @override
  State<_CountdownCard> createState() => _CountdownCardState();
}

class _CountdownCardState extends State<_CountdownCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetDate = widget.vm.dashboard?.weddingDateOnly;
    final now = DateTime.now();
    final target = targetDate ?? now;
    final diff = target.difference(now);
    final totalSeconds = diff.inSeconds > 0 ? diff.inSeconds : 0;
    final days = totalSeconds ~/ (24 * 60 * 60);
    final hours = (totalSeconds ~/ (60 * 60)) % 24;
    final minutes = (totalSeconds ~/ 60) % 60;
    final seconds = totalSeconds % 60;
    final weddingDateLabel =
        widget.vm.dashboard?.weddingDateLabel.isNotEmpty == true
        ? widget.vm.dashboard!.weddingDateLabel
        : 'Wedding date not set';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB0C3), Color(0xFFF48AA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE04F6D).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Countdown To Your Special Day',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2A1E22),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weddingDateLabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2A1E22),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeBox(value: days.toString(), label: 'Days'),
              _TimeBox(value: hours.toString().padLeft(2, '0'), label: 'Hours'),
              _TimeBox(
                value: minutes.toString().padLeft(2, '0'),
                label: 'Minutes',
              ),
              _TimeBox(
                value: seconds.toString().padLeft(2, '0'),
                label: 'Seconds',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF2B3C0)),
          ),
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A1E22),
          ),
        ),
      ],
    );
  }
}

class DashboardStatGrid extends StatelessWidget {
  const DashboardStatGrid({
    super.key,
    required this.vm,
    required this.onTapBudget,
    required this.onTapGuests,
    required this.onTapTasks,
    required this.onTapVendors,
    required this.onTapTaskList,
  });

  final CoupleDashboardViewModel vm;
  final VoidCallback onTapBudget;
  final VoidCallback onTapGuests;
  final VoidCallback onTapTasks;
  final VoidCallback onTapVendors;
  final VoidCallback onTapTaskList;

  @override
  Widget build(BuildContext context) {
    final dashboard = vm.dashboard;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Budget',
                value: dashboard != null
                    ? 'RM ${_money(dashboard.totalBudget)}'
                    : '--',
                subtitle: dashboard != null
                    ? 'RM ${_money(dashboard.remainingBudget)} remaining'
                    : '',
                icon: Icons.account_balance_wallet_rounded,
                accent: const Color(0xFFF4708A),
                color: const Color(0xFFFCE0E5),
                onTap: onTapBudget,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Guest',
                value: dashboard != null
                    ? '${dashboard.confirmedGuests}/${dashboard.guestCount}'
                    : '--',
                subtitle: dashboard != null ? 'Guests confirmed' : '',
                icon: Icons.group_rounded,
                accent: const Color(0xFFE04F6D),
                color: const Color(0xFFFFF3F5),
                onTap: onTapGuests,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Tasklist',
                value: dashboard != null
                    ? '${dashboard.completedTasks}/${dashboard.totalTasks}'
                    : '--',
                subtitle: dashboard != null
                    ? '${_taskProgressPercent(dashboard).toStringAsFixed(0)}% complete'
                    : '',
                icon: Icons.checklist_rounded,
                accent: const Color(0xFFE04F6D),
                color: const Color(0xFFFFF2F5),
                onTap: onTapTasks,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Vendor',
                value: dashboard != null
                    ? '${dashboard.vendorsBooked}/${dashboard.pendingVendors}'
                    : '--',
                subtitle: dashboard != null ? 'Booked / Pending' : '',
                icon: Icons.storefront_rounded,
                accent: const Color(0xFFF4708A),
                color: const Color(0xFFFFF8F9),
                onTap: onTapVendors,
              ),
            ),
          ],
        ),
        if (dashboard != null) ...[
          const SizedBox(height: 12),
          _JourneyStrip(progress: _taskProgressRatio(dashboard)),
          const SizedBox(height: 12),
          _UpcomingTaskCard(
            tasks: dashboard.upcomingTasks,
            onTap: onTapTaskList,
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.subtitle = '',
    this.color = Colors.white,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: accent.withValues(alpha: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A3B40),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 6,
            backgroundColor: const Color(0xFFF5D8DF),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE04F6D)),
          ),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyStrip extends StatelessWidget {
  const _JourneyStrip({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Journey progress',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE04F6D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: const Color(0xFFF1DDE2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE04F6D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTaskCard extends StatelessWidget {
  const _UpcomingTaskCard({required this.tasks, required this.onTap});

  final List<Map<String, dynamic>> tasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final task = tasks.isNotEmpty ? tasks.first : null;
    final title = task != null ? _string(task['title']) : 'No upcoming task';
    final dueDate = task != null
        ? _string(task['due_date'])
        : 'Add one from Tasklist';

    return Material(
      color: const Color(0xFFFFF7F9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: Color(0xFFE04F6D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming task',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dueDate,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: const Color(0xFF6F6468),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

String _string(dynamic value) {
  if (value == null) return '';
  final s = value is String ? value.trim() : value.toString();
  if (s.isEmpty) return '';

  // Sanitize known server error/class traces that may be returned by some endpoints
  // e.g. "App\\HTTP\\Controllers\\API\\Setting\\UserResource" or exception dumps.
  final classPattern = RegExp(r'App\\.*Controllers', caseSensitive: false);
  final junkPattern = RegExp(
    r'exception|illuminate\\|app\\http|userresource',
    caseSensitive: false,
  );
  if (classPattern.hasMatch(s) || junkPattern.hasMatch(s)) return '';

  return s;
}

String _money(double value) => value.toStringAsFixed(2);

double _taskProgressPercent(CoupleDashboard? dashboard) {
  return _taskProgressRatio(dashboard) * 100;
}

double _taskProgressRatio(CoupleDashboard? dashboard) {
  if (dashboard == null || dashboard.totalTasks <= 0) return 0;
  return (dashboard.completedTasks / dashboard.totalTasks).clamp(0.0, 1.0);
}

String _weddingMetaLabel(CoupleDashboard? dashboard) {
  if (dashboard == null) return '';

  final parts = <String>[];
  final venue = dashboard.weddingVenue.trim();
  final time = dashboard.weddingTime.trim();

  if (venue.isNotEmpty) parts.add(venue);
  if (time.isNotEmpty) parts.add(time);

  return parts.join(' • ');
}
