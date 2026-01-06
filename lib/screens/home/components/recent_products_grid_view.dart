import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facility/screens/home/blocs/recent_products_cubit.dart';
import 'package:facility/screens/home/components/product_grid_view.dart';

// Temporary stub
class UserStateHandlerWidget extends StatelessWidget {
  final Widget child;
  const UserStateHandlerWidget({required this.child, super.key});
  @override
  Widget build(BuildContext context) => child;
}

class RecentProductsGridView extends StatefulWidget {
  const RecentProductsGridView({super.key});

  @override
  State<RecentProductsGridView> createState() => _RecentProductsGridViewState();
}

class _RecentProductsGridViewState extends State<RecentProductsGridView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<RecentProductsCubit>();
      if (cubit.state.status == RecentProductsStatusEnum.initial) {
        cubit.fetchRecentProducts(reset: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) => UserStateHandlerWidget(
      child: BlocBuilder<RecentProductsCubit, RecentProductsState>(
        builder: (context, state) => ProductListGridView(
            products: state.products,
            status: state.status == RecentProductsStatusEnum.initial
                ? GridStatusEnum.initial
                : state.status == RecentProductsStatusEnum.loading
                    ? GridStatusEnum.loading
                    : state.status == RecentProductsStatusEnum.success
                        ? GridStatusEnum.success
                        : GridStatusEnum.failure,
            loadMore: state.hasMore
                ? context.read<RecentProductsCubit>().loadMore
                : null,
          ),
      ),
    );
}
