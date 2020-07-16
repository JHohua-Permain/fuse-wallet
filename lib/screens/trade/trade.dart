import 'dart:core';
import 'package:digitalrand/models/community/community.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:digitalrand/redux/state/store.dart';
import 'package:digitalrand/services.dart';
import 'package:redux/redux.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:ethereum_address/ethereum_address.dart';
import 'package:digitalrand/screens/trade/review_trade.dart';
import 'package:digitalrand/screens/pro_mode/assets_list.dart';
import 'package:digitalrand/utils/debouncer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:digitalrand/constans/exchangable_tokens.dart';
import 'package:digitalrand/generated/i18n.dart';
import 'package:digitalrand/models/app_state.dart';
import 'package:digitalrand/models/tokens/token.dart';
import 'package:digitalrand/screens/trade/card.dart';
import 'package:digitalrand/utils/format.dart';
import 'package:digitalrand/widgets/main_scaffold.dart';
import 'package:digitalrand/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_segment/flutter_segment.dart';

class TradeScreen extends StatefulWidget {
  final Token primaryToken;
  const TradeScreen({Key key, this.primaryToken}) : super(key: key);

  @override
  _ExchangeState createState() => _ExchangeState();
}

class _ExchangeState extends State<TradeScreen> {
  TextEditingController receiveController = TextEditingController();
  TextEditingController payWithController = TextEditingController();
  Token tokenToPayWith;
  Token tokenToReceive;
  final _payWithDebouncer = Debouncer(milliseconds: 1000);
  final _receiveDebouncer = Debouncer(milliseconds: 1000);
  bool isFetchingPayWith = false;
  Map swapResponse;
  Map transactionsResponse;
  bool isFetchingReceive = false;
  bool isSwap = false;
  bool isFetchingPrice = true;
  String fromTokenAmountPay;
  String fromTokenAmountReceive;
  String toTokenAmountPay;
  String toTokenAmountReceive;

  @override
  void dispose() {
    payWithController.dispose();
    receiveController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Segment.screen(screenName: '/trade-screen');
    super.initState();
  }

  void onPayWithDropDownChanged(Token token, walletAddress) {
    setState(() {
      tokenToPayWith = token;
    });
    fetchPrices(walletAddress, token, tokenToReceive);
  }

  void onReceiveDropDownChanged(Token token, walletAddress) {
    setState(() {
      tokenToReceive = token;
    });
    fetchPrices(walletAddress, token, tokenToPayWith);
  }

