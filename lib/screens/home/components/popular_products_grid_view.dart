import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/home/blocs/popular_products_cubit.dart';
import 'package:facility/screens/home/components/product_grid_view.dart';

class PopularProductsGridView extends StatefulWidget {
  const PopularProductsGridView({super.key});

  @override
  State<PopularProductsGridView> createState() => _PopularProductsGridViewState();
}

class _PopularProductsGridViewState extends State<PopularProductsGridView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<PopularProductsCubit>();
      if (cubit.state.status == PopularProductsStatusEnum.initial) {
        cubit.fetchPopularProducts(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PopularProductsCubit, PopularProductsState>(
        builder: (context, state) => ProductListGridView(
          products: state.products,
          status: state.status == PopularProductsStatusEnum.initial
              ? GridStatusEnum.initial
              : state.status == PopularProductsStatusEnum.loading
                  ? GridStatusEnum.loading
                  : state.status == PopularProductsStatusEnum.success
                      ? GridStatusEnum.success
                      : GridStatusEnum.failure,
          loadMore: state.hasMore
              ? context.read<PopularProductsCubit>().loadMore
              : null,
        ),
      );
}
