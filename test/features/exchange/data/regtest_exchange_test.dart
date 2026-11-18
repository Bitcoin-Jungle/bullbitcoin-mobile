import 'dart:typed_data';

import 'package:bb_mobile/core/exchange/data/exchange_api_key_repository_impl.dart';
import 'package:bb_mobile/core/exchange/data/http/exchange_authentication_interceptor.dart';
import 'package:bb_mobile/core/storage/data/datasources/key_value_storage/key_value_storage_datasource.dart';
import 'package:bb_mobile/features/exchange/data/regtest_exchange_auth_repository.dart';
import 'package:bb_mobile/features/exchange/data/regtest_exchange_routing.dart';
import 'package:bb_mobile/features/settings/domain/settings_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primitives/primitives.dart';

final class _Storage implements KeyValueStorageDatasource<String> {
  final values = <String, String>{};

  @override
  Future<void> saveValue({required String key, required String value}) async =>
      values[key] = value;

  @override
  Future<Map<String, String>> getAll() async => values;

  @override
  Future<String?> getValue(String key) async => values[key];

  @override
  Future<bool> hasValue(String key) async => values.containsKey(key);

  @override
  Future<void> deleteValue(String key) async => values.remove(key);
}

/// Records the final URL and key of each request; answers with an empty 200.
final class _Recorder implements HttpClientAdapter {
  final uris = <Uri>[];
  final keys = <Object?>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    uris.add(options.uri);
    keys.add(options.headers['X-API-Key']);
    return ResponseBody.fromString('{}', 200);
  }

  @override
  void close({bool force = false}) {}
}

Dio _client(
  _Recorder recorder,
  Future<NetworkEnv> Function() environment, {
  String baseUrl = 'https://api05.bullbitcoin.dev',
  String? key,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = recorder;
  addRegtestExchangeRouting(dio, environment);
  if (key != null) {
    addExchangeAuthentication(dio, () async => Ok(key));
  }
  addRegtestKeyGuard(dio);
  return dio;
}

void main() {
  group('regtest exchange routing', () {
    test(
      'regtest goes to the simulator on the shared host, keeping the path',
      () async {
        final recorder = _Recorder();
        final dio = _client(
          recorder,
          () async => NetworkEnv.regtest,
          baseUrl: 'https://api05.bullbitcoin.dev/public',
          key: RegtestExchangeProfile.developmentApiKey,
        );

        await dio.post<Object?>('/price');

        expect(
          recorder.uris.single.toString(),
          'http://127.0.0.1:8088/public/price',
        );
        expect(recorder.keys.single, RegtestExchangeProfile.developmentApiKey);
      },
    );

    test('the shared host profile decides the host', () {
      expect(
        RegtestExchangeProfile.baseUri(host: '10.1.2.3').toString(),
        'http://10.1.2.3:8088',
      );
      expect(RegtestExchangeProfile.baseUri().port, 8088);
    });

    test('testnet and mainnet requests are left untouched', () async {
      for (final environment in [NetworkEnv.testnet, NetworkEnv.mainnet]) {
        final recorder = _Recorder();
        final dio = _client(recorder, () async => environment, key: 'real-key');

        await dio.post<Object?>('/price');

        expect(
          recorder.uris.single.toString(),
          'https://api05.bullbitcoin.dev/price',
          reason: environment.name,
        );
        expect(recorder.keys.single, 'real-key');
      }
    });

    test('an unreadable environment fails closed, with no request', () async {
      final recorder = _Recorder();
      final dio = _client(recorder, () async => throw Exception('settings'));

      await expectLater(
        dio.post<Object?>('/price'),
        throwsA(
          isA<DioException>().having(
            (e) => e.error,
            'error',
            isA<RegtestExchangeRoutingException>(),
          ),
        ),
      );
      expect(recorder.uris, isEmpty);
    });

    test('an absolute URL is refused on regtest', () async {
      final recorder = _Recorder();
      final dio = _client(recorder, () async => NetworkEnv.regtest);

      await expectLater(
        dio.post<Object?>('https://api.bullbitcoin.com/price'),
        throwsA(isA<DioException>()),
      );
      expect(recorder.uris, isEmpty);
    });

    test('the development key never leaves toward another host', () async {
      for (final environment in [
        NetworkEnv.testnet,
        NetworkEnv.mainnet,
        NetworkEnv.regtest,
      ]) {
        final recorder = _Recorder();
        // A client that never rebinds: only the guard stands in the way.
        final dio = Dio(BaseOptions(baseUrl: 'https://api05.bullbitcoin.dev'))
          ..httpClientAdapter = recorder;
        addExchangeAuthentication(
          dio,
          () async => const Ok(RegtestExchangeProfile.developmentApiKey),
        );
        addRegtestKeyGuard(dio);

        await expectLater(
          dio.post<Object?>('/price'),
          throwsA(isA<DioException>()),
          reason: environment.name,
        );
        expect(recorder.uris, isEmpty);
      }
    });
  });

  group('regtest credential slot', () {
    test(
      'regtest reads and writes its own credential, never the testnet one',
      () async {
        final storage = _Storage();
        var regtest = false;
        final repository = ExchangeApiKeyRepositoryImpl(
          secureStorage: storage,
          isRegtest: () async => regtest,
        );
        final testnetKey =
            (await const RegtestExchangeAuthRepository().generateApiKey() as Ok)
                .value;

        regtest = true;
        expect(
          await repository.saveApiKey(testnetKey, isTestnet: true),
          isA<Ok>(),
        );
        expect(storage.values.keys, ['exchange_api_key_regtest']);
        expect(
          (await repository.readActiveApiKey(isTestnet: true) as Ok).value,
          RegtestExchangeProfile.developmentApiKey,
        );

        regtest = false;
        expect(
          (await repository.readActiveApiKey(isTestnet: true) as Ok).value,
          isNull,
          reason: 'the testnet slot does not see the regtest credential',
        );
        expect(
          (await repository.readActiveApiKey(isTestnet: false) as Ok).value,
          isNull,
        );
      },
    );

    test('the development account is the fixed key of the simulator', () async {
      final result = await RegtestExchangeAuthRepository(
        now: () => DateTime.utc(2026, 11, 18),
      ).generateApiKey();

      final key = (result as Ok).value;
      expect(key.key, RegtestExchangeProfile.developmentApiKey);
      expect(key.isActive, isTrue);
    });
  });

  test('regtest rides the non-mainnet exchange slot, mainnet never does', () {
    expect(Environment.regtest.exchangeSlotIsTestnet(), isTrue);
    expect(Environment.testnet.exchangeSlotIsTestnet(), isTrue);
    expect(Environment.mainnet.exchangeSlotIsTestnet(), isFalse);
  });
}
