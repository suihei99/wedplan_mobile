import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:wedplan_mobile/viewmodels/couple/ai_budget_view_model.dart';
import 'package:wedplan_mobile/viewmodels/couple/me_view_model.dart';
import 'package:wedplan_mobile/views/couple/me/ai_budget/widgets/ai_budget_widgets.dart';

class AiBudgetScreen extends StatefulWidget {
  const AiBudgetScreen({super.key});

  @override
  State<AiBudgetScreen> createState() => _AiBudgetScreenState();
}

class _AiBudgetScreenState extends State<AiBudgetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _guestCountController = TextEditingController();
  final AiBudgetViewModel _viewModel = AiBudgetViewModel();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final profile = context.read<MeViewModel>().profile;
    _guestCountController.text = (profile?.guestCount ?? 0) > 0
        ? profile!.guestCount.toString()
        : '100';
    _viewModel.initialize(profile);
    _initialized = true;
  }

  @override
  void dispose() {
    _guestCountController.dispose();
    _viewModel.dispose();
    super.dispose();
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

    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return AiBudgetScreenContent(
          profile: profile,
          viewModel: _viewModel,
          guestCountController: _guestCountController,
          formKey: _formKey,
          onQuickTap: _setQuickGuestCount,
          onBudgetRangeSelected: _viewModel.selectBudgetRange,
          onGenerate: _generateEstimate,
          onReset: _resetToProfile,
        );
      },
    );
  }

  void _setQuickGuestCount(int value) {
    _guestCountController.text = value.toString();
    _viewModel.markUngenerated();
  }

  void _generateEstimate() {
    if (!_formKey.currentState!.validate()) return;

    _viewModel.markGenerated();
  }

  void _resetToProfile() {
    final profile = context.read<MeViewModel>().profile;
    _guestCountController.text = (profile?.guestCount ?? 0) > 0
        ? profile!.guestCount.toString()
        : '100';
    _viewModel.resetFromProfile(profile);
  }
}
