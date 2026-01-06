import 'package:flutter/material.dart';
import 'package:facility/screens/home/components/featured_products_grid_view.dart';
import 'package:facility/screens/home/components/latest_products_grid_view.dart';
import 'package:facility/screens/home/components/pinned_products_grid_view.dart';
import 'package:facility/screens/home/components/popular_products_grid_view.dart';
import 'package:facility/screens/home/components/recent_products_grid_view.dart';

class HomeTabBarView extends StatelessWidget {
  const HomeTabBarView({
    required this.controller,
    super.key,
  });

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      children: [
        FeaturedProductsGridView(),
        PinnedProductsGridView(),
        PopularProductsGridView(),
        RecentProductsGridView(),
        LatestProductsGridView(),
      ],
    );
  }
  //
  // Widget _products(BuildContext context, {bool isTablet = false}) {
  //   return cgv.CustomGridView<ProductModel>(
  //     crossAxisCount: isTablet ? 1 : 2,
  //     mainAxisSpacing: 8,
  //     crossAxisSpacing: 8,
  //     loadingWidget: const ProductShimmer(),
  //     emptyWidget: EmptyWidget(
  //       hideBackgroundAnimation: true,
  //       image: 'assets/beautiful_image_icons/boxes.png',
  //       title: context.l10n.noResults,
  //       subTitle: context.l10n.noResultsToDisplay,
  //     ),
  //     errorWidget: Container(),
  //     padding: AppInsets.baseScreenListInsets,
  //     itemBuilder: (context, product) => ProductTile(
  //       imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
  //       title: product.name,
  //       description: product.description,
  //       category: product.categoryTitle,
  //       estimatedPrice: product.price,
  //       rating: product.rating ?? 0.0,
  //       reviewCount: product.reviewedCount ?? 0,
  //       brand: product.brandName,
  //       onTap: () {
  //         context.read<SelectionCubit<ProductModel>>().select(product);
  //         final isMobile = context.isMobile();
  //         if (isMobile) {
  //           context.go(AppRoutes.product.fullPath());
  //         }
  //       },
  //     ),
  //   );
  // }
}
