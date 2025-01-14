import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:redux/redux.dart';

class SplashViewModel extends Equatable {
  final String privateKey;
  final String jwtToken;
  final bool isLoggedOut;
  final Function() loginAgain;

  final Function(VoidCallback successCallback, VoidCallback errorCallback)
      createLocalAccount;

  SplashViewModel({
    this.privateKey,
    this.jwtToken,
    this.isLoggedOut,
    this.createLocalAccount,
    this.loginAgain,
  });

  static SplashViewModel fromStore(Store<AppState> store) {
    return SplashViewModel(
        privateKey: store.state.userState.privateKey,
        jwtToken: store.state.userState.jwtToken,
        isLoggedOut: store.state.userState.isLoggedOut ?? false,
        createLocalAccount:
            (VoidCallback successCallback, VoidCallback errorCallback) {
          store
              .dispatch(createLocalAccountCall(successCallback, errorCallback));
        },
        loginAgain: () {
          store.dispatch(reLoginCall());
        });
  }

  @override
  List<Object> get props => [privateKey, jwtToken, isLoggedOut];
}
