import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';

class RecentProductsCubit extends Cubit<RecentProductsState> {
  RecentProductsCubit() : super(RecentProductsState.initial());

  int currentOffset = 0;
  final int limit = 10;
  bool isLoading = false;

  Future<void> fetchRecentProducts({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !state.hasMore) return;

    try {
      if (reset) {
        emit(state.copyWith(
          status: RecentProductsStatusEnum.loading,
          products: [],
          hasMore: true,
        ));
        currentOffset = 0;
      } else {
        emit(state.copyWith(status: RecentProductsStatusEnum.loading));
      }

      isLoading = true;

      final response = await ProductModel.fetchRecentViewedProducts(
        limit: limit,
        offset: currentOffset,
      );

      final newHasMore = response.length == limit;
      currentOffset += limit;

      final allProducts = reset
          ? response
          : List<ProductModel>.from(state.products)..addAll(response);

      emit(state.copyWith(
        status: RecentProductsStatusEnum.success,
        products: allProducts,
        hasMore: newHasMore,
      ));
    } catch (e) {
      log('Failed to fetch recent products: $e');
      emit(state.copyWith(
        status: RecentProductsStatusEnum.failure,
        hasMore: false,
      ));
    } finally {
      isLoading = false;
    }
  }

  Future<void> loadMore() async => fetchRecentProducts();

  Future<void> refresh() async => fetchRecentProducts(reset: true);
}

enum RecentProductsStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class RecentProductsState {

  const RecentProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
  });

  factory RecentProductsState.initial() {
    return const RecentProductsState(
      status: RecentProductsStatusEnum.initial,
      products: [],
      hasMore: true,
    );
  }

  final RecentProductsStatusEnum status;
  final List<ProductModel> products;
  final bool hasMore;

  RecentProductsState copyWith({
    RecentProductsStatusEnum? status,
    List<ProductModel>? products,
    bool? hasMore,
  }) {
    return RecentProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