  void getQuateForPayWith(String value, String walletAddress) async {
    try {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          isFetchingPayWith = true;
        });
      }
      if (value.isEmpty) {
        if (this.mounted) {
          setState(() {
            swapResponse = null;
            receiveController.text = '';
            isFetchingPayWith = false;
          });
        }
        return;
      }
      dynamic response = await fetchSwap(
          walletAddress, tokenToPayWith.address, tokenToReceive.address,
          sourceAmount: toBigInt(value, tokenToPayWith.decimals).toString(),
          transactions: true,
          skipBalanceChecks: false);
      String toTokenAmount = formatValue(
          BigInt.from(num.parse(response['destinationAmount'])),
          tokenToReceive.decimals,
          withPrecision: true);
      if (this.mounted) {
        response['amount'] = num.parse(value);
        response['amountIn'] = num.parse(formatValue(
            BigInt.from(num.parse(response['destinationAmount'])),
            tokenToReceive.decimals,
            withPrecision: true));
        setState(() {
          receiveController.text = toTokenAmount;
          isFetchingPayWith = false;
          swapResponse = response;
        });
      }
    } catch (error) {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          isFetchingPayWith = false;
        });
      }
    }
  }

  void getQuateForReceive(String value, String walletAddress) async {
    try {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          isFetchingReceive = true;
        });
      }
      if (value.isEmpty) {
        if (this.mounted) {
          setState(() {
            swapResponse = null;
            payWithController.text = '';
            isFetchingReceive = false;
          });
        }
        return;
      }
      dynamic response = await fetchSwap(
          walletAddress, tokenToReceive.address, tokenToPayWith.address,
          sourceAmount: toBigInt(value, tokenToReceive.decimals).toString(),
          transactions: true,
          skipBalanceChecks: false);
      response['amount'] = num.parse(value);
      response['amountIn'] = num.parse(formatValue(
          BigInt.from(num.parse(response['destinationAmount'])),
          tokenToReceive.decimals,
          withPrecision: true));
      String fromTokenAmount = formatValue(
          BigInt.from(num.parse(response['destinationAmount'])),
          tokenToPayWith.decimals,
          withPrecision: true);
      if (this.mounted) {
        setState(() {
          swapResponse = response;
          payWithController.text = fromTokenAmount;
          isFetchingReceive = false;
        });
      }
    } catch (error) {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          isFetchingReceive = false;
        });
      }
    }
  }

  List<DropdownMenuItem<Token>> _buildItems(List<Token> tokens) {
    return tokens.map((Token token) {
      return DropdownMenuItem<Token>(
        value: token,
        child: Row(
          children: <Widget>[
            CachedNetworkImage(
              width: 33,
              height: 33,
              imageUrl: token.imageUrl != null && token.imageUrl.isNotEmpty
                  ? token.imageUrl
                  : getTokenUrl(checksumEthereumAddress(token.address)),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(
                Icons.error,
                size: 18,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              token.symbol,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      );
    }).toList();
  }

  void swap() {
    if (this.mounted) {
      Token tokenPayWith = tokenToPayWith;
      Token tokenReceive = tokenToReceive;
      setState(() {
        isSwap = !isSwap;
        tokenToPayWith = tokenReceive;
        tokenToReceive = tokenPayWith;
      });
    }
  }

  void fetchPrices(
      String walletAddress, Token soureToken, Token destinationToken) async {
    try {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          payWithController.text = '';
          receiveController.text = '';
          fromTokenAmountPay = null;
          toTokenAmountPay = null;
          fromTokenAmountReceive = null;
          toTokenAmountReceive = null;
          isFetchingPrice = true;
        });
      }
      List<Future> futures = <Future>[];
      futures.add(fetchSwap(
          walletAddress, soureToken.address, destinationToken.address,
          sourceAmount:
              toBigInt(num.parse('1'), soureToken.decimals).toString()));
      futures.add(fetchSwap(
          walletAddress, destinationToken.address, soureToken.address,
          sourceAmount:
              toBigInt(num.parse('1'), destinationToken.decimals).toString()));
      List res = await Future.wait(futures);
      Map paywithResponse = res[0];
      Map receiceResponse = res[1];
      String fromTokenPay = formatValue(
          BigInt.from(num.parse(paywithResponse['sourceAmount'])),
          soureToken.decimals);
      String toTokenPay = formatValue(
          BigInt.from(num.parse(paywithResponse['destinationAmount'])),
          destinationToken.decimals);
      String fromTokenReceive = formatValue(
          BigInt.from(num.parse(receiceResponse['sourceAmount'])),
          destinationToken.decimals);
      String toTokenReceive = formatValue(
          BigInt.from(num.parse(receiceResponse['destinationAmount'])),
          soureToken.decimals);
      if (this.mounted) {
        setState(() {
          fromTokenAmountPay = fromTokenPay;
          toTokenAmountPay = toTokenPay;
          isFetchingPrice = false;
          fromTokenAmountReceive = fromTokenReceive;
          toTokenAmountReceive = toTokenReceive;
        });
      }
    } catch (e) {
      if (this.mounted) {
        setState(() {
          swapResponse = null;
          fromTokenAmountPay = null;
          toTokenAmountPay = null;
          isFetchingPrice = false;
          fromTokenAmountReceive = null;
          toTokenAmountReceive = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ExchangeViewModel>(
        distinct: true,
        converter: _ExchangeViewModel.fromStore,
        onInitialBuild: (viewModel) {
          final Token ethToken = viewModel.tokens
              ?.firstWhere((element) => element.symbol == 'ETH');
          final Token dzarToken = viewModel.tokens
              ?.firstWhere((element) => element.symbol == 'DZAR');
          final Token dai = viewModel.tokens
              ?.firstWhere((element) => element.symbol == 'DAI');
          final Token payWithToken = widget?.primaryToken ??
              (ethToken == viewModel.tokens[0]
                  ? dzarToken
                  : viewModel.tokens[0]);
          fetchPrices(viewModel.walletAddress, payWithToken, dai);
          setState(() {
            tokenToPayWith = payWithToken;
            tokenToReceive = dai;
          });
        },
        builder: (_, viewModel) {
          final List<DropdownMenuItem<Token>> options =
              _buildItems(viewModel.tokens);
          final Token ethToken =
              viewModel.tokens.firstWhere((element) => element.symbol == 'ETH');
          final Token dzarToken = viewModel.tokens
              .firstWhere((element) => element.symbol == 'DZAR');
          final Token dai =
              viewModel.tokens.firstWhere((element) => element.symbol == 'DAI');
          final Token payWithToken = tokenToPayWith ??
              (ethToken == viewModel.tokens[0]
                  ? dzarToken
                  : viewModel.tokens[0]);
          final Token receiveToken = tokenToReceive ?? dai;
          num value = num.parse(formatValue(
              payWithToken.amount, payWithToken.decimals,
              withPrecision: true));
          bool payWithHasBalance = payWithController.text != null &&
                  payWithController.text.isNotEmpty
              ? value.compareTo(num.parse(payWithController.text ?? 0) ?? 0) !=
                  -1
              : true;
          // num receiveValue = num.parse(
          //     formatValue(receiveToken.amount, receiveToken.decimals, withPrecision: false));
          // bool receiveHasBalance = receiveController.text != null &&
          //         receiveController.text.isNotEmpty
          //     ? receiveValue.compareTo(
          //             num.tryParse(receiveController.text ?? 0) ?? 0) >=
          //         0
          //     : true;
          return MainScaffold(
            expandedHeight: MediaQuery.of(context).size.height / 12,
            automaticallyImplyLeading: false,
            withPadding: true,
            padding: 20.0,
            title: I18n.of(context).trade,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: <Widget>[
                          TradeCard(
                            useMaxWidget: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 15),
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F5F5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              child: InkWell(
                                  onTap: () {
                                    String max = formatValue(
                                        tokenToPayWith.amount,
                                        tokenToPayWith.decimals,
                                        withPrecision: true);
                                    setState(() {
                                      payWithController.text = max;
                                    });
                                    _payWithDebouncer.run(() =>
                                        getQuateForPayWith(
                                            max, viewModel.walletAddress));
                                  },
                                  child: Text(
                                    I18n.of(context).use_max,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                  )),
                            ),
                            fromTokenAmount: isSwap
                                ? fromTokenAmountPay
                                : fromTokenAmountReceive,
                            toTokenAmount: isSwap
                                ? toTokenAmountPay
                                : toTokenAmountReceive,
                            isFetchingPrice: isFetchingPrice,
                            hasBalance: payWithHasBalance,
                            // hasBalance: value == 0
                            //     ? false
                            //     : (isSwap
                            //         ? payWithHasBalance
                            //         : receiveHasBalance),
                            onDropDownChanged: (token) {
                              onPayWithDropDownChanged(
                                  token, viewModel.walletAddress);
                            },
                            items: options,
                            onChanged: (value) {
                              _payWithDebouncer.run(() => getQuateForPayWith(
                                  value, viewModel.walletAddress));
                            },
                            walletAddress: viewModel.walletAddress,
                            textEditingController: payWithController,
                            isFetching: isFetchingReceive,
                            tokenToReceive: receiveToken,
                            token: payWithToken,
                            title: 'Pay with',
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 0, bottom: 0),
                                child: SizedBox(
                                  child: Divider(
                                    thickness: 1.0,
                                    color: Color(0xFFDBDBDB),
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: swap,
                                  child: SvgPicture.asset(
                                    'assets/images/swap_icon.svg',
                                    fit: BoxFit.fill,
                                    width: 40,
                                    height: 40,
                                  ))
                            ],
                          ),
                          TradeCard(
                            fromTokenAmount: isSwap
                                ? fromTokenAmountReceive
                                : fromTokenAmountPay,
                            toTokenAmount: isSwap
                                ? toTokenAmountReceive
                                : toTokenAmountPay,
                            isFetchingPrice: isFetchingPrice,
                            // hasBalance: receiveValue == 0
                            //     ? false
                            //     : (isSwap
                            //         ? receiveHasBalance
                            //         : payWithHasBalance),
                            onDropDownChanged: (token) {
                              onReceiveDropDownChanged(
                                  token, viewModel.walletAddress);
                            },
                            items: options,
                            onChanged: (value) {
                              _receiveDebouncer.run(() => getQuateForReceive(
                                  value, viewModel.walletAddress));
                            },
                            walletAddress: viewModel.walletAddress,
                            textEditingController: receiveController,
                            isFetching: isFetchingPayWith,
                            tokenToReceive: payWithToken,
                            token: receiveToken,
                            title: 'Receive',
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
            footer: Center(
              child: PrimaryButton(
                labelFontWeight: FontWeight.normal,
                label: I18n.of(context).trade,
                fontSize: 15,
                disabled: swapResponse == null ||
                    (swapResponse != null && swapResponse['tx'] == null),
                onPressed: () async {
                  if (swapResponse != null && swapResponse['tx'] != null) {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => ReviewTradeScreen(
                                  fromToken: tokenToPayWith.copyWith(),
                                  toToken: tokenToReceive.copyWith(),
                                  exchangeSummry: swapResponse,
                                )));
                  }
                },
              ),
            ),
          );
        });
  }
}

class _ExchangeViewModel extends Equatable {
  final String walletAddress;
  final List<Token> tokens;
  final String homeBridgeAddress;

  _ExchangeViewModel({
    this.walletAddress,
    this.tokens,
    this.homeBridgeAddress,
  });

  static _ExchangeViewModel fromStore(Store<AppState> store) {
    final List<Token> tokens = List<Token>.from(
            store.state.proWalletState.erc20Tokens?.values ?? Iterable.empty())
        .where((Token token) =>
            num.parse(formatValue(token.amount, token.decimals,
                    withPrecision: true))
                .compareTo(0) ==
            1)
        .toList()
        .reversed
        .toList();
    final List<Token> exchangable = exchangableTokens.values.toList()
      ..removeWhere((Token token) {
        dynamic foundToken = tokens.firstWhere(
            (element) =>
                element.address.toLowerCase() == token.address.toLowerCase(),
            orElse: () => null);
        if (foundToken != null) {
          return true;
        } else
          return false;
      });
    Community community = store.state.cashWalletState.communities.values.first;
    return _ExchangeViewModel(
      homeBridgeAddress: community.homeBridgeAddress,
      walletAddress: store.state.userState.walletAddress,
      tokens: [...tokens, ...exchangable].toSet().toList(),
    );
  }

  @override
  List<Object> get props => [walletAddress, tokens];
}

Future<dynamic> fetchSwap(
    String walletAddress, String fromTokenAddress, String toTokenAddress,
    {String sourceAmount,
    String destinationAmount,
    bool transactions = false,
    bool skipBalanceChecks = true}) async {
  final logger = await AppFactory().getLogger('action');
  try {
    if (fromTokenAddress != null &&
        fromTokenAddress.isNotEmpty &&
        toTokenAddress != null &&
        toTokenAddress.isNotEmpty) {
      Map apiOptions = Map.from({
        'apiKey': DotEnv().env['TOTLE_API_KEY'],
        'swap': {
          'sourceAsset': fromTokenAddress,
          'destinationAsset': toTokenAddress,
        },
        'config': {
          'transactions': transactions,
          'skipBalanceChecks': skipBalanceChecks
        }
      });
      if (sourceAmount != null && sourceAmount.isNotEmpty) {
        apiOptions['swap']['sourceAmount'] = sourceAmount;
      }
      if (destinationAmount != null && destinationAmount.isNotEmpty) {
        apiOptions['swap']['destinationAmount'] = destinationAmount;
      }
      Map<String, dynamic> response =
          await exchangeApi.swap(walletAddress, options: apiOptions);
      bool success = response['success'] ?? false;
      if (success) {
        if (response['response'].containsKey('transactions')) {
          dynamic swapData = List.from(response['response']['transactions'])
              .firstWhere((element) => element['type'] == 'swap', orElse: null);
          if (swapData != null) {
            return Map.from(
                {...response['response']['summary'][0], 'tx': swapData['tx']});
          } else {
            return Map.from({...response['response']['summary'][0]});
          }
        } else {
          return Map.from({...response['response']['summary'][0]});
        }
      }
      throw response;
    }
    throw 'Error fromTokenAddress and toTokenAddress are empty';
  } catch (error) {
    logger.severe('ERROR in fetchSwap - ${error.toString()}');
    // throw error;
  }
}
