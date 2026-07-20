part of '../dashboard_tabs.dart';

class SettingTab extends ConsumerStatefulWidget {
  const SettingTab({super.key, required this.onToggleTheme});

  @override
  ConsumerState<SettingTab> createState() => _SettingTabState();
  final VoidCallback onToggleTheme;
}

class _SettingTabState extends ConsumerState<SettingTab> {
  bool _offlineStorage = true;

  Future<void> _onLogout() async {
    await AuthService.instance.logout();
    ref.read(currentUserIdProvider.notifier).state = null;

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => LoginScreen(onToggleTheme: widget.onToggleTheme),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: context.themeColors.background,
        title: Text(
          'Setting',
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: GoogleFonts.inter(
                    color: context.themeColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                GlassPanel(
                  padding: EdgeInsets.zero,
                  child: MoreRow(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    onTap: () {},
                    switchValue:
                        Theme.of(context).brightness == Brightness.dark,
                    onSwitchChanged: (value) {
                      widget.onToggleTheme();
                    },
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Data',
                  style: GoogleFonts.inter(
                    color: context.themeColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                GlassPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      MoreRow(
                        icon: Icons.assignment_outlined,
                        label: 'Export CSV',
                        onTap: () {
                          // TODO: Implement if needed
                        },
                      ),
                      const PanelDivider(),
                      MoreRow(
                        icon: Icons.delete_outlined,
                        label: 'Clear All Data',
                        labelColor: Colors.redAccent,
                        onTap: () {
                          // TODO
                          showDialog(
                            context: context,
                            builder: ((context) {
                              return AlertDialog(
                                title: const Text('Confirm Delete'),
                                content: const Text(
                                  'Are you sure you want to clear all data? This action cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close dialog
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement after setting up database
                                    },
                                    child: const Text('Clear All Data'),
                                  ),
                                ],
                              );
                            }),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'About',
                  style: GoogleFonts.inter(
                    color: context.themeColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                GlassPanel(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      MoreRow(
                        icon: Icons.info_outlined,
                        label: 'Version',
                        onTap: () {},
                        trailingText: 'v1.0.0',
                      ),
                      MoreRow(
                        icon: Icons.account_circle,
                        label: 'Developer',
                        onTap: () {},
                        trailingText: 'Group 15',
                      ),
                      MoreRow(
                        icon: Icons.storage_outlined,
                        label: 'Offline Storage',
                        onTap: () {},
                        switchValue: _offlineStorage,
                        onSwitchChanged: (value) {
                          setState(() {
                            _offlineStorage = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
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
                              await _onLogout();
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
      ),
    );
  }
}
