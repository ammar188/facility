import 'dart:developer';

import 'package:facility/hooks/auth_hooks.dart';
import 'package:facility/screens/loginScreen.dart';
import 'package:flutter/material.dart';
import 'create_board_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const sidebarBg = Color(0xFFFFFFFF);
  static const accent = Color(0xFFEAF245);
  static const lightBg = Color(0xFFF6F6F6);
  static const primaryText = Color(0xFF2D403C);
  static const secondaryText = Color(0xFF7A7D86);

  int _selected = 0;

  final _navItems = const <_NavItem>[
    _NavItem('Dashboard', Icons.space_dashboard_rounded),
    _NavItem('Create Board', Icons.add_business_rounded),
    // _NavItem('Market', Icons.store_mall_directory_outlined),
    // _NavItem('Active Bids', Icons.gavel_outlined),
    // _NavItem('My Portfolio', Icons.work_outline_rounded),
    // _NavItem('Wallet', Icons.account_balance_wallet_outlined),
    // _NavItem('Favourites', Icons.favorite_border_rounded),
    // _NavItem('History', Icons.history_rounded),
    // _NavItem('Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Sidebar(
              background: sidebarBg,
              accent: accent,
              navItems: _navItems,
              selectedIndex: _selected,
              onSelect: (index) => setState(() => _selected = index),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(accent: accent),
                    const SizedBox(height: 24),
                    Expanded(child: _PageSurface(item: _navItems[_selected])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.background,
    required this.accent,
    required this.navItems,
    required this.selectedIndex,
    required this.onSelect,
  });

  final Color background;
  final Color accent;
  final List<_NavItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const primaryText = Color(0xFF2D403C);
    const secondaryText = Color(0xFF7A7D86);

    final primaryItems = navItems.take(3).toList();
    final profileItems = navItems.skip(3).toList();

    return Container(
      width: 287,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: const Color(0xFFE6E4F0), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SidebarHeader(),
            const SizedBox(height: 28),
            for (var i = 0; i < primaryItems.length; i++) ...[
              _NavButton(
                item: primaryItems[i],
                accent: accent,
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
                activeText: primaryText,
                inactiveText: secondaryText,
                activeBg: const Color(0xFFF0F4F7),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            // const _SectionLabel(text: 'PROFILE'),
            // const SizedBox(height: 12),
            // for (var i = 0; i < profileItems.length; i++) ...[
            //   _NavButton(
            //     item: profileItems[i],
            //     accent: accent,
            //     selected: (i + primaryItems.length) == selectedIndex,
            //     onTap: () => onSelect(i + primaryItems.length),
            //     activeText: primaryText,
            //     inactiveText: secondaryText,
            //     activeBg: const Color(0xFFF0F4F7),
            //   ),
            //   const SizedBox(height: 14),
            // ],
            // const SizedBox(height: 8),
            // const _SectionLabel(text: 'OTHER'),
            // const SizedBox(height: 12),
            // _LightModeRow(textColor: primaryText, secondary: secondaryText),
            const Spacer(),
            const SizedBox(height: 12),
            const _BalanceCard(),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEAF245),
          ),
          child: Center(
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2D403C),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Umair',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D403C),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'NFT Marketplace',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 12,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LightModeRow extends StatefulWidget {
  const _LightModeRow({
    required this.textColor,
    required this.secondary,
  });

  final Color textColor;
  final Color secondary;

  @override
  State<_LightModeRow> createState() => _LightModeRowState();
}

