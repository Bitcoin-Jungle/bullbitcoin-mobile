import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:primitives/primitives.dart';

import 'backup_storage.dart';
import 'backup_storage_failure.dart';

/// App-private Drive storage. Each authorization owns its transport and listener.
final class GoogleDriveBackupStorage implements BackupStorage {
  static const _scopes = ['https://www.googleapis.com/auth/drive.appdata'];
  static final _sharedGoogle = GoogleSignIn(scopes: _scopes);
  static const _deadline = Duration(seconds: 60);
  final GoogleSignIn _google;
  final Future<http.Client?> Function()? _authenticatedClient;

  GoogleDriveBackupStorage({
    GoogleSignIn? googleSignIn,
    this._authenticatedClient,
  }) : _google = googleSignIn ?? _sharedGoogle;

  @override
  BackupDestination get destination => BackupDestination.googleDrive;

  @override
  Future<Result<StorageSession, BackupStorageFailure>> authorize({
    required bool interactive,
  }) async {
    final session = _DriveSession(_google, _authenticatedClient);
    try {
      await session.authorize(interactive).timeout(_deadline);
      return Ok(session);
    } on Exception catch (error) {
      session.dispose();
      return Err(_failure(error));
    }
  }
}

final class _DriveSession implements StorageSession {
  static const _deadline = Duration(seconds: 60);
  static const _fields = 'id,name,size,createdTime,modifiedTime,md5Checksum';
  final GoogleSignIn _google;
  final Future<http.Client?> Function()? _authenticatedClient;
  GoogleSignInAccount? _currentAccount;
  int _authenticationEpoch = 0;
  int? _authorizedEpoch;
  String? _email;
  http.Client? _client;
  drive.DriveApi? _api;
  bool _disposed = false;
  late final StreamSubscription<GoogleSignInAccount?> _authentication;

  _DriveSession(this._google, this._authenticatedClient) {
    _currentAccount = _google.currentUser;
    _authentication = _google.onCurrentUserChanged.listen(
      (account) {
        if (account == null || _currentAccount?.email != account.email) {
          _authenticationEpoch++;
        }
        _currentAccount = account;
        if (account == null || (_email != null && _email != account.email)) {
          _clearClient();
        }
      },
      onError: (Object error, StackTrace stack) {
        // Authentication events never log account details or foreign messages.
        _authenticationEpoch++;
        _clearClient();
      },
    );
  }

  @override
  StorageAccount get account {
    final email = _email;
    if (email == null) throw StateError('Session has no authorized account');
    // Email preserves RecoverBull's existing account identity. It is never logged.
    return StorageAccount(id: email);
  }

  Future<void> authorize(bool interactive) async {
    final before = _authenticationEpoch;
    final account = interactive
        ? await _google.signIn()
        : await _google.signInSilently(suppressErrors: false);
    if (_disposed) throw const _AuthorizationChanged();
    if (_authenticationEpoch == before) {
      _currentAccount = account;
    } else if (_authenticationEpoch != before + 1 ||
        _currentAccount?.email != account?.email) {
      throw const _AuthorizationChanged();
    }
    if (account == null) {
      throw _StorageException(
        interactive
            ? const BackupStorageCancelledFailure()
            : const BackupStorageAuthorizationRequiredFailure(),
      );
    }
    _email = account.email;
    _authorizedEpoch = _authenticationEpoch;
    final client = await _clientFor(account, interactive);
    if (client == null) throw const _AuthorizationChanged();
    try {
      _checkAccount();
    } on Exception {
      client.close();
      rethrow;
    }
    _client = client;
    _api = drive.DriveApi(client);
  }

