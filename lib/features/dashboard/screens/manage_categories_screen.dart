import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../models/category_definition.dart';
import '../providers/dashboard_provider.dart';
import '../utils/category_catalog.dart';
import '../widgets/category_editor_sheet.dart';
import '../widgets/dashboard_common_widgets.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);
    final expenses = state.categories
        .where((category) => category.isExpense)
        .toList();
    final income = state.categories
        .where((category) => !category.isExpense)
        .toList();

    return Scaffold(
      backgroundColor: context.themeColors.background,
      appBar: AppBar(
        backgroundColor: context.themeColors.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Manage categories',
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                children: [
                  Text(
                    'Choose how each category appears across transactions, budgets, and reports.',
                    style: GoogleFonts.inter(
                      color: context.themeColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _CategorySection(
                    title: 'Expense categories',
                    categories: expenses,
                    onEdit: (category) =>
                        _editCategory(context, ref, category, expenses),
                  ),
                  const SizedBox(height: 28),
                  _CategorySection(
                    title: 'Income categories',
                    categories: income,
                    onEdit: (category) =>
                        _editCategory(context, ref, category, income),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _editCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryDefinition category,
    List<CategoryDefinition> peers,
  ) async {
    final updated = await showCategoryEditorSheet(
      context: context,
      isExpense: category.isExpense,
      existingNames: peers.map((item) => item.label).toSet(),
      initialCategory: category,
    );
    if (updated == null || !context.mounted) return;

    try {
      await ref.read(dashboardProvider.notifier).updateCategory(updated);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to update this category. Please try again.'),
          ),
        );
    }
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.categories,
    required this.onEdit,
  });

  final String title;
  final List<CategoryDefinition> categories;
  final ValueChanged<CategoryDefinition> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GlassPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < categories.length; index++) ...[
                _CategoryRow(
                  category: categories[index],
                  onTap: () => onEdit(categories[index]),
                ),
                if (index != categories.length - 1) const PanelDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onTap});

  final CategoryDefinition category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = categoryAppearance(category, Theme.of(context).brightness);
    return Semantics(
      button: true,
      label: 'Edit ${category.label} appearance',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: visual.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(visual.icon, color: visual.foreground, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.label,
                        style: GoogleFonts.inter(
                          color: context.themeColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.isCustom
                            ? 'Custom category'
                            : 'Built-in category',
                        style: GoogleFonts.inter(
                          color: context.themeColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: context.themeColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
