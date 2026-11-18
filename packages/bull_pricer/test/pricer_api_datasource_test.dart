import 'package:bull_pricer/src/data/datasources/pricer_api_datasource.dart';
import 'package:bull_pricer/src/domain/entities/price_history_interval.dart';
import 'package:bull_pricer/src/domain/entities/supported_currency.dart';
import 'package:dio/dio.dart';
import 'package:primitives/primitives.dart';
import 'package:test/test.dart';

import 'fake_price_api.dart';

// A real `getRate` answer from api05 (2026-10-22).
final _getRateAnswer = element({
  'fromCurrency': 'BTC',
  'toCurrency': 'CAD',
  'price': 11228945,
  'priceCurrency': 'CAD',
  'precision': 2,
  'indexPrice': 11424220,
  'createdAt': '2026-10-22T16:31:08.709Z',
});

void main() {
  late FakePriceApi api;
  const datasource = PricerApiDatasource();
  const mainnet = BitcoinNetwork.mainnet;

  setUp(() async => api = await FakePriceApi.start());
  tearDown(() => api.close());

  group('requests', () {
    test('indexPrice asks getRate from BTC, without the API key', () async {
      api.respond = (_) => _getRateAnswer;

      final response = await datasource.indexPrice(
        mainnet,
        SupportedCurrency.cad,
      );

      expect(response.indexPrice(), closeTo(114242.20, 1e-9));
      final request = api.requests.single;
      expect(request.method, 'getRate');
      expect(request.params, {'fromCurrency': 'BTC', 'toCurrency': 'CAD'});
      expect(request.apiKey, isNull);
    });
  });

  group('price history', () {
    final from = DateTime.utc(2026, 8, 6);
    final to = DateTime.utc(2026, 11, 4);

    test(
      'asks getIndexRateHistory for the window, without the API key',
      () async {
        await datasource.indexPriceHistory(
          mainnet,
          SupportedCurrency.cad,
          PriceHistoryInterval.day,
          from: from,
          to: to,
        );

        final request = api.requests.single;
        expect(request.method, 'getIndexRateHistory');
        expect(request.params, {
          'fromCurrency': 'BTC',
          'toCurrency': 'CAD',
          'interval': 'day',
          'fromDate': '${from.millisecondsSinceEpoch}',
          'toDate': '${to.millisecondsSinceEpoch}',
        });
        expect(request.apiKey, isNull);
        expect(request.host, 'api.bullbitcoin.com');
      },
    );

    test('names the 15-minute interval as the API does', () async {
      await datasource.indexPriceHistory(
        BitcoinNetwork.testnet,
        SupportedCurrency.cad,
        PriceHistoryInterval.fifteenMinutes,
        from: from,
        to: to,
      );

      expect(api.requests.single.params['interval'], 'fifteen');
      expect(api.requests.single.host, 'api05.bullbitcoin.dev');
    });

    test('a JSON-RPC error is a FormatException', () async {
      api.respond = (_) => (
        status: 200,
        body: const {
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': -32000, 'message': 'Server error'},
        },
      );

      await expectLater(
        datasource.indexPriceHistory(
          mainnet,
          SupportedCurrency.cad,
          PriceHistoryInterval.day,
          from: from,
          to: to,
        ),
        throwsFormatException,
      );
    });
  });

  group('networks', () {
    test('mainnet asks api.bullbitcoin.com', () async {
      await datasource.indexPrice(mainnet, SupportedCurrency.cad);

      expect(api.requests.single.host, 'api.bullbitcoin.com');
    });

    test('testnet asks api05.bullbitcoin.dev', () async {
      await datasource.indexPrice(
        BitcoinNetwork.testnet,
        SupportedCurrency.cad,
      );

      expect(api.requests.single.host, 'api05.bullbitcoin.dev');
    });

    test(
      'regtest asks the stack simulator on its port, never a Bull host',
      () async {
        await datasource.indexPrice(
          BitcoinNetwork.regtest,
          SupportedCurrency.cad,
        );
        await datasource.indexPriceHistory(
          BitcoinNetwork.regtest,
          SupportedCurrency.cad,
          PriceHistoryInterval.day,
          from: DateTime.utc(2026, 8, 6),
          to: DateTime.utc(2026, 11, 4),
        );

        expect(api.requests.map((r) => r.host).toSet(), {'127.0.0.1'});
        expect(api.requests.map((r) => r.port).toSet(), {8088});
      },
    );

    test('regtest follows the shared regtest host profile', () async {
      await const PricerApiDatasource(regtestHost: '10.1.2.3')
          .indexPrice(BitcoinNetwork.regtest, SupportedCurrency.cad);

      expect(api.requests.single.host, '10.1.2.3');
      expect(api.requests.single.port, 8088);
    });

    test('a network without a price service is never asked', () async {
      await expectLater(
        datasource.indexPrice(BitcoinNetwork.signet, SupportedCurrency.cad),
        throwsA(isA<PricerUnsupportedNetworkException>()),
      );
      expect(api.requests, isEmpty);
    });
  });

  group('errors', () {
    test('HTTP 429 surfaces as a DioException with its status', () async {
      api.respond = (_) => (status: 429, body: const <String, Object>{});

      await expectLater(
        datasource.indexPrice(mainnet, SupportedCurrency.cad),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            429,
          ),
        ),
      );
    });

    test('a JSON-RPC error is a FormatException', () async {
      api.respond = (_) => (
        status: 200,
        body: const {
          'jsonrpc': '2.0',
          'id': 1,
          'error': {'code': -32000, 'message': 'Server error'},
        },
      );

      await expectLater(
        datasource.indexPrice(mainnet, SupportedCurrency.cad),
        throwsFormatException,
      );
    });

    test('an answer without a price is a FormatException', () async {
      api.respond = (_) => (status: 200, body: const {'jsonrpc': '2.0'});

      await expectLater(
        datasource.indexPrice(mainnet, SupportedCurrency.cad),
        throwsFormatException,
      );
    });
  });
}
