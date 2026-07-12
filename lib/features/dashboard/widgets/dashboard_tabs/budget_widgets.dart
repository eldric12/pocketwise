part of '../dashboard_tabs.dart';

class _SetBudgetDialog extends StatefulWidget {
  const _SetBudgetDialog({
    required this.category,
    this.currentLimit,
    this.onRemove,
  });

  final String category;
  final double? currentLimit;
  final VoidCallback? onRemove;

  @override
  State<_SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<_SetBudgetDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentLimit?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF33435B)),
      ),
      title: Text(
        widget.currentLimit == null ? 'Set budget' : 'Edit budget',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly limit for ${widget.category}',
            style: GoogleFonts.inter(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}(\.\d{0,2})?')),
            ],
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Budget amount',
              prefixText: 'RM ',
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.background,
              labelStyle: GoogleFonts.inter(color: AppColors.mutedText),
              prefixStyle: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3A4960)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger),
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actionsAlignment: widget.onRemove == null
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      actions: [
        if (widget.onRemove != null)
          TextButton(
            onPressed: widget.onRemove,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Enter an amount greater than RM 0.');
      return;
    }
    Navigator.pop(context, amount);
  }
}

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.data,
    required this.onSetBudget,
  });

  final BudgetViewData data;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final progress = data.limit == null || data.limit == 0
        ? 0.0
        : (data.spent! / data.limit!).clamp(0.0, 1.0).toDouble();
    final percentage = data.limit == null || data.limit == 0
        ? null
        : ((data.spent! / data.limit!) * 100).round();
    final overAmount = data.limit != null && data.spent! > data.limit!
        ? data.spent! - data.limit!
        : null;
    final badgeLabel = overAmount == null
        ? '$percentage%'
        : 'RM${overAmount == overAmount.roundToDouble() ? overAmount.toStringAsFixed(0) : overAmount.toStringAsFixed(2)} over';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.category,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSetBudget,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                data.limit == null ? '+ Set budget' : 'Edit',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GlassPanel(
          child: data.limit == null
              ? Text(
                  'No budget set — spending shown without a limit.',
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'RM ${data.spent!.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ RM ${data.limit!.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            color: AppColors.mutedText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: data.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badgeLabel,
                            style: GoogleFonts.inter(
                              color: data.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class BudgetWarningCard extends StatelessWidget {
  const BudgetWarningCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.color = AppColors.warning,
  });

  factory BudgetWarningCard.fromBudget(BudgetViewData budget) {
    final spent = budget.spent!;
    final limit = budget.limit!;
    final percentage = ((spent / limit) * 100).round();
    final isExceeded = spent >= limit;
    return BudgetWarningCard(
      title: isExceeded
          ? '${budget.category} budget exceeded'
          : '${budget.category} budget at $percentage%',
      subtitle:
          'RM${spent.toStringAsFixed(0)} of RM${limit.toStringAsFixed(0)} spent this month.',
      color: isExceeded ? AppColors.danger : AppColors.warning,
    );
  }

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 14,
                    height: 1.45,
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

