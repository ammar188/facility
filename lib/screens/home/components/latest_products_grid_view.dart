import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/home/blocs/latest_products_cubit.dart';
import 'package:facility/screens/home/components/product_grid_view.dart';

class LatestProductsGridView extends StatefulWidget {
  const LatestProductsGridView({super.key});

  @override
  State<LatestProductsGridView> createState() => _LatestProductsGridViewState();
}

class _LatestProductsGridViewState extends State<LatestProductsGridView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<LatestProductsCubit>();
      if (cubit.state.status == LatestProductsStatusEnum.initial) {
        cubit.fetchLatestProducts(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LatestProductsCubit, LatestProductsState>(
        builder: (context, state) {
          return ProductListGridView(
            products: state.products,
            status: state.status == LatestProductsStatusEnum.initial
                ? GridStatusEnum.initial
                : state.status == LatestProductsStatusEnum.loading
                    ? GridStatusEnum.loading
                    : state.status == LatestProductsStatusEnum.success
                        ? GridStatusEnum.success
                        : GridStatusEnum.failure,
            loadMore: state.hasMore
                ? context.read<LatestProductsCubit>().loadMore
                : null,
          );
        },
      );
}
