import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/transaction.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_common_widgets.dart';

class NewTransactionScreen extends ConsumerStatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  ConsumerState<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends ConsumerState<NewTransactionScreen> {
  final _amountController = TextEditingController(text: '15.00');
  final _noteController = TextEditingController(text: 'Lunch at Sunway');
  bool _isExpense = true;
  String _category = 'Food';
  String _paymentMethod = 'Cash';

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleIconButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'New transaction',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SegmentedToggle(
                leftLabel: 'Expense',
                rightLabel: 'Income',
                isLeftSelected: _isExpense,
                onChanged: (isExpense) {
                  setState(() {
                    _isExpense = isExpense;
                  });
                },
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Amount',
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: InputDecoration(
                    prefixText: 'RM  ',
                    prefixStyle: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: GoogleFonts.spaceGrotesk(
                      color: Colors.white24,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'CATEGORY',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8CB4F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Food', 'Transport', 'Bills', 'Shopping', '+ Add']
                    .map(
                      (item) => ChoiceChipButton(
                        label: item,
                        selected: _category == item,
                        onTap: item.startsWith('+')
                            ? () {}
                            : () {
                                setState(() {
                                  _category = item;
                                });
                              },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Date',
                child: Text(
                  '3 Jul 2026',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LabeledField(
                label: 'Note (optional)',
                child: TextField(
                  controller: _noteController,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Lunch at Sunway',
                    hintStyle: GoogleFonts.inter(
                      color: Colors.white38,
                      fontSize: 18,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'PAYMENT METHOD',
                style: GoogleFonts.inter(
                  color: const Color(0xFF8CB4F6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: ['Cash', 'E-wallet', 'Card']
                    .map(
                      (item) => ChoiceChipButton(
                        label: item,
                        selected: _paymentMethod == item,
                        onTap: () {
                          setState(() {
                            _paymentMethod = item;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveTransaction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: AppColors.primary.withValues(alpha: 0.28),
                  ),
                  child: Text(
                    'Save transaction',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'Only amount & category are required',
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA9C3EC),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount to continue.')),
      );
      return;
    }

    final trimmedNote = _noteController.text.trim();
    final title = trimmedNote.isEmpty
        ? (_isExpense ? 'Quick expense' : 'Quick income')
        : trimmedNote;

    ref.read(dashboardProvider.notifier).addTransaction(
          Transaction(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: title,
            amount: amount,
            date: DateTime.now(),
            categoryId: _category.toLowerCase().replaceAll(' ', '_'),
            categoryLabel: _category,
            paymentMethod: _paymentMethod,
            note: trimmedNote,
            isExpense: _isExpense,
          ),
        );
    Navigator.of(context).pop();
  }
}
