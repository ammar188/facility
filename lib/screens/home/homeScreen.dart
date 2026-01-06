// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:facility/app/routes/app_routes.dart';
// import 'package:facility/screens/home/components/banner.dart' show BannersView, dummyMainBanners;
// import 'package:facility/screens/home/components/bar.dart';
// import 'package:facility/screens/home/components/bar_view.dart';

// // Temporary stubs for missing components
// class Category {
//   final int? id;
//   final String name;
//   Category({this.id, required this.name});
// }

// class CategoryShimmer extends StatelessWidget {
//   const CategoryShimmer({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 100,
//       height: 100,
//       color: Colors.grey[300],
//       margin: const EdgeInsets.all(8),
//     );
//   }
// }

// class CategoryTile extends StatelessWidget {
//   final Category category;
//   const CategoryTile({required this.category, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 100,
//       height: 100,
//       margin: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.blue[100],
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: Text(
//           category.name,
//           style: const TextStyle(fontSize: 12),
//         ),
//       ),
//     );
//   }
// }

// class CustomListView<T> extends StatelessWidget {
//   final EdgeInsets padding;
//   final Widget loadingWidget;
//   final Widget emptyWidget;
//   final Widget errorWidget;
//   final bool isScrollHorizontal;
//   final Widget Function(BuildContext, T) itemBuilder;
//   final List<T>? items;

//   const CustomListView({
//     required this.padding,
//     required this.loadingWidget,
//     required this.emptyWidget,
//     required this.errorWidget,
//     required this.isScrollHorizontal,
//     required this.itemBuilder,
//     this.items,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final data = items ?? <T>[];
//     if (data.isEmpty) {
//       return emptyWidget;
//     }
//     return ListView.builder(
//       scrollDirection: isScrollHorizontal ? Axis.horizontal : Axis.vertical,
//       padding: padding,
//       itemCount: data.length,
//       itemBuilder: (context, index) => itemBuilder(context, data[index]),
//     );
//   }
// }

// class AppInsets {
//   static const sideInsets = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({required this.tabController, super.key});

//   final TabController tabController;

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return NestedScrollView(
//             headerSliverBuilder: (
//               BuildContext context,
//               bool innerBoxIsScrolled,
//             ) {
//               return <Widget>[
//                 SliverAppBar(
//                   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                   pinned: true,
//                   floating: true,
//                   // expandedHeight: 424,
//                   expandedHeight: 260, 

//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // const SizedBox(height: 16),
//                         // BannersView(mainBannerList: dummyMainBanners),
//                         // const SizedBox(height: 16),
//                         SizedBox(
//                           // height: 152,
//                           child: CustomListView<Category>(
//                             // items: [
//                             //   Category(id: 1, name: 'Category 1'),
//                             //   Category(id: 2, name: 'Category 2'),
//                             //   Category(id: 3, name: 'Category 3'),
//                             //   Category(id: 4, name: 'Category 4'),
//                             //   Category(id: 5, name: 'Category 5'),
//                             // ],
//                             padding: AppInsets.sideInsets.copyWith(
//                               right: AppInsets.sideInsets.right - 8,
//                             ),
//                             loadingWidget: const CategoryShimmer(),
//                             emptyWidget: const CategoryShimmer(),
//                             errorWidget: Container(),
//                             isScrollHorizontal: true,
//                             itemBuilder: (context, data) {
//                               return InkWell(
//                                 onTap: () => _onCategoryToggle(context, data),
//                                 child: CategoryTile(category: data),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   bottom: HomeTabBar(controller: tabController),
//                 ),
//               ];
//             },
//             body: HomeTabBarView(controller: tabController),
//           );
//         },
//       ),
//     );
//   }

//   void _onCategoryToggle(BuildContext context, Category category) {
//     // TODO: Implement ProductSearchCubit
//     // context.read<ProductSearchCubit>().setCategory(category.id);
//     context.go(AppRoutes.dashBoard.path);
//   }
// }
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:facility/app/routes/app_routes.dart';
import 'package:facility/screens/home/components/bar.dart';
import 'package:facility/screens/home/components/bar_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.tabController, super.key});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (
          BuildContext context,
          bool innerBoxIsScrolled,
        ) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              floating: true,
              // ❌ No expandedHeight
              // ❌ No FlexibleSpaceBar
              bottom: HomeTabBar(controller: tabController),
            ),
          ];
        },
        body: HomeTabBarView(controller: tabController),
      ),
    );
  }

  void _onCategoryToggle(BuildContext context) {
    context.go(AppRoutes.dashBoard.path);
  }
}
