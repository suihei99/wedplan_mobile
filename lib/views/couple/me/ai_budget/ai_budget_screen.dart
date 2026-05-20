import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/viewmodels/couple/me_view_model.dart';

class AiBudgetScreen extends StatefulWidget {
  const AiBudgetScreen({super.key});

  @override
  State<AiBudgetScreen> createState() => _AiBudgetScreenState();
}

class _AiBudgetScreenState extends State<AiBudgetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  bool _initialized = false;
  bool _generated = false;
  String _selectedBudgetRange = 'Not sure yet';

  @override
  void dispose() {
    _guestCountController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final profile = context.read<MeViewModel>().profile;
    _guestCountController.text = (profile?.guestCount ?? 0) > 0
      ? profile!.guestCount.toString()
      : '100';
    _selectedBudgetRange = _budgetRangeFromProfile(profile) ?? 'Not sure yet';
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<MeViewModel>().profile;

    if (profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF4F5),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final estimate = _calculateEstimate(profile);
    final breakdown = _buildBreakdown(estimate);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF4F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF4F5),
        foregroundColor: const Color(0xFF21161A),
        elevation: 0,
        title: Text(
          'AI Estimate Budget',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkResponse(
              onTap: _resetToProfile,
              radius: 22,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFEFDCE0)),
                ),
                child: const Icon(Icons.refresh_rounded, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AssistantHero(profile: profile),
                          const SizedBox(height: 14),
                          _PromptCard(onQuickTap: _setQuickGuestCount),
                          const SizedBox(height: 14),
                          _InputCard(
                            guestCountController: _guestCountController,
                            selectedBudgetRange: _selectedBudgetRange,
                            onBudgetRangeSelected: (value) {
                              setState(() {
                                _selectedBudgetRange = value;
                                _generated = false;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          _GenerateButton(onPressed: _generateEstimate),
                          const SizedBox(height: 14),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _generated
                                ? _ResultCard(
                                    estimate: estimate,
                                    breakdown: breakdown,
                                    guestCount: _parseGuestCount(),
                                    budgetRange: _selectedBudgetRange,
                                    profile: profile,
                                  )
                                : _PlaceholderCard(profile: profile),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAF4F5),
                    border: Border(top: BorderSide(color: Color(0xFFF0DDE1))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _followUpController,
                          decoration: InputDecoration(
                            hintText:
                                'Ask about savings, categories, or next steps...',
                            hintStyle: GoogleFonts.manrope(
                              color: const Color(0xFF9A8B91),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFF0DDE1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFF0DDE1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xFFE04F6D),
                                width: 1.4,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _sendFollowUp(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 54,
                        width: 54,
                        child: FilledButton(
                          onPressed: () => _sendFollowUp(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFE04F6D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.send_rounded),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _setQuickGuestCount(int value) {
    setState(() {
      _guestCountController.text = value.toString();
      _generated = false;
    });
  }

  void _generateEstimate() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _generated = true;
    });
  }

  void _sendFollowUp(BuildContext context) {
    final message = _followUpController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a budget question first.')),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Follow-up noted: $message')));
    setState(() {
      _generated = true;
    });
  }

  void _resetToProfile() {
    final profile = context.read<MeViewModel>().profile;
    setState(() {
      _guestCountController.text = (profile?.guestCount ?? 0) > 0
          ? profile!.guestCount.toString()
          : '100';
      _selectedBudgetRange = _budgetRangeFromProfile(profile) ?? 'Not sure yet';
      _generated = false;
      _followUpController.clear();
    });
  }

  int _parseGuestCount() {
    final value = int.tryParse(_guestCountController.text.trim());
    if (value != null && value > 0) return value;
    return 100;
  }

  String? _budgetRangeFromProfile(CoupleMeProfile? profile) {
    final budget = profile?.totalBudgetLimit ?? 0;
    if (budget >= 50000) return 'RM 50,000+';
    if (budget >= 25000) return 'RM 25,000 - RM 40,000';
    if (budget > 0) return 'RM 10,000 - RM 20,000';
    return null;
  }

  double _calculateEstimate(CoupleMeProfile profile) {
    final guestCount = _parseGuestCount();
    final guestEstimate = _estimateFromGuests(guestCount);
    double rangeEstimate;
    if (_selectedBudgetRange == 'RM 10,000 - RM 20,000') {
      rangeEstimate = 15000;
    } else if (_selectedBudgetRange == 'RM 25,000 - RM 40,000') {
      rangeEstimate = 35000;
    } else if (_selectedBudgetRange == 'RM 50,000+') {
      rangeEstimate = 50000;
    } else {
      rangeEstimate = 0;
    }
    final double profileBudget = profile.totalBudgetLimit > 0
      ? profile.totalBudgetLimit
      : 0.0;

    final combined = <double>[
      guestEstimate,
      rangeEstimate,
      profileBudget,
    ].where((value) => value > 0).reduce(math.max);

    return _roundToNearest500(combined);
  }

  double _estimateFromGuests(int guestCount) {
    if (guestCount <= 0) return 0;
    if (guestCount <= 80) return 25000;
    if (guestCount <= 120) return 35000;
    if (guestCount <= 180) return 50000;
    if (guestCount <= 250) return 65000;
    return 80000;
  }

  double _roundToNearest500(double value) {
    if (value <= 0) return 0;
    return (value / 500).roundToDouble() * 500;
  }

  List<_BreakdownItem> _buildBreakdown(double estimate) {
    if (estimate <= 0) return const <_BreakdownItem>[];

    return [
      _BreakdownItem('Venue', estimate * 0.30, Icons.location_on_rounded),
      _BreakdownItem('Catering', estimate * 0.35, Icons.restaurant_rounded),
      _BreakdownItem('Decor', estimate * 0.10, Icons.celebration_rounded),
      _BreakdownItem(
        'Photo & video',
        estimate * 0.10,
        Icons.camera_alt_rounded,
      ),
      _BreakdownItem('Music', estimate * 0.05, Icons.music_note_rounded),
      _BreakdownItem(
        'Contingency',
        estimate * 0.10,
        Icons.safety_check_rounded,
      ),
    ];
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero({required this.profile});

  final CoupleMeProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF4708A), Color(0xFFE04F6D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Budget Assistant',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEFF2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Online and ready',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFE04F6D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.displayName.isNotEmpty
                      ? profile.displayName
                      : 'Your wedding budget bot',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    color: const Color(0xFF6F6468),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.onQuickTap});

  final ValueChanged<int> onQuickTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Hi, I’m your wedding budget bot.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE04F6D),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tell me your guest count and budget range, and I’ll calculate a helpful estimate.',
            style: GoogleFonts.manrope(
              fontSize: 13,
              height: 1.4,
              color: const Color(0xFF4E4045),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickChip(label: '120 guests', onTap: () => onQuickTap(120)),
              _QuickChip(label: '200 guests', onTap: () => onQuickTap(200)),
              _QuickChip(label: '300 guests', onTap: () => onQuickTap(300)),
              _QuickChip(label: 'Not sure yet', onTap: () => onQuickTap(100)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.guestCountController,
    required this.selectedBudgetRange,
    required this.onBudgetRangeSelected,
  });

  final TextEditingController guestCountController;
  final String selectedBudgetRange;
  final ValueChanged<String> onBudgetRangeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guest count',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: guestCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'e.g., 150',
              hintStyle: GoogleFonts.manrope(
                color: const Color(0xFF9A8B91),
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFFFFBFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFF0DDE1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFFE04F6D),
                  width: 1.4,
                ),
              ),
            ),
            validator: (value) {
              final parsed = int.tryParse((value ?? '').trim());
              if (parsed == null || parsed <= 0) {
                return 'Enter a valid guest count';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Budget range',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: [
              _BudgetRangeTile(
                label: 'RM 10,000 - RM 20,000',
                selected: selectedBudgetRange == 'RM 10,000 - RM 20,000',
                onTap: () => onBudgetRangeSelected('RM 10,000 - RM 20,000'),
              ),
              _BudgetRangeTile(
                label: 'RM 25,000 - RM 40,000',
                selected: selectedBudgetRange == 'RM 25,000 - RM 40,000',
                onTap: () => onBudgetRangeSelected('RM 25,000 - RM 40,000'),
              ),
              _BudgetRangeTile(
                label: 'RM 50,000+',
                selected: selectedBudgetRange == 'RM 50,000+',
                onTap: () => onBudgetRangeSelected('RM 50,000+'),
              ),
              _BudgetRangeTile(
                label: 'Not sure yet',
                selected: selectedBudgetRange == 'Not sure yet',
                onTap: () => onBudgetRangeSelected('Not sure yet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF6F6468),
            ),
          ),
          const Spacer(),
          Text(
            value,
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

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFE04F6D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'Get My Budget Estimate',
          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({required this.profile});

  final CoupleMeProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('placeholder'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated wedding budget',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your estimate will appear here after you tap the pink button.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 12),
          _MetaLine(label: 'Couple', value: profile.displayName),
          _MetaLine(
            label: 'Current budget',
            value: 'RM ${profile.totalBudgetLimit.toStringAsFixed(0)}',
          ),
          _MetaLine(
            label: 'Guest count',
            value: profile.guestCount > 0 ? profile.guestCount.toString() : '-',
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.estimate,
    required this.breakdown,
    required this.guestCount,
    required this.budgetRange,
    required this.profile,
  });

  final double estimate;
  final List<_BreakdownItem> breakdown;
  final int guestCount;
  final String budgetRange;
  final CoupleMeProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF0DDE1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estimated wedding budget',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Guest count: $guestCount',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF6F6468),
            ),
          ),
          Text(
            'Budget range: $budgetRange',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF6F6468),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${estimate.toStringAsFixed(0)}',
            style: GoogleFonts.manrope(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFE04F6D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Recommended total budget for ${profile.displayName.isNotEmpty ? profile.displayName : 'your couple'}.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFF4E4045),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF4E4E8)),
            ),
            child: Column(
              children: breakdown
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEFF2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              size: 18,
                              color: const Color(0xFFE04F6D),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            'RM ${item.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF21161A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: Keep a small buffer for last-minute costs and extra guests.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF6F6468),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem(this.label, this.amount, this.icon);

  final String label;
  final double amount;
  final IconData icon;
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFE04F6D),
        side: const BorderSide(color: Color(0xFFF2B8BF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _BudgetRangeTile extends StatelessWidget {
  const _BudgetRangeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFEFF2) : const Color(0xFFFFFBFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFFE04F6D)
                  : const Color(0xFFF0DDE1),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected
                    ? const Color(0xFFE04F6D)
                    : const Color(0xFF21161A),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
