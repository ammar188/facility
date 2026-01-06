import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/home/blocs/featured_products_cubit.dart';
import 'package:facility/screens/home/components/product_grid_view.dart';

class FeaturedProductsGridView extends StatefulWidget {
  const FeaturedProductsGridView({super.key});

  @override
  State<FeaturedProductsGridView> createState() => _FeaturedProductsGridViewState();
}

class _FeaturedProductsGridViewState extends State<FeaturedProductsGridView> {
  @override
  void initState() {
    super.initState();
    // Auto-fetch data when widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<FeaturedProductsCubit>();
      if (cubit.state.status == FeaturedProductsStatusEnum.initial) {
        cubit.fetchFeaturedProducts(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FeaturedProductsCubit, FeaturedProductsState>(
        builder: (context, state) {
          return ProductListGridView(
            products: state.products,
            status: state.status == FeaturedProductsStatusEnum.initial
                ? GridStatusEnum.initial
                : state.status == FeaturedProductsStatusEnum.loading
                    ? GridStatusEnum.loading
                    : state.status == FeaturedProductsStatusEnum.success
                        ? GridStatusEnum.success
                        : GridStatusEnum.failure,
            loadMore: state.hasMore
                ? context.read<FeaturedProductsCubit>().loadMore
                : null,
          );
        },
      );
}
