import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';

class PopularProductsCubit extends Cubit<PopularProductsState> {
  PopularProductsCubit() : super(PopularProductsState.initial());

  int currentOffset = 0;
  final int limit = 10;
  bool isLoading = false;

  Future<void> fetchPopularProducts({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !state.hasMore) return;

    try {
      if (reset) {
        emit(state.copyWith(
          status: PopularProductsStatusEnum.loading,
          products: [],
          hasMore: true,
        ));
        currentOffset = 0;
      } else {
        emit(state.copyWith(status: PopularProductsStatusEnum.loading));
      }

      isLoading = true;

      final response = await ProductModel.fetchClicksViews(
        limit: limit,
        offset: currentOffset,
      );

      final newHasMore = response.length == limit;
      currentOffset += limit;

      final allProducts = reset
          ? response
          : List<ProductModel>.from(state.products)..addAll(response);

      emit(state.copyWith(
        status: PopularProductsStatusEnum.success,
        products: allProducts,
        hasMore: newHasMore,
      ));
    } catch (e) {
      log('Failed to fetch popular products: $e');
      emit(
        state.copyWith(
          status: PopularProductsStatusEnum.failure,
          hasMore: false,
        ),
      );
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMore() async => fetchPopularProducts();

  Future<void> refresh() async => fetchPopularProducts(reset: true);
}

enum PopularProductsStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class PopularProductsState {

  const PopularProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
  });

  factory PopularProductsState.initial() {
    return const PopularProductsState(
      status: PopularProductsStatusEnum.initial,
      products: [],
      hasMore: true,
    );
  }
  final PopularProductsStatusEnum status;
  final List<ProductModel> products;
  final bool hasMore;

  PopularProductsState copyWith({
    PopularProductsStatusEnum? status,
    List<ProductModel>? products,
    bool? hasMore,
  }) {
    return PopularProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
