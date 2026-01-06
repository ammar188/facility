import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:facility/screens/home/components/product_shimmer.dart';
import 'package:facility/models/product.dart';
import 'package:facility/components/product_tile.dart';

// ProductTile is now in lib/components/product_tile.dart
// ProductModel is now in lib/models/product.dart

class EmptyWidget extends StatelessWidget {
  final bool hideBackgroundAnimation;
  final String? image;
  final String? title;
  final String? subTitle;
  
  const EmptyWidget({
    this.hideBackgroundAnimation = false,
    this.image,
    this.title,
    this.subTitle,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) Image.asset(image!, height: 100),
          if (title != null) Text(title!, style: const TextStyle(fontSize: 18)),
          if (subTitle != null) Text(subTitle!, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class AppInsets {
  static const baseScreenListInsets = EdgeInsets.all(16);
}

enum GridStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class ProductListGridView extends StatelessWidget {
  const ProductListGridView({
    required this.products,
    this.status,
    this.itemCountWhenLoading = 6,
    this.loadMore,
    super.key,
  });

  final List<ProductModel> products;
  final GridStatusEnum? status;
  final int itemCountWhenLoading;
  final VoidCallback? loadMore;

  bool _isNearBottom(ScrollMetrics metrics) =>
      metrics.pixels >= (metrics.maxScrollExtent - 200);

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 2;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            _isNearBottom(notification.metrics) &&
            status != GridStatusEnum.loading) {
          loadMore?.call();
        }
        return false;
      },
      child: Builder(
        builder: (_) {
          if (status == GridStatusEnum.failure) {
            return const Center(child: Text('Failed to load products.'));
          }

          if (products.isEmpty && status != GridStatusEnum.loading) {
            return EmptyWidget(
              hideBackgroundAnimation: true,
              image: 'assets/beautiful_image_icons/boxes.png',
              title: 'No Results',
              subTitle: 'No products to display',
            );
          }

          final itemCount = status == GridStatusEnum.loading
              ? products.length + itemCountWhenLoading
              : products.length;

          return MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: AppInsets.baseScreenListInsets,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return const ProductShimmer();
              }

              final product = products[index];
              return ProductTile(
                imageUrl: product.imageUrls.isNotEmpty
                    ? product.imageUrls.first
                    : '',
                title: product.name,
                description: product.description,
                category: product.categoryTitle,
                estimatedPrice: product.price,
                rating: product.rating ?? 0.0,
                reviewCount: product.reviewedCount ?? 0,
                brand: product.brandName,
                onTap: () {
                  // TODO: Implement SelectionCubit
                  // context.read<SelectionCubit<ProductModel>>().select(product);
                  // Navigate to product detail if needed
                  // context.go(AppRoutes.product.path);
                },
              );
            },
          );
        },
      ),
    );
  }
}