class _LightModeRowState extends State<_LightModeRow> {
  bool _isLight = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 20, color: widget.textColor),
        const SizedBox(width: 12),
        Text(
          'Light Mode',
          style: TextStyle(
            color: widget.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Switch(
          value: _isLight,
          onChanged: (v) => setState(() => _isLight = v),
          activeColor: Colors.white,
          activeTrackColor: const Color(0xFF5E17EB),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE5E7EB),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 228,
      constraints: const BoxConstraints(minHeight:150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2D403C),
            Color(0xFF8B9941),
            Color(0xFF8BC543),
            Color(0xFFD2DC44),
            Color(0xFFDEE744),
            Color(0xFFEAF245),
          ],
          stops: [0.0, 0.2, 0.42, 0.62, 0.8, 1.0],
        ),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your Balance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
          const Text(
            '1,034.02',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2D403C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                minimumSize: const Size.fromHeight(36),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 16,
                    width: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF245),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 12,
                      color: Color(0xFF2D403C),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Top Up Balance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 12,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.accent,
    required this.selected,
    required this.onTap,
    required this.activeText,
    required this.inactiveText,
    required this.activeBg,
  });
  final _NavItem item;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;
  final Color activeText;
  final Color inactiveText;
  final Color activeBg;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? activeBg : Colors.transparent;
    final fg = selected ? activeText : inactiveText;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Icon(item.icon, size: 20, color: fg),
            const SizedBox(width: 12),
            Text(
              item.label,
              style: TextStyle(
                color: fg,
                fontSize: 16,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E4F0), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              color: const Color(0xFFB9E2F5),
              alignment: Alignment.center,
              child: const Icon(Icons.person, color: Color(0xFF2D403C)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muhammed Ali',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF53515B),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Free Account',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF8F92A1),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.settings, color: Color(0xFF53515B), size: 20),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(44),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 24,
                  color: Color(0xFFABAAAF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: Color(0xFF232323),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search Item, Collection and Account..',
                      hintStyle: const TextStyle(
                        color: Color(0xFFABAAAF),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        _SegmentedSwitch(accent: accent),
        const SizedBox(width: 10),
        _CircleButton(
          icon: Icons.notifications_outlined,
          background: const Color(0xFFEAF245),
          iconColor: const Color(0xFF2D403C),
          showDot: true,
          dotColor: Color(0xFF2D403C),
        ),
        const SizedBox(width: 10),
        _CircleAvatar(),
      ],
    );
  }
}

class _SegmentedSwitch extends StatelessWidget {
  const _SegmentedSwitch({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(45),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _Segment(
            label: 'User',
            selected: true,
          ),
          SizedBox(width: 10),
          _Segment(
            label: 'Creator',
            selected: false,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(40),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF18181B) : const Color(0xFF70737D),
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.background,
    this.iconColor,
    this.borderColor,
    this.showDot = false,
    this.dotColor,
  });
  final IconData icon;
  final Color background;
  final Color? iconColor;
  final Color? borderColor;
  final bool showDot;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: iconColor ?? Colors.grey.shade800,
          ),
        ),
        if (showDot)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: dotColor ?? Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
      ],
    );
  }
}

class _CircleAvatar extends StatelessWidget {
  const _CircleAvatar();

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    final messenger = ScaffoldMessenger.of(context);
    final authHooks = AuthHooks();

    try {
      messenger.showSnackBar(const SnackBar(content: Text('Logging out...')));
      log('🚪 Logging out user', name: 'Dashboard');

      // Call logout
      await authHooks.useLogout();

      log('✅ Logout successful', name: 'Dashboard');
      messenger.hideCurrentSnackBar();

      // Wait a moment for auth state to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Navigate to login screen and clear navigation stack
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<LoginScreen>(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false, // Remove all previous routes
        );
      }
    } catch (e) {
      log('❌ Logout error: $e', name: 'Dashboard', error: e);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleLogout(context),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade200,
        child: const Icon(Icons.person, color: Colors.black87),
      ),
    );
  }
}

class _HeroArea extends StatelessWidget {
  const _HeroArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D403C), // dark green top
              Color(0xFF8B9941),
              Color(0xFF8BC543),
              Color(0xFFD2DC44),
              Color(0xFFDEE744),
              Color(0xFFEAF245), // light yellow bottom
            ],
            stops: [
              0.0,
              0.25,
              0.45,
              0.65,
              0.82,
              1.0,
            ],
          ),
          // Optional: subtle noise/texture could be added with an overlay asset if desired.
        ),
      ),
    );
  }
}

class _PageSurface extends StatelessWidget {
  const _PageSurface({required this.item});
  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    // Show Create Board page when "Create Board" is selected
    if (item.label == 'Create Board') {
      return const CreateBoardPage();
    }
    
    // Default dashboard view
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D403C),
          ),
        ),
        const SizedBox(height: 12),
        const Expanded(child: _HeroArea()),
      ],
    );
  }
}

