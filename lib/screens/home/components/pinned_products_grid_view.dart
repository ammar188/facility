import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/models/product.dart';
import 'package:facility/screens/home/components/product_grid_view.dart';

// Temporary stubs
class UserStateHandlerWidget extends StatelessWidget {
  final Widget child;
  const UserStateHandlerWidget({required this.child, super.key});
  @override
  Widget build(BuildContext context) => child;
}

// TODO: Create PinnedProductsCubit

enum PinnedProductsStatusEnum {
  initial,
  loading,
  success,
  failure,
}

class PinnedProductsState {
  final PinnedProductsStatusEnum status;
  final List<ProductModel> products;
  final bool hasMore;
  
  const PinnedProductsState({
    required this.status,
    required this.products,
    required this.hasMore,
  });
  
  factory PinnedProductsState.initial() {
    return const PinnedProductsState(
      status: PinnedProductsStatusEnum.initial,
      products: [],
      hasMore: true,
    );
  }
}

class PinnedProductsCubit extends Cubit<PinnedProductsState> {
  PinnedProductsCubit() : super(PinnedProductsState.initial());
  
  int currentOffset = 0;
  final int limit = 10;
  bool isLoading = false;
  
  Future<void> fetchPinnedProducts({bool reset = false}) async {
    if (isLoading) return;
    if (!reset && !state.hasMore) return;
    
    try {
      if (reset) {
        emit(PinnedProductsState(
          status: PinnedProductsStatusEnum.loading,
          products: [],
          hasMore: true,
        ));
        currentOffset = 0;
      } else {
        emit(PinnedProductsState(
          status: PinnedProductsStatusEnum.loading,
          products: state.products,
          hasMore: state.hasMore,
        ));
      }
      
      isLoading = true;
      // TODO: Implement ProductModel.fetchPinnedProducts() method
      final fetched = <ProductModel>[]; // Placeholder - implement API call
      
      final newHasMore = fetched.length == limit;
      currentOffset += limit;
      
      final allProducts = reset
          ? fetched
          : List<ProductModel>.from(state.products)..addAll(fetched);
      
      emit(PinnedProductsState(
        status: PinnedProductsStatusEnum.success,
        products: allProducts,
        hasMore: newHasMore,
      ));
    } catch (e) {
      emit(PinnedProductsState(
        status: PinnedProductsStatusEnum.failure,
        products: state.products,
        hasMore: false,
      ));
    } finally {
      isLoading = false;
    }
  }
  
  Future<void> loadMore() async => fetchPinnedProducts();
  
  Future<void> refresh() async => fetchPinnedProducts(reset: true);
}

class PinnedProductsGridView extends StatefulWidget {
  const PinnedProductsGridView({super.key});

  @override
  State<PinnedProductsGridView> createState() => _PinnedProductsGridViewState();
}

class _PinnedProductsGridViewState extends State<PinnedProductsGridView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<PinnedProductsCubit>();
      if (cubit.state.status == PinnedProductsStatusEnum.initial) {
        cubit.fetchPinnedProducts(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) => UserStateHandlerWidget(
      child: BlocBuilder<PinnedProductsCubit, PinnedProductsState>(
        builder: (context, state) {
          return ProductListGridView(
            products: state.products,
            status: state.status == PinnedProductsStatusEnum.initial
                ? GridStatusEnum.initial
                : state.status == PinnedProductsStatusEnum.loading
                ? GridStatusEnum.loading
                : state.status == PinnedProductsStatusEnum.success
                ? GridStatusEnum.success
                : GridStatusEnum.failure,
            loadMore: state.hasMore
                ? context.read<PinnedProductsCubit>().loadMore
                : null,
          );
        },
      ),
    );
}
