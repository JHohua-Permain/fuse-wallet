import 'package:equatable/equatable.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/models/community/community.dart';
import 'package:fusecash/redux/actions/swap_actions.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:redux/redux.dart';

class HomeScreenViewModel extends Equatable {
  final Community community;
  final bool isContactsSynced;
  final bool backup;
  final bool isBackupDialogShowed;
  final Function setShowDialog;
  final Function getSwapList;

  HomeScreenViewModel({
    this.isContactsSynced,
    this.community,
    this.backup,
    this.isBackupDialogShowed,
    this.setShowDialog,
    this.getSwapList
  });

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    String communityAddress = store.state.cashWalletState.communityAddress;
    Community community =
        store.state.cashWalletState.communities[communityAddress] ??
            Community();
    return HomeScreenViewModel(
      isContactsSynced: store.state.userState.isContactsSynced,
      community: community,
      backup: store.state.userState.backup,
      isBackupDialogShowed:
          store.state.userState?.receiveBackupDialogShowed ?? false,
      setShowDialog: () {
        store.dispatch(ReceiveBackupDialogShowed());
      },
      getSwapList: () {
        store.dispatch(fetchSwapList());
      },
    );
  }

  @override
  List<Object> get props => [
        community,
        isContactsSynced,
        backup,
        isContactsSynced,
      ];
}