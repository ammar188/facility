import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:facility/components/product_tile.dart';
import 'package:facility/models/product.dart';
import 'package:facility/screens/dashboard/product_search_cubit/product_search_cubit.dart';
import 'package:facility/screens/home/components/product_shimmer.dart';
import 'package:facility/screens/home/components/product_grid_view.dart' show EmptyWidget;

class SearchGridView extends StatelessWidget {
  const SearchGridView({
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.padding,
    this.initialWidget,
    super.key,
  });

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final Widget? initialWidget;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductSearchCubit, (List<ProductModel>, SearchStateEnum)>(
      builder: (context, searchState) {
        final (products, searchStatus) = searchState;

        if (searchStatus == SearchStateEnum.loading) {
          return const ProductShimmer();
        } else if (searchStatus == SearchStateEnum.failure) {
          return const Center(child: Text('Failed to load search results'));
        } else if (searchStatus == SearchStateEnum.success && products.isEmpty) {
          return EmptyWidget(
            hideBackgroundAnimation: true,
            image: 'assets/beautiful_image_icons/boxes_mobile.png',
            title: 'No Results',
            subTitle: 'No results to display.',
          );
        }

        return MasonryGridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          padding: padding,
          itemCount: products.length + (initialWidget != null ? 1 : 0),
          itemBuilder: (context, index) {
            // If the index is 0 and an initialWidget is provided, return the initial widget
            if (initialWidget != null && index == 0) {
              return initialWidget!;
            }
            final product = products[index];
            // todo add the initial widget in case of first widget
            return ProductTile(
              imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
              title: product.name,
              description: product.description,
              category: product.categoryTitle,
              estimatedPrice: product.price,
              rating: product.rating ?? 0.0,
              reviewCount: product.reviewedCount ?? 0,
              brand: product.brandName,
            );
          },
        );
      },
    );
  }
}
