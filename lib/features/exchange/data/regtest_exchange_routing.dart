import 'package:dio/dio.dart';
import 'package:primitives/primitives.dart';

/// The only exchange a regtest session may talk to: the development simulator
/// on the shared regtest host. The fake key below means nothing anywhere else.
abstract final class RegtestExchangeProfile {
  static const simulatorPort = 8088;

  /// Accepted by the simulator, refused by every real Bull server.
  static const developmentApiKey = 'regtest-exchange-development-key';

  /// Fixed to the shared host profile; there is no way to pass another URL.
  /// Throws [ArgumentError] on a build without a configured regtest host.
  static Uri baseUri({String? host}) => Uri(
    scheme: 'http',
    host: host ?? RegtestHostProfile.forNetwork(NetworkEnv.regtest)!.host,
    port: simulatorPort,
  );

  /// [baseUri], or null when this build has no regtest host.
  static Uri? tryBaseUri({String? host}) {
    try {
      return baseUri(host: host);
    } on ArgumentError {
      return null;
    }
  }
}

/// A refused request: regtest traffic left the simulator, or the active
/// environment could not be read.
final class RegtestExchangeRoutingException implements Exception {
  const RegtestExchangeRoutingException();
}

/// Binds the non-mainnet exchange clients to the active environment.
///
/// While regtest is active every request goes to [RegtestExchangeProfile], and
/// it fails closed when the environment cannot be read. Add it before the
/// authentication interceptor, and [addRegtestKeyGuard] after it.
void addRegtestExchangeRouting(
  Dio dio,
  Future<NetworkEnv> Function() readEnvironment, {
  String? regtestHost,
}) => dio.interceptors.add(
  regtestExchangeRoutingInterceptor(readEnvironment, regtestHost: regtestHost),
);

/// The rebinding half of [addRegtestExchangeRouting], for clients built by a
/// feature that must not import this one.
Interceptor regtestExchangeRoutingInterceptor(
  Future<NetworkEnv> Function() readEnvironment, {
  String? regtestHost,
}) {
  return InterceptorsWrapper(
    onRequest: (options, handler) async {
      final NetworkEnv environment;
      try {
        environment = await readEnvironment();
      } on Exception {
        handler.reject(
          DioException(
            requestOptions: options,
            error: const RegtestExchangeRoutingException(),
          ),
        );
        return;
      }
      if (environment == NetworkEnv.regtest) {
        final regtest = RegtestExchangeProfile.tryBaseUri(host: regtestHost);
        if (regtest == null || Uri.parse(options.path).hasScheme) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const RegtestExchangeRoutingException(),
            ),
          );
          return;
        }
        final path = Uri.parse(options.baseUrl).path;
        options.baseUrl = regtest.replace(path: path).toString();
      }
      handler.next(options);
    },
  );
}

/// The development key never leaves toward any other host, whatever the
/// environment. Add it after the authentication interceptor so it sees the
/// final URL and the key the client attached.
void addRegtestKeyGuard(Dio dio, {String? regtestHost}) {
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final key = options.headers['X-API-Key'];
        final regtest = RegtestExchangeProfile.tryBaseUri(host: regtestHost);
        final toSimulator =
            regtest != null &&
            options.uri.host == regtest.host &&
            options.uri.port == regtest.port;
        if (key == RegtestExchangeProfile.developmentApiKey && !toSimulator) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: const RegtestExchangeRoutingException(),
            ),
          );
          return;
        }
        handler.next(options);
      },
    ),
  );
}
