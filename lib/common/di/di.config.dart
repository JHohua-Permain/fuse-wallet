// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:dio/dio.dart' as _i4;
import 'package:firebase_analytics/firebase_analytics.dart' as _i7;
import 'package:firebase_auth/firebase_auth.dart' as _i9;
import 'package:firebase_core/firebase_core.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:logger/logger.dart' as _i13;
import 'package:package_info/package_info.dart' as _i15;
import 'package:phone_number/phone_number.dart' as _i16;
import 'package:wallet_core/wallet_core.dart' as _i3;

import '../../services/apis/exchange.dart' as _i5;
import '../../services/apis/explorer.dart' as _i6;
import '../../services/apis/funder.dart' as _i10;
import '../../services/apis/fuseswap.dart' as _i11;
import '../../services/apis/market.dart' as _i14;
import '../../utils/log/log_it.dart' as _i17;
import '../../utils/onboard/Istrategy.dart' as _i12;
import '../network/services.dart' as _i18;
import '../network/web3.dart' as _i25;
import 'dio.dart' as _i19;
import 'firebase.dart' as _i20;
import 'logger_di.dart' as _i22;
import 'onboard.dart' as _i21;
import 'package_info.dart' as _i23;
import 'phone.dart' as _i24; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
Future<_i1.GetIt> $initGetIt(_i1.GetIt get,
    {String environment, _i2.EnvironmentFilter environmentFilter}) async {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final servicesModule = _$ServicesModule();
  final dioDi = _$DioDi();
  final firebaseInjectableModule = _$FirebaseInjectableModule();
  final onBoardStrategy = _$OnBoardStrategy();
  final loggerDi = _$LoggerDi();
  final packageInfoDi = _$PackageInfoDi();
  final phone = _$Phone();
  final web3Di = _$Web3Di();
  gh.lazySingleton<_i3.API>(() => servicesModule.api);
  gh.factory<_i4.Dio>(() => dioDi.dio);
  gh.lazySingleton<_i5.Exchange>(() => _i5.Exchange(get<_i4.Dio>()));
  gh.factoryParam<_i6.Explorer, String, String>(
      (base, apiKey) => _i6.Explorer(get<_i4.Dio>(), base, apiKey));
  gh.factory<_i7.FirebaseAnalytics>(
      () => firebaseInjectableModule.firebaseAnalytics);
  await gh.factoryAsync<_i8.FirebaseApp>(
      () => firebaseInjectableModule.firebaseApp,
      preResolve: true);
  gh.lazySingleton<_i9.FirebaseAuth>(
      () => firebaseInjectableModule.firebaseAuth);
  gh.lazySingleton<_i10.Funder>(() => _i10.Funder(get<_i4.Dio>()));
  gh.lazySingleton<_i11.FuseSwapService>(
      () => _i11.FuseSwapService(get<_i4.Dio>()));
  gh.lazySingleton<_i3.Graph>(() => servicesModule.graph);
  gh.lazySingleton<_i12.IOnBoardStrategy>(
      () => onBoardStrategy.onBoardStrategy);
  gh.lazySingleton<_i13.Logger>(() => loggerDi.logger);
  gh.lazySingleton<_i14.Market>(() => _i14.Market(get<_i4.Dio>()));
  await gh.factoryAsync<_i15.PackageInfo>(() => packageInfoDi.packageInfo,
      preResolve: true);
  gh.lazySingleton<_i16.PhoneNumberUtil>(() => phone.phoneNumberUtil);
  gh.factory<String>(() => web3Di.defaultCommunityAddress,
      instanceName: 'defaultCommunityAddress');
  gh.factoryParam<_i3.Web3, Map<dynamic, dynamic>, dynamic>(
      (walletModules, _) => web3Di.fuseWeb3(
          get<String>(instanceName: 'defaultCommunityAddress'), walletModules),
      instanceName: 'fuseWeb3');
  gh.factoryParam<_i3.Web3, Map<dynamic, dynamic>, dynamic>(
      (walletModules, _) => web3Di.ethereumWeb3(
          get<String>(instanceName: 'defaultCommunityAddress'), walletModules),
      instanceName: 'ethereumWeb3');
  gh.lazySingleton<_i17.LogIt>(() => _i17.LogIt(get<_i13.Logger>()));
  return get;
}

class _$ServicesModule extends _i18.ServicesModule {}

class _$DioDi extends _i19.DioDi {}

class _$FirebaseInjectableModule extends _i20.FirebaseInjectableModule {}

class _$OnBoardStrategy extends _i21.OnBoardStrategy {}

class _$LoggerDi extends _i22.LoggerDi {}

class _$PackageInfoDi extends _i23.PackageInfoDi {}

class _$Phone extends _i24.Phone {}

class _$Web3Di extends _i25.Web3Di {}
