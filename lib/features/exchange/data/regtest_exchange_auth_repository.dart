import 'package:bb_mobile/core/exchange/domain/entity/exchange_api_key.dart';
import 'package:bb_mobile/features/exchange/data/regtest_exchange_routing.dart';
import 'package:bb_mobile/features/exchange/domain/exchange_failure.dart';
import 'package:bb_mobile/features/exchange/domain/repositories/exchange_auth_repository.dart';
import 'package:primitives/primitives.dart';

/// The development account of the regtest simulator: no web login, and a fixed
/// key that [addRegtestKeyGuard] keeps from leaving toward any other host.
final class RegtestExchangeAuthRepository implements ExchangeAuthRepository {
  const RegtestExchangeAuthRepository({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  @override
  Future<Result<ExchangeApiKey, ExchangeFailure>> generateApiKey() async {
    final seconds = _now().millisecondsSinceEpoch ~/ 1000;
    return ExchangeApiKey.create(
      id: 'regtest-development',
      key: RegtestExchangeProfile.developmentApiKey,
      name: 'Regtest development account',
      userId: 'dummy-user',
      isActive: true,
      createdAt: seconds,
      updatedAt: seconds,
    ).mapErr((_) => const ExchangeAuthenticationFailure());
  }
}
