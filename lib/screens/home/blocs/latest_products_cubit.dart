import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';

class LatestProductsCubit extends Cubit<LatestProductsState> {
  LatestProductsCubit() : super(LatestProductsState.initial());

  int currentOffset = 0;
  final int limit = 10;
  bool isLoading = false;

  Future<void> fetchLatestProducts({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !state.hasMore) return;

    if (reset) {
      emit(
        state.copyWith(
          status: LatestProductsStatusEnum.loading,
          products: [],
          hasMore: true,
        ),
      );
      currentOffset = 0;
    } else {
      emit(state.copyWith(status: LatestProductsStatusEnum.loading));
    }

    isLoading = true;

    try {
      final response = await ProductModel.fetchLatestProducts(
        limit: limit,
        offset: currentOffset,
      );

      final updatedProducts =
          reset ? response : [...state.products, ...response];

      final newHasMore = response.length == limit;
      currentOffset += limit;

      emit(state.copyWith(
        status: LatestProductsStatusEnum.success,
        products: updatedProducts,
        hasMore: newHasMore,
      ));
    } catch (e) {
      log('Failed to fetch latest products: $e');
      emit(state.copyWith(
        status: LatestProductsStatusEnum.failure,
        hasMore: false,
      ));
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMore() async => fetchLatestProducts();

  Future<void> refresh() async => fetchLatestProducts(reset: true);
}

enum LatestProductsStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class LatestProductsState {

  const LatestProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
  });

  factory LatestProductsState.initial() {
    return const LatestProductsState(
      status: LatestProductsStatusEnum.initial,
      products: [],
      hasMore: true,
    );
  }
  final LatestProductsStatusEnum status;
  final List<ProductModel> products;
  final bool hasMore;

  LatestProductsState copyWith({
    LatestProductsStatusEnum? status,
    List<ProductModel>? products,
    bool? hasMore,
  }) {
    return LatestProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
