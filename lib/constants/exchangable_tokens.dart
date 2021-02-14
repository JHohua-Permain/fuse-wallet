import 'package:fusecash/constants/addresses.dart';
import 'package:fusecash/models/tokens/token.dart';
import 'package:fusecash/utils/images.dart';

final Token _daiToken = Token(
  address: '0x6B175474E89094C44Da98b954EedeAC495271d0F',
  decimals: 18,
  imageUrl: ImageUrl.getTokenUrl('0x6B175474E89094C44Da98b954EedeAC495271d0F'),
  name: "Dai Stablecoin",
  subtitle: 'US dollar',
  amount: BigInt.zero,
  symbol: "DAI",
);

final _dzarToken = Token(
  symbol: "DZAR",
  name: "Digital Rand",
  amount: BigInt.zero,
  decimals: 6,
  subtitle: 'South Africa',
  imageUrl: ImageUrl.getTokenUrl('0x9Cb2f26A23b8d89973F08c957C4d7cdf75CD341c'),
  address: "0x9Cb2f26A23b8d89973F08c957C4d7cdf75CD341c",
);

final _usdcToken = Token(
  symbol: "USDC",
  name: "USD Coin",
  decimals: 6,
  subtitle: 'US dollar',
  imageUrl: ImageUrl.getTokenUrl('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'),
  address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
);

final _tetherToken = Token(
  symbol: "USDT",
  name: "Tether USD",
  amount: BigInt.zero,
  decimals: 6,
  subtitle: 'US dollar',
  imageUrl: ImageUrl.getTokenUrl('0xdAC17F958D2ee523a2206206994597C13D831ec7'),
  address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
);

final _trueUSDToken = Token(
  symbol: "TUSD",
  name: "TrueUSD",
  amount: BigInt.zero,
  decimals: 18,
  subtitle: 'US dollar',
  imageUrl: ImageUrl.getTokenUrl('0x0000000000085d4780B73119b644AE5ecd22b376'),
  address: "0x0000000000085d4780B73119b644AE5ecd22b376",
);

final _eursToken = Token(
  symbol: "EURS",
  name: "STASIS EURS Token",
  amount: BigInt.zero,
  decimals: 2,
  subtitle: 'Europe',
  imageUrl: ImageUrl.getTokenUrl('0xdB25f211AB05b1c97D595516F45794528a807ad8'),
  address: "0xdB25f211AB05b1c97D595516F45794528a807ad8",
);

final _rupiahToken = Token(
  symbol: "IDRT",
  name: "Rupiah Token",
  amount: BigInt.zero,
  decimals: 2,
  subtitle: 'Indonesia',
  imageUrl: ImageUrl.getTokenUrl('0x998FFE1E43fAcffb941dc337dD0468d52bA5b48A'),
  address: "0x998FFE1E43fAcffb941dc337dD0468d52bA5b48A",
);

final _etherToken = Token(
  symbol: "ETH",
  amount: BigInt.zero,
  name: "Ether",
  decimals: 18,
  imageUrl: ImageUrl.getTokenUrl(Addresses.ZERO_ADDRESS),
  address: Addresses.ZERO_ADDRESS,
);

// final Token _wbtcToken = Token(
//     address: '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
//     decimals: 8,
//     imageUrl: ImageUrl.getTokenUrl('0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599'),
//     name: "Wrapped BTC",
//     amount: BigInt.zero,
//     symbol: "WBTC");

final Map<String, Token> exchangableTokens = new Map<String, Token>.from({
  _etherToken.address: _etherToken,
  _daiToken.address: _daiToken,
  _usdcToken.address: _usdcToken,
  _tetherToken.address: _tetherToken,
  _trueUSDToken.address: _trueUSDToken,
  _eursToken.address: _eursToken,
  _dzarToken.address: _dzarToken,
  _rupiahToken.address: _rupiahToken,
  // _wbtcToken.address: _wbtcToken,
});

final dollarPeggedToken = [
  _daiToken.address.toLowerCase(),
  _usdcToken.address.toLowerCase(),
  _tetherToken.address.toLowerCase(),
  _trueUSDToken.address.toLowerCase(),
  _eursToken.address.toLowerCase()
];