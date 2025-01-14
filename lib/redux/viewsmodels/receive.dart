import 'package:equatable/equatable.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:redux/redux.dart';

class ReceiveModel extends Equatable {
  final String walletAddress;
  ReceiveModel({
    this.walletAddress,
  });

  static ReceiveModel fromStore(Store<AppState> store) {
    return ReceiveModel(
      walletAddress:
          store.state.userState?.walletAddress?.replaceFirst('x', 'f') ?? '',
    );
  }

  @override
  List<Object> get props => [
        walletAddress,
      ];
}
