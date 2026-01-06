import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';

class FeaturedProductsCubit extends Cubit<FeaturedProductsState> {
  FeaturedProductsCubit() : super(FeaturedProductsState.initial());

  int currentOffset = 0;
  final int limit = 10;
  bool isLoading = false;

  Future<void> fetchFeaturedProducts({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !state.hasMore) return;

    try {
      if (reset) {
        emit(state.copyWith(
          status: FeaturedProductsStatusEnum.loading,
          products: [],
          hasMore: true,
        ));
        currentOffset = 0;
      } else {
        emit(state.copyWith(status: FeaturedProductsStatusEnum.loading));
      }

      isLoading = true;

      final fetched = await ProductModel.fetchFeaturedViews(
        limit: limit,
        offset: currentOffset,
      );

      final newHasMore = fetched.length == limit;
      currentOffset += limit;

      final allProducts = reset
          ? fetched
          : List<ProductModel>.from(state.products)..addAll(fetched);

      emit(state.copyWith(
        status: FeaturedProductsStatusEnum.success,
        products: allProducts,
        hasMore: newHasMore,
      ));
    } catch (e) {
      log('Failed to fetch featured products: $e');
      emit(state.copyWith(
        status: FeaturedProductsStatusEnum.failure,
        hasMore: false,
      ));
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMore() async => fetchFeaturedProducts();

  Future<void> refresh() async => fetchFeaturedProducts(reset: true);
}

enum FeaturedProductsStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class FeaturedProductsState {

  const FeaturedProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
  });

  factory FeaturedProductsState.initial() {
    return const FeaturedProductsState(
      status: FeaturedProductsStatusEnum.initial,
      products: [],
      hasMore: true,
    );
  }
  final FeaturedProductsStatusEnum status;
  final List<ProductModel> products;
  final bool hasMore;

  FeaturedProductsState copyWith({
    FeaturedProductsStatusEnum? status,
    List<ProductModel>? products,
    bool? hasMore,
  }) {
    return FeaturedProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
