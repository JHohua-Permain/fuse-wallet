import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/redux/actions/cash_wallet_actions.dart';
import 'package:fusecash/redux/viewsmodels/home.dart';
import 'package:fusecash/features/home/widgets/assets_list.dart';
import 'package:fusecash/features/home/widgets/cash_header.dart';
import 'package:fusecash/features/home/widgets/feed.dart';
import 'package:fusecash/utils/addresses.dart';
import 'package:fusecash/widgets/my_app_bar.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    Key key,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  RefreshIndicator refreshIndicator(HomeViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        viewModel.refreshFeed();
        await Future.delayed(Duration(milliseconds: 1000));
        return 'success';
      },
      child: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                appBar: AppBar(
                  toolbarHeight: 70,
                  backgroundColor: Theme.of(context).canvasColor,
                  bottom: PreferredSize(
                    preferredSize: Size(
                      MediaQuery.of(context).size.width * .8,
                      70,
                    ),
                    child: TabBar(
                      tabs: [
                        Tab(
                          child: Text(
                            I18n.of(context).feed,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Tab(
                          child: Text(
                            I18n.of(context).wallet,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                body: TabBarView(
                  children: [
                    Feed(),
                    AssetsList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, HomeViewModel>(
      distinct: true,
      converter: HomeViewModel.fromStore,
      onInitialBuild: (viewModel) {
        viewModel.onReceiveBranchData(true);
      },
      onWillChange: (previousViewModel, newViewModel) {
        newViewModel.onReceiveBranchData(false);
      },
      onInit: (store) {
        final communities = store.state.cashWalletState.communities;
        if (!communities.containsKey(
            '0xAcdC5D3104406aA43Bd0b157a2265097A59B21D2v'.toLowerCase())) {
          store.dispatch(switchCommunityCall(
              '0xAcdC5D3104406aA43Bd0b157a2265097A59B21D2'));
        }
      },
      builder: (_, viewModel) {
        return Scaffold(
          appBar: MyAppBar(
            height: 182,
            child: CashHeader(),
          ),
          body: refreshIndicator(viewModel),
        );
      },
    );
  }
}
