import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:wedplan_mobile/models/couple/ai_budget_model.dart';
import 'package:wedplan_mobile/models/couple/me_profile.dart';
import 'package:wedplan_mobile/viewmodels/couple/ai_budget_view_model.dart';

class AiBudgetScreenContent extends StatelessWidget {
  const AiBudgetScreenContent({
    super.key,
    required this.profile,
    required this.viewModel,
    required this.guestCountController,
    required this.formKey,
    required this.onQuickTap,
    required this.onBudgetRangeSelected,
    required this.onGenerate,
    required this.onReset,
  });

  final CoupleMeProfile profile;
  final AiBudgetViewModel viewModel;
  final TextEditingController guestCountController;
  final GlobalKey<FormState> formKey;
  final ValueChanged<int> onQuickTap;
  final ValueChanged<String> onBudgetRangeSelected;
  final VoidCallback onGenerate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final guestCount = _parseGuestCount(guestCountController.text);
    final estimate = viewModel.buildEstimate(
      profile: profile,
      guestCount: guestCount,
    );

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
              onTap: onReset,
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AiBudgetAssistantHero(profile: profile),
                      const SizedBox(height: 14),
                      AiBudgetPromptCard(onQuickTap: onQuickTap),
                      const SizedBox(height: 14),
                      AiBudgetInputCard(
                        guestCountController: guestCountController,
                        selectedBudgetRange: viewModel.selectedBudgetRange,
                        onBudgetRangeSelected: onBudgetRangeSelected,
                      ),
                      const SizedBox(height: 14),
                      AiBudgetGenerateButton(onPressed: onGenerate),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: viewModel.generated
                            ? AiBudgetResultCard(
                                estimate: estimate,
                                guestCount: guestCount,
                                budgetRange: viewModel.selectedBudgetRange,
                                profile: profile,
                              )
                            : AiBudgetPlaceholderCard(profile: profile),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _parseGuestCount(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed != null && parsed > 0) return parsed;
    return 100;
  }
}

class AiBudgetAssistantHero extends StatelessWidget {
  const AiBudgetAssistantHero({super.key, required this.profile});

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

class AiBudgetPromptCard extends StatelessWidget {
  const AiBudgetPromptCard({super.key, required this.onQuickTap});

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
              AiBudgetQuickChip(
                label: '120 guests',
                onTap: () => onQuickTap(120),
              ),
              AiBudgetQuickChip(
                label: '200 guests',
                onTap: () => onQuickTap(200),
              ),
              AiBudgetQuickChip(
                label: '300 guests',
                onTap: () => onQuickTap(300),
              ),
              AiBudgetQuickChip(
                label: 'Not sure yet',
                onTap: () => onQuickTap(100),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AiBudgetInputCard extends StatelessWidget {
  const AiBudgetInputCard({
    super.key,
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
              AiBudgetBudgetRangeTile(
                label: 'RM 10,000 - RM 20,000',
                selected: selectedBudgetRange == 'RM 10,000 - RM 20,000',
                onTap: () => onBudgetRangeSelected('RM 10,000 - RM 20,000'),
              ),
              AiBudgetBudgetRangeTile(
                label: 'RM 25,000 - RM 40,000',
                selected: selectedBudgetRange == 'RM 25,000 - RM 40,000',
                onTap: () => onBudgetRangeSelected('RM 25,000 - RM 40,000'),
              ),
              AiBudgetBudgetRangeTile(
                label: 'RM 50,000+',
                selected: selectedBudgetRange == 'RM 50,000+',
                onTap: () => onBudgetRangeSelected('RM 50,000+'),
              ),
              AiBudgetBudgetRangeTile(
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

class AiBudgetGenerateButton extends StatelessWidget {
  const AiBudgetGenerateButton({super.key, required this.onPressed});

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

class AiBudgetPlaceholderCard extends StatelessWidget {
  const AiBudgetPlaceholderCard({super.key, required this.profile});

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
          AiBudgetMetaLine(label: 'Couple', value: profile.displayName),
          AiBudgetMetaLine(
            label: 'Current budget',
            value: 'RM ${profile.totalBudgetLimit.toStringAsFixed(0)}',
          ),
          AiBudgetMetaLine(
            label: 'Guest count',
            value: profile.guestCount > 0 ? profile.guestCount.toString() : '-',
          ),
        ],
      ),
    );
  }
}

class AiBudgetResultCard extends StatelessWidget {
  const AiBudgetResultCard({
    super.key,
    required this.estimate,
    required this.guestCount,
    required this.budgetRange,
    required this.profile,
  });

  final AiBudgetEstimate estimate;
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
            'RM ${estimate.amount.toStringAsFixed(0)}',
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
              children: estimate.breakdown
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

class AiBudgetMetaLine extends StatelessWidget {
  const AiBudgetMetaLine({super.key, required this.label, required this.value});

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

class AiBudgetQuickChip extends StatelessWidget {
  const AiBudgetQuickChip({
    super.key,
    required this.label,
    required this.onTap,
  });

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

class AiBudgetBudgetRangeTile extends StatelessWidget {
  const AiBudgetBudgetRangeTile({
    super.key,
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
