import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: context.themeColors.surface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: context.themeColors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class FilterChipCard extends StatelessWidget {
  const FilterChipCard({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary
                  : context.themeColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Colors.transparent
                    : context.themeColors.border,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : context.themeColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MonthPill extends StatelessWidget {
  const MonthPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.themeColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.themeColors.surfaceSoft,
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x1FFFFFFF)),
      ),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: context.themeColors.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftSelected,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.themeColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.themeColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentButton(
              label: leftLabel,
              selected: isLeftSelected,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: SegmentButton(
              label: rightLabel,
              selected: !isLeftSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class SegmentButton extends StatelessWidget {
  const SegmentButton({
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? Colors.white : context.themeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: context.themeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.themeColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class ChoiceChipButton extends StatelessWidget {
  const ChoiceChipButton({
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
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : context.themeColors.surfaceSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : context.themeColors.border,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: selected ? Colors.white : context.themeColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class MoreRow extends StatelessWidget {
  const MoreRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.switchValue,
    this.onSwitchChanged,
    this.labelColor,
    this.trailingText
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final dynamic labelColor;
  final String? trailingText;

  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  @override
  Widget build(BuildContext context) {
    final hasSwitch = switchValue != null && onSwitchChanged != null;
    final textColor = labelColor ?? context.themeColors.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasSwitch)
                Switch(
                  value: switchValue!,
                  onChanged: onSwitchChanged,
                )
              else if (trailingText != null)
                Text(
                  trailingText!,
                  style: GoogleFonts.inter(
                    color: context.themeColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  )
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.themeColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PanelDivider extends StatelessWidget {
  const PanelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.themeColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.primary.withValues(alpha: 0.95),
            size: 22,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
