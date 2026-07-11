import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class PocketWiseBottomBar extends StatelessWidget {
  const PocketWiseBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 88,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1426).withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: BottomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                active: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.menu_rounded,
                activeIcon: Icons.menu_rounded,
                label: 'Activity',
                active: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
            ),
            SizedBox(
              width: 84,
              child: Center(
                child: GestureDetector(
                  onTap: onAddPressed,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.42),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.adjust_outlined,
                activeIcon: Icons.adjust_rounded,
                label: 'Budget',
                active: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
            ),
            Expanded(
              child: BottomNavItem(
                icon: Icons.more_horiz_rounded,
                activeIcon: Icons.more_horiz_rounded,
                label: 'More',
                active: currentIndex == 3,
                onTap: () => onChanged(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 19,
              color: active ? AppColors.primary : const Color(0xFF7487A9),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: active ? AppColors.primary : const Color(0xFF7487A9),
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
