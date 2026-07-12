part of '../new_transaction_screen.dart';

class _PaymentMethodDropdown extends StatelessWidget {
  const _PaymentMethodDropdown({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static const _methods = ['Cash', 'E-wallet', 'Card', 'Bank transfer'];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: const Color(0xFF243249)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
            const Icon(
              Icons.credit_card_rounded,
              color: Color(0xFF91A6C5),
              size: 24,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PAYMENT METHOD',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF7898C6),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              initialValue: value,
              onSelected: onChanged,
              tooltip: 'Select payment method',
              color: const Color(0xFF243249),
              surfaceTintColor: Colors.transparent,
              elevation: 12,
              position: PopupMenuPosition.under,
              offset: const Offset(0, 4),
              constraints: const BoxConstraints(minWidth: 220),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF33435B)),
              ),
              itemBuilder: (context) => _methods
                  .map(
                    (method) => PopupMenuItem<String>(
                      value: method,
                      height: 52,
                      child: Row(
                        children: [
                          Icon(
                            _iconFor(method),
                            size: 21,
                            color: method == value
                                ? AppColors.primary
                                : const Color(0xFF9AAEC9),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              method,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (method == value)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFC8D4E7),
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(String method) => switch (method) {
        'Cash' => Icons.payments_outlined,
        'E-wallet' => Icons.account_balance_wallet_outlined,
        'Card' => Icons.credit_card_rounded,
        _ => Icons.account_balance_outlined,
      };
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF243249)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF91A6C5), size: 24),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF7898C6),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailing, color: const Color(0xFFC8D4E7), size: 21),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoField extends StatelessWidget {
  const _MemoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF243249)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(
              Icons.note_alt_outlined,
              color: Color(0xFF91A6C5),
              size: 24,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 80,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: 'MEMO / NOTES',
                labelStyle: GoogleFonts.inter(
                  color: const Color(0xFF7898C6),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
                hintText: 'e.g. Lunch, groceries, monthly pay',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF587091),
                  fontSize: 15,
                ),
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, this.centered = false});

  final String text;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: centered ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: const Color(0xFF8FB3E8),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

