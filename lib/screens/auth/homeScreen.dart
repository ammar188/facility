// OLD CODE - COMMENTED OUT
// import 'package:flutter/material.dart';
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       ),
//       body: Container(
//         color: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.home,
//                 size: 64,
//                 color: isDark ? Colors.white70 : Colors.black54,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Welcome Home',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Home screen content goes here',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: isDark ? Colors.white70 : Colors.black54,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khareed/router/app_router.dart';
import 'package:khareed/screens/dashboard/product_search_cubit/product_search_cubit.dart';
import 'package:khareed/screens/home/components/banner.dart';
import 'package:khareed/screens/home/components/bar.dart';
import 'package:khareed/screens/home/components/bar_view.dart';
import 'package:khareed_core/khareed_core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.tabController, super.key});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return NestedScrollView(
            headerSliverBuilder: (
              BuildContext context,
              bool innerBoxIsScrolled,
            ) {
              return <Widget>[
                SliverAppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  pinned: true,
                  floating: true,
                  expandedHeight: 424,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        BannersView(mainBannerList: dummyMainBanners),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 152,
                          child: CustomListView<Category>(
                            padding: AppInsets.sideInsets.copyWith(
                              right: AppInsets.sideInsets.right - 8,
                            ),
                            loadingWidget: const CategoryShimmer(),
                            emptyWidget: const CategoryShimmer(),
                            errorWidget: Container(),
                            isScrollHorizontal: true,
                            itemBuilder: (context, data) {
                              return InkWell(
                                onTap: () => _onCategoryToggle(context, data),
                                child: CategoryTile(category: data),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: HomeTabBar(controller: tabController),
                ),
              ];
            },
            body: HomeTabBarView(controller: tabController),
          );
        },
      ),
    );
  }

  void _onCategoryToggle(BuildContext context, Category category) {
    context.read<ProductSearchCubit>().setCategory(category.id);
    context.go(AppRoutes.dashBoard.path);
  }
}
