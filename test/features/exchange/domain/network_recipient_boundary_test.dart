import 'package:primitives/primitives.dart' show BitcoinUnit;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bb_mobile/core/settings/data/settings_repository.dart';
import 'package:bb_mobile/features/settings/domain/settings_entity.dart';
import 'package:bb_mobile/core/exchange/domain/entity/default_wallet.dart';
import 'package:bb_mobile/core/exchange/domain/repositories/exchange_recipient_repository.dart';
import 'package:bb_mobile/features/exchange/domain/usecases/save_default_wallet_usecase.dart';
import 'package:bb_mobile/features/exchange/domain/usecases/delete_default_wallet_usecase.dart';

class SettingsMock extends Mock implements SettingsRepository {}

class RecipientsMock extends Mock implements ExchangeRecipientRepository {}

void main() {
  for (final environment in [Environment.mainnet, Environment.testnet]) {
    test('default wallet writes retain ${environment.name} backend', () async {
      final settings = SettingsMock();
      final mainnet = RecipientsMock();
      final testnet = RecipientsMock();
      final selected = environment == Environment.mainnet ? mainnet : testnet;
      final other = environment == Environment.mainnet ? testnet : mainnet;
      when(() => settings.fetch()).thenAnswer(
        (_) async => SettingsEntity(
          environment: environment,
          bitcoinUnit: BitcoinUnit.sats,
          currencyCode: 'CAD',
        ),
      );
      when(
        () => selected.saveDefaultWallet(
          walletType: WalletAddressType.bitcoin,
          address: 'destination',
          existingRecipientId: null,
        ),
      ).thenAnswer(
        (_) async => const DefaultWallet(
          walletType: WalletAddressType.bitcoin,
          address: 'destination',
        ),
      );
      when(
        () => selected.deleteDefaultWallet(
          walletType: WalletAddressType.bitcoin,
          address: 'destination',
          recipientId: 'recipient',
        ),
      ).thenAnswer((_) async {});
      await SaveDefaultWalletUsecase(
        mainnetRepository: mainnet,
        testnetRepository: testnet,
        settingsRepository: settings,
      ).execute(walletType: WalletAddressType.bitcoin, address: 'destination');
      await DeleteDefaultWalletUsecase(
        mainnetRepository: mainnet,
        testnetRepository: testnet,
        settingsRepository: settings,
      ).execute(
        walletType: WalletAddressType.bitcoin,
        address: 'destination',
        recipientId: 'recipient',
      );
      verify(
        () => selected.saveDefaultWallet(
          walletType: WalletAddressType.bitcoin,
          address: 'destination',
          existingRecipientId: null,
        ),
      ).called(1);
      verify(
        () => selected.deleteDefaultWallet(
          walletType: WalletAddressType.bitcoin,
          address: 'destination',
          recipientId: 'recipient',
        ),
      ).called(1);
      verifyZeroInteractions(other);
    });
  }
}
