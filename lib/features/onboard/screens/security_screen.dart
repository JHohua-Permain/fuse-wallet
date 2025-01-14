import 'package:auto_route/auto_route.dart';
import 'package:flutter_segment/flutter_segment.dart';
import 'package:fusecash/constants/enums.dart';
import 'package:fusecash/common/router/routes.gr.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fusecash/features/home/screens/set_up_pincode.dart';
import 'package:fusecash/redux/actions/user_actions.dart';
import 'package:fusecash/utils/biometric_local_auth.dart';
import 'package:fusecash/widgets/my_scaffold.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fusecash/generated/i18n.dart';
import 'package:fusecash/models/app_state.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  BiometricAuth _biometricType;

  Future<void> _checkBiometrical() async {
    _biometricType = await BiometricUtils.getAvailableBiometrics();
    if (_biometricType != BiometricAuth.none) {
      setState(() {
        _biometricType = _biometricType;
      });
    }
  }

  @override
  void initState() {
    Segment.screen(screenName: '/choose-lock-method-screen');
    _checkBiometrical();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: I18n.of(context).protect_wallet,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: <Widget>[
                SizedBox(
                  height: 30,
                ),
                SvgPicture.asset('assets/images/lock.svg'),
                SizedBox(
                  height: 30,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    I18n.of(context).choose_lock_method,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                )
              ],
            ),
            Column(
              children: [
                StoreConnector<AppState, _SecurityViewModel>(
                  distinct: true,
                  converter: _SecurityViewModel.fromStore,
                  builder: (_, viewModel) {
                    return Container(
                      padding: EdgeInsets.only(top: 20, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 20.0),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              InkWell(
                                focusColor: Theme.of(context).canvasColor,
                                highlightColor: Theme.of(context).canvasColor,
                                child: Container(
                                    height: 60,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    width:
                                        MediaQuery.of(context).size.width * .8,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(11.0)),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            SvgPicture.asset(
                                                'assets/images/${BiometricAuth.faceID == _biometricType ? 'face_id' : 'fingerprint'}.svg'),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              BiometricUtils.getBiometricString(
                                                  _biometricType),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SvgPicture.asset(
                                              'assets/images/info_black.svg',
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Text(
                                              I18n.of(context).recommended,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                            ),
                                          ],
                                        )
                                      ],
                                    )),
                                onTap: () async {
                                  final String biometric =
                                      BiometricUtils.getBiometricString(
                                          _biometricType);

                                  await BiometricUtils
                                      .showDefaultPopupCheckBiometricAuth(
                                    message: 'Please use $biometric to unlock!',
                                    callback: (bool result) {
                                      if (result) {
                                        viewModel
                                            .setSecurityType(_biometricType);
                                        ExtendedNavigator.root.popUntilRoot();
                                        ExtendedNavigator.root
                                            .replace(Routes.homeScreen);
                                      }
                                    },
                                  );
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                focusColor: Theme.of(context).canvasColor,
                                highlightColor: Theme.of(context).canvasColor,
                                child: Container(
                                  height: 60,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  width: MediaQuery.of(context).size.width * .8,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(11.0)),
                                    color: Color(0xFFF7F7F7),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Row(children: [
                                    SvgPicture.asset(
                                        'assets/images/pincode.svg',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(I18n.of(context).pincode,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface))
                                  ]),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SetUpPinCodeScreen(
                                        onSuccess: () {
                                          ExtendedNavigator.root.popUntilRoot();
                                          ExtendedNavigator.root
                                              .replace(Routes.homeScreen);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SecurityViewModel {
  final Function(BiometricAuth) setSecurityType;
  _SecurityViewModel({this.setSecurityType});

  static _SecurityViewModel fromStore(Store<AppState> store) {
    return _SecurityViewModel(setSecurityType: (biometricAuth) {
      store.dispatch(SetSecurityType(biometricAuth: biometricAuth));
    });
  }
}
