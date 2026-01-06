import 'package:flutter/material.dart';
import 'package:facility/l10n/l10n.dart';

// Temporary stubs
class AppColors {
  static const secondary = Color(0xFFF5F5F5);
  static const onSecondary = Color(0xFF000000);
}

class HomeTabBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeTabBar({required this.controller, super.key});

  final TabController controller;

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  State<HomeTabBar> createState() => _HomeTabBarState();
}

class _HomeTabBarState extends State<HomeTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.secondary),
      height: widget.preferredSize.height,
      child: TabBar(
        controller: widget.controller,
        isScrollable: true,
        physics: const BouncingScrollPhysics(),
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(text: context.l10n.featured),
          Tab(text: context.l10n.pinned),
          Tab(text: context.l10n.popular),
          Tab(text: context.l10n.recent),
          Tab(text: context.l10n.latest),
        ],
      ),
    );
  }
}
