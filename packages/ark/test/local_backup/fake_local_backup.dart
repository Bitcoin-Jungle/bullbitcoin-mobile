import 'dart:async';

import 'package:ark/src/data/local_backup/local_backup_port.dart';
import 'package:ark/src/domain/ark_wallet_failure.dart';
import 'package:primitives/primitives.dart';

/// Controlled protocol simulation, never evidence of a copied or flushed file.
final class FakeLocalBackup implements LocalBackupPort {
  LocalBackupStatus _status = LocalBackupStatus(
    lastSuccess: null,
    pending: true,
    failure: null,
  );
  int _sequence = 0;
  bool _closed = false;
  Completer<Result<LocalBackupPublication, ArkWalletFailure>>? _completion;
  Future<Result<LocalBackupPublication, ArkWalletFailure>>? _active;
  Future<void>? _closing;

  @override
  LocalBackupStatus get status => _status;

  @override
  Result<void, ArkWalletFailure> markPending() {
    if (_closed) {
      return const Err(ArkUnavailableFailure(ArkFailureReason.closed));
    }
    _sequence++;
    _status = LocalBackupStatus(
      lastSuccess: _status.lastSuccess,
      pending: true,
      failure: _status.failure,
    );
    return const Ok(null);
  }

  @override
  Future<Result<LocalBackupPublication, ArkWalletFailure>> copyNow() {
    if (_closed) {
      return Future.value(
        const Err(ArkUnavailableFailure(ArkFailureReason.closed)),
      );
    }
    if (_active != null) {
      return Future.value(const Err(ArkWriterBusyFailure()));
    }
    final sequence = _sequence;
    final completion =
        Completer<Result<LocalBackupPublication, ArkWalletFailure>>();
    _completion = completion;
    _status = LocalBackupStatus(
      lastSuccess: _status.lastSuccess,
      pending: true,
      failure: _status.failure,
    );
    final active = completion.future
        .then((result) {
          _status = switch (result) {
            Ok(:final value) => LocalBackupStatus(
              lastSuccess: value,
              pending: _sequence != sequence,
              failure: null,
            ),
            Err(:final failure) => LocalBackupStatus(
              lastSuccess: _status.lastSuccess,
              pending: true,
              failure: failure,
            ),
          };
          return result;
        })
        .whenComplete(() {
          _completion = null;
          _active = null;
        });
    _active = active;
    return active;
  }

  /// Signals full simulated settlement, including cleanup. No real I/O occurs.
  void completeCopy(Result<LocalBackupPublication, ArkWalletFailure> result) {
    final completion = _completion;
    if (completion == null || completion.isCompleted) {
      throw StateError('No unsettled copy to complete');
    }
    completion.complete(result);
  }

  @override
  Future<void> close() {
    _closed = true;
    return _closing ??= _active?.then<void>((_) {}) ?? Future<void>.value();
  }
}
