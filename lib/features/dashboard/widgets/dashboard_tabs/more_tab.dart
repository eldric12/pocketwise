part of '../dashboard_tabs.dart';

class MoreTab extends StatelessWidget {
  const MoreTab({
    super.key,
    // required this.transactions,
    required this.onOpenReports,
    required this.onToggleTheme,
  });

  // final List<Transaction> transactions;
  final VoidCallback onOpenReports;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MoreRow(
                  icon: Icons.swap_vert_rounded,
                  label: 'Reports & analytics',
                  onTap: onOpenReports,
                ),
                const PanelDivider(),
                MoreRow(
                  icon: Icons.grid_view_rounded,
                  label: 'Manage categories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageCategoriesScreen(),
                      ),
                    );
                  },
                ),
                const PanelDivider(),
                MoreRow(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SettingTab(onToggleTheme: onToggleTheme),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
