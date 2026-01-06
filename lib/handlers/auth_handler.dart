import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khareed/components/bottom_nav_bar/bottom_nav_bar_cubit.dart';
import 'package:khareed/models/address.dart';
import 'package:khareed/router/app_router.dart';
import 'package:khareed/screens/home/blocs/recent_products_cubit.dart';
import 'package:khareed/screens/product/components/pinned_products_cubit.dart';
import 'package:khareed_core/khareed_core.dart';
import 'package:khareed_core/terms_and_conditions/terms_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthHandler extends StatelessWidget {

  const AuthHandler({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, AuthState>(
      listener: (context, userState) async {
        final event = userState.event;
        final session = userState.session;

        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.initialSession) {
          if (session != null) {

            final termsCubit = context.read<TermsCubit>();
            final addressCubit = context.read<FetchListCubit<Address>>();
            final orderCubit = context.read<FetchListCubit<Order>>();
            final requestCubit = context.read<FetchListCubit<Request>>();
            final requestItemCubit =
            context.read<FetchListCubit<RequestItem>>();
            final pinnedCubit = context.read<PinnedProductsCubit>();
            final recentCubit = context.read<RecentProductsCubit>();
            final navBarCubit = context.read<BottomNavBarCubit>();
            final chatCenterCubit = context.read<ChatCenterChatCubit>();
            final chatCubit = context.read<ChatCubit>();


            await termsCubit.checkIfAgreedToLatest();
            await addressCubit.fetchData();
            await orderCubit.fetchData();
            await requestCubit.fetchData(key: FetchKey.users);
            await requestItemCubit.fetchData(key: FetchKey.users);
            await pinnedCubit.fetchPinnedProducts();
            await recentCubit.fetchRecentProducts();
            await chatCenterCubit.fetchChats(reset: true);

            await chatCubit.fetchChats(reset: true);

            // await chatCubit.fetchData().then((chats) {
            //   if (chats.isNotEmpty) {
            //     final chat = chats.first;
            //     context.read<SelectionCubit<Chat>>().select(chat);
            //
            //     context.read<FetchListCubit<Message>>().fetchData(id: chat.id);
            //
            //     final requests = requestCubit.state.$1;
            //     final requestIds =
            //     requests.map((r) => r.id).whereType<int>().toList();
            //
            //     context.read<FetchListCubit<RequestBid>>().executeAndEmitData(
            //           () => RequestBid.fetchBidsPerUserId(
            //         requestIds,
            //         chat.otherUserId,
            //       ),
            //     );
            //   }
            // });

            if (navBarCubit.state.current == BottomNavBarStateEnum.quotation) {
              context.read<SelectionCubit<Request>>().clear();
              // context.goNamed(AppRoutes.requestsPost.name);
            }
          }
        } else if (event == AuthChangeEvent.signedOut) {
          context.read<PinnedProductsCubit>().fetchPinnedProducts();
          context.read<ChatCenterChatCubit>().fetchChats(reset: true);
          context.read<TermsCubit>().checkIfAgreedToLatest();
          context.go(AppRoutes.home.path);
        }
      },
      child: child,
    );
  }
}
