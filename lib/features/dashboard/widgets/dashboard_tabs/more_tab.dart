part of '../dashboard_tabs.dart';

class MoreTab extends ConsumerWidget  {
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
  Widget build(BuildContext context, WidgetRef ref) {
    
  Future<void> onLogout() async {
    await AuthService.instance.logout();
    ref.read(currentUserIdProvider.notifier).state = null;

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(onToggleTheme: onToggleTheme),
      ),
      (route) => false,
    );
  }

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
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await onLogout();
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    );
                  }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.themeColors.dangerBackground,
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: context.themeColors.dangerText,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
