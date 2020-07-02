import 'package:digitalrand/models/jobs/base.dart';
import 'package:digitalrand/models/pro/price.dart';
import 'package:digitalrand/models/tokens/base.dart';
import 'package:digitalrand/models/transactions/transactions.dart';
import 'package:digitalrand/services.dart';
import 'package:digitalrand/utils/format.dart';
import 'package:json_annotation/json_annotation.dart';

part 'token.g.dart';

@JsonSerializable(explicitToJson: true)
class Token extends ERC20Token {
  final String imageUrl;
  final String originNetwork;
  final int timestamp;
  final Price priceInfo;
  @JsonKey(fromJson: _transactionsFromJson)
  final Transactions transactions;
  @JsonKey(name: 'jobs', fromJson: _jobsFromJson, toJson: _jobsToJson)
  final List<Job> jobs;
  @JsonKey(ignore: true)
  final String subtitle;

  static Transactions _transactionsFromJson(Map<String, dynamic> json) =>
      json == null ? Transactions.initial() : Transactions.fromJson(json);

  static List<Job> _jobsFromJson(Map<String, dynamic> json) => json == null
      ? List<Job>()
      : List<Job>.from(json['jobs'].map((job) => JobFactory.create(job)));

  static Map<String, dynamic> _jobsToJson(List<dynamic> jobs) =>
      new Map.from({"jobs": jobs.map((job) => job.toJson()).toList()});

  Token(
      {String address,
      String name,
      String symbol,
      int decimals,
      BigInt amount,
      this.priceInfo,
      this.imageUrl,
      this.subtitle,
      this.timestamp = 0,
      this.transactions,
      this.jobs,
      this.originNetwork})
      : super(
            address: address,
            name: name,
            symbol: symbol,
            decimals: decimals,
            amount: amount);

  Token copyWith(
      {String address,
      String name,
      String symbol,
      String imageUrl,
      int decimals,
      BigInt amount,
      String subtitle,
      int timestamp,
      Price priceInfo,
      String originNetwork,
      Transactions transactions,
      List<Job> jobs}) {
    return Token(
        priceInfo: priceInfo ?? this.priceInfo,
        subtitle: subtitle,
        address: address ?? this.address,
        name: name ?? this.name,
        originNetwork: originNetwork ?? this.originNetwork,
        symbol: symbol ?? this.symbol,
        imageUrl: imageUrl ?? this.imageUrl,
        decimals: decimals ?? this.decimals,
        amount: amount ?? this.amount,
        timestamp: timestamp ?? this.timestamp,
        transactions: transactions ?? this.transactions,
        jobs: jobs ?? this.jobs);
  }

  @override
  Future<dynamic> fetchTokenBalance(String accountAddress,
      {void Function(BigInt) onDone, Function onError}) async {
    if (originNetwork == null) {
      try {
        final BigInt balance = await tokenAPI.getTokenBalanceByAccountAddress(
            this.address, accountAddress);
        if (this.amount.compareTo(balance) != 0) {
          onDone(balance);
        }
      } catch (e, s) {
        onError(e, s);
      }
    } else {
      try {
        final BigInt balance =
            await graph.getTokenBalance(accountAddress, this.address);
        if (this.amount.compareTo(balance) != 0) {
          onDone(balance);
        }
      } catch (e, s) {
        onError(e, s);
      }
    }
  }

  Future<dynamic> fetchTokenLastestPrice(
      {void Function(Price) onDone, Function onError}) async {
    try {
      final String quote = await tokenAPI.getTokenLastestPrice(this.address);
      String total =
          formatValue(this.amount, this.decimals, withPrecision: false);
      if (this.priceInfo == null) {
        Price priceInfo = Price(
            currency: 'usd',
            quote: quote,
            total: (num.parse(total) / num.parse(quote)).toString());
        onDone(priceInfo);
      } else {
        Price priceInfo = this.priceInfo.copyWith(
            quote: quote,
            total: (num.parse(total) / num.parse(quote)).toString());
        onDone(priceInfo);
      }
    } catch (e, s) {
      onError(e, s);
    }
  }

  factory Token.initial() {
    return new Token(
        address: '',
        imageUrl: null,
        name: '',
        amount: BigInt.zero,
        decimals: 0,
        symbol: '',
        timestamp: 0,
        transactions: Transactions.initial(),
        jobs: new List<Job>());
  }

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
