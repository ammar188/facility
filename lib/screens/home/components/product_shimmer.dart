import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Temporary stubs
class AppColors {
  static const shimmerBaseColor = Color(0xFFE0E0E0);
  static const shimmerHighlightColor = Color(0xFFF5F5F5);
  static const shimmerOnBaseColor = Colors.white;
}

class ProductShimmer extends StatelessWidget {
  const ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    const minValue = 100;
    const maxValue = 300;
    final random = Random();
    final randomHeight =
        minValue + (random.nextDouble() * (maxValue - minValue));

    return Material(
      borderRadius: BorderRadius.circular(8),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseColor,
              highlightColor: AppColors.shimmerHighlightColor,
              child: Container(
                width: double.infinity,
                height: randomHeight,
                color: AppColors.shimmerOnBaseColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 17,
                    width: 150,
                    color: AppColors.shimmerOnBaseColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Description shimmer
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 12,
                    width: double.infinity,
                    color: AppColors.shimmerOnBaseColor,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: AppColors.shimmerBaseColor,
                  highlightColor: AppColors.shimmerHighlightColor,
                  child: Container(
                    height: 12,
                    width: 100,
                    color: AppColors.shimmerOnBaseColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