  Future<http.Client?> _clientFor(
    GoogleSignInAccount account,
    bool interactive,
  ) async {
    final authenticate = _authenticatedClient;
    if (authenticate != null) return authenticate();
    // v6 account.authentication always permits interactive recovery. Discovery
    // instead asks the platform explicitly for non-interactive tokens.
    final tokens = await GoogleSignInPlatform.instance.getTokens(
      email: account.email,
      shouldRecoverAuth: interactive,
    );
    _checkAccount();
    final accessToken = tokens.accessToken;
    if (accessToken == null) return null;
    return auth.authenticatedClient(
      http.Client(),
      auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().toUtc().add(const Duration(days: 365)),
        ),
        null,
        GoogleDriveBackupStorage._scopes,
      ),
      closeUnderlyingClient: true,
    );
  }

  void _checkAccount() {
    if (_disposed ||
        _authorizedEpoch != _authenticationEpoch ||
        _email == null ||
        _currentAccount?.email != _email) {
      throw const _AuthorizationChanged();
    }
  }

  drive.DriveApi get _connectedApi {
    _checkAccount();
    final api = _api;
    if (api == null) throw const _AuthorizationChanged();
    return api;
  }

  Future<Result<T, BackupStorageFailure>> _run<T>(
    Future<T> Function() action,
  ) async {
    try {
      _checkAccount();
      final result = await action().timeout(_deadline);
      _checkAccount();
      return Ok(result);
    } on Exception catch (error) {
      // A transport may fail because an account-change event closed it. Fence
      // that identity change before classifying the resulting network failure.
      try {
        _checkAccount();
      } on _AuthorizationChanged {
        return const Err(BackupStorageAuthorizationRequiredFailure());
      }
      // A timed-out HTTP operation must not continue using this capability.
      if (error is TimeoutException) dispose();
      return Err(_failure(error));
    }
  }

  @override
  Future<Result<List<StoredObject>, BackupStorageFailure>> list({
    required String mimeType,
    String? namePrefix,
  }) => _run(() async {
    final objects = <StoredObject>[];
    final seenTokens = <String>{};
    String? token;
    do {
      final response = await _connectedApi.files.list(
        spaces: 'appDataFolder',
        q: "mimeType='${_escape(mimeType)}' and trashed=false",
        $fields: 'nextPageToken,files($_fields)',
        orderBy: 'createdTime desc',
        pageToken: token,
        pageSize: 1000,
      );
      _checkAccount();
      for (final file in response.files ?? <drive.File>[]) {
        final object = _object(file);
        if (namePrefix == null || object.name.startsWith(namePrefix)) {
          objects.add(object);
        }
      }
      token = response.nextPageToken;
      if (token != null && token.isNotEmpty && !seenTokens.add(token)) {
        throw const FormatException('Repeated Drive page token');
      }
    } while (token != null && token.isNotEmpty);
    return objects;
  });

  @override
  Future<Result<Uint8List, BackupStorageFailure>> read(
    StoredObject object, {
    required int maxBytes,
  }) => _run(() async {
    if (maxBytes < 0) throw ArgumentError.value(maxBytes, 'maxBytes');
    if ((object.size ?? 0) > maxBytes) {
      throw const _StorageException(BackupStorageTooLargeFailure());
    }
    final response = await _connectedApi.files.get(
      object.id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );
    if (response is! drive.Media) {
      throw const FormatException('Invalid Drive media');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.stream) {
      _checkAccount();
      if (bytes.length + chunk.length > maxBytes) {
        throw const _StorageException(BackupStorageTooLargeFailure());
      }
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  });

  @override
  Future<Result<StoredObject, BackupStorageFailure>> create({
    required String name,
    required String mimeType,
    required Uint8List bytes,
  }) => _run(() async {
    final file = drive.File()
      ..name = name
      ..mimeType = mimeType
      ..parents = ['appDataFolder'];
    final created = await _connectedApi.files.create(
      file,
      uploadMedia: drive.Media(Stream.value(bytes), bytes.length),
      $fields: _fields,
    );
    return _object(created);
  });

  @override
  Future<Result<void, BackupStorageFailure>> delete(StoredObject object) =>
      _run(() async => _connectedApi.files.delete(object.id));

  @override
  Future<Result<void, BackupStorageFailure>> disconnect() async {
    try {
      _checkAccount();
      await _google.disconnect().timeout(_deadline);
      return const Ok(null);
    } on Exception catch (error) {
      return Err(_failure(error));
    } finally {
      dispose();
    }
  }

  void _clearClient() {
    final previous = _client;
    _client = null;
    _api = null;
    try {
      previous?.close();
    } on Exception {
      // Best-effort release; never turn a close failure into grant revocation.
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_authentication.cancel());
    _clearClient();
  }
}

String _escape(String value) =>
    value.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

StoredObject _object(drive.File file) {
  final id = file.id;
  final name = file.name;
  if (id == null || name == null) {
    throw const FormatException('Invalid Drive metadata');
  }
  return StoredObject(
    id: id,
    name: name,
    size: int.tryParse(file.size ?? ''),
    createdAt: file.createdTime,
    modifiedAt: file.modifiedTime,
    md5: file.md5Checksum,
    durability: Durability.durable,
  );
}

BackupStorageFailure _failure(Exception error) {
  if (error is _StorageException) return error.failure;
  if (error is _AuthorizationChanged) {
    return const BackupStorageAuthorizationRequiredFailure();
  }
  if (error is TimeoutException ||
      error is IOException ||
      error is http.ClientException) {
    return const BackupStorageUnavailableFailure();
  }
  if (error is PlatformException) {
    return switch (error.code) {
      'sign_in_canceled' => const BackupStorageCancelledFailure(),
      'sign_in_required' => const BackupStorageAuthorizationRequiredFailure(),
      'network_error' => const BackupStorageUnavailableFailure(),
      _ => const BackupStorageUnexpectedFailure(),
    };
  }
  if (error is drive.DetailedApiRequestError) {
    final reasons = error.errors.map((item) => item.reason).toSet();
    if (reasons.contains('storageQuotaExceeded') ||
        reasons.contains('quotaExceeded')) {
      return const BackupStorageQuotaExceededFailure();
    }
    if (reasons.contains('rateLimitExceeded') ||
        reasons.contains('userRateLimitExceeded')) {
      return const BackupStorageUnavailableFailure();
    }
    return switch (error.status ?? 0) {
      401 || 403 => const BackupStoragePermissionRevokedFailure(),
      404 => const BackupStorageNotFoundFailure(),
      408 || 429 || >= 500 => const BackupStorageUnavailableFailure(),
      _ => const BackupStorageUnexpectedFailure(),
    };
  }
  return const BackupStorageUnexpectedFailure();
}

final class _AuthorizationChanged implements Exception {
  const _AuthorizationChanged();
}

final class _StorageException implements Exception {
  final BackupStorageFailure failure;

  const _StorageException(this.failure);
}
