import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fusecash/models/plugins/backup_bonus.dart';
import 'package:fusecash/models/plugins/invite_bonus.dart';
import 'package:fusecash/models/plugins/join_bonus.dart';
import 'package:fusecash/models/plugins/moonpay.dart';
import 'package:fusecash/models/plugins/rampInstant.dart';
import 'package:fusecash/models/plugins/transak.dart';
import 'package:fusecash/models/plugins/wallet_banner.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plugins.freezed.dart';
part 'plugins.g.dart';

WalletBannerPlugin walletBannerFromJson(json) =>
    json == null ? null : WalletBannerPluginConverter().fromJson(json);

JoinBonusPlugin joinBonusPluginFromJson(json) =>
    json == null ? null : JoinBonusPluginConverter().fromJson(json);

BackupBonusPlugin backupBonusPluginFromJson(json) =>
    json == null ? null : BackupBonusPluginConverter().fromJson(json);

InviteBonusPlugin inviteBonusPluginFromJson(json) =>
    json == null ? null : InviteBonusPluginConverter().fromJson(json);

@immutable
@freezed
abstract class Plugins implements _$Plugins {
  const Plugins._();

  @JsonSerializable()
  factory Plugins({
    @nullable @JsonKey(includeIfNull: false) RampInstantPlugin rampInstant,
    @nullable @JsonKey(includeIfNull: false) MoonpayPlugin moonpay,
    @nullable @JsonKey(includeIfNull: false) TransakPlugin transak,
    @nullable
    @JsonKey(includeIfNull: false, fromJson: walletBannerFromJson)
        WalletBannerPlugin walletBanner,
    @nullable
    @JsonKey(includeIfNull: false, fromJson: joinBonusPluginFromJson)
        JoinBonusPlugin joinBonus,
    @nullable
    @JsonKey(includeIfNull: false, fromJson: backupBonusPluginFromJson)
        BackupBonusPlugin backupBonus,
    @nullable
    @JsonKey(includeIfNull: false, fromJson: inviteBonusPluginFromJson)
        InviteBonusPlugin inviteBonus,
  }) = _Plugins;

  factory Plugins.fromJson(dynamic json) => _$PluginsFromJson(json);

  List getDepositPlugins() {
    List depositPlugins = [];
    if (this.rampInstant != null && this.rampInstant.isActive) {
      depositPlugins.add(this.rampInstant);
    }
    if (this.transak != null && this.transak.isActive) {
      depositPlugins.add(this.transak);
    }
    if (this.moonpay != null && this.moonpay.isActive) {
      depositPlugins.add(this.moonpay);
    }
    return depositPlugins;
  }
}

class PluginsConverter implements JsonConverter<Plugins, Map<String, dynamic>> {
  const PluginsConverter();

  @override
  Plugins fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return Plugins();
    } else {
      Map getServicesMap(dynamic json) {
        if (json.containsKey('onramp')) {
          if (json['onramp'].containsKey('services')) {
            return json['onramp']['services'];
          } else {
            return json['onramp'];
          }
        } else {
          return json;
        }
      }

      dynamic services = getServicesMap(json);
      return Plugins(
        moonpay: MoonpayPlugin.fromJson(services["moonpay"] ?? {}),
        rampInstant: RampInstantPlugin.fromJson(services["rampInstant"] ?? {}),
        transak: TransakPlugin.fromJson(services["transak"] ?? {}),
        joinBonus: JoinBonusPluginConverter().fromJson(json['joinBonus'] ?? {}),
        walletBanner:
            WalletBannerPluginConverter().fromJson(json['walletBanner']),
        backupBonus: BackupBonusPluginConverter().fromJson(json['backupBonus']),
        inviteBonus:
            InviteBonusPluginConverter().fromJson(json['inviteBonus'] ?? {}),
      );
    }
  }

  @override
  Map<String, dynamic> toJson(Plugins instance) => instance?.toJson();
}
