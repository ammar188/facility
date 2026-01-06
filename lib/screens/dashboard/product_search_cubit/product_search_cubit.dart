import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';

enum SearchStateEnum { initial, loading, success, failure }

class ProductSearchCubit extends Cubit<(List<ProductModel>, SearchStateEnum)> {
  ProductSearchCubit() : super(([], SearchStateEnum.initial));

  final searchController = TextEditingController();
  int currentOffset = 0;
  Set<int> selectedTags = {};
  Set<int> selectedCategories = {}; // Added for selected categories

  bool hasMore = true;
  int limit = 10;
  bool isLoading = false;

  void toggleTag(int tagId) {
    if (selectedTags.contains(tagId)) {
      selectedTags.remove(tagId);
    } else {
      selectedTags.add(tagId);
    }
    search();
  }

  void toggleCategory(int categoryId) {
    if (selectedCategories.contains(categoryId)) {
      selectedCategories.remove(categoryId);
    } else {
      selectedCategories.add(categoryId);
    }
    search();
  }

  void setCategory(int categoryId) {
    selectedCategories..clear()..add(categoryId);
    search();
  }

  Future<void> search({int? brandId}) async {
    try {
      resetPagination();
      emit(([], SearchStateEnum.loading));
      final products = await ProductModel.search(
        brandId: brandId,
        tagIds: selectedTags.toList(),
        categoryIds: selectedCategories.toList(),
        // Pass selected categories
        searchTerm: searchController.text,
        limit: limit,
        offset: currentOffset,
      );
      hasMore = products.length == limit;
      emit((products, SearchStateEnum.success));
    } catch (_) {
      emit(([], SearchStateEnum.failure));
    }
  }

  Future<void> loadMore({int? brandId}) async {
    try {
      if (!hasMore || isLoading) return;
      emit((state.$1, SearchStateEnum.loading));
      currentOffset += limit;
      final products = await ProductModel.search(
        brandId: brandId,
        tagIds: selectedTags.toList(),
        categoryIds: selectedCategories.toList(),
        // Pass selected categories
        searchTerm: searchController.text,
        limit: limit,
        offset: currentOffset,
      );
      hasMore = products.length == limit;
      emit(
        (
          List<ProductModel>.from(state.$1)..addAll(products),
          SearchStateEnum.success,
        ),
      );
    } catch (_) {
      emit((state.$1, SearchStateEnum.failure));
    }
  }

  void resetPagination() {
    currentOffset = 0;
  }
}
