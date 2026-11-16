import 'package:meta/meta.dart';
import 'package:primitives/primitives.dart';

import '../../domain/ark_wallet_failure.dart';

/// Descriptive metadata for a validated, file-flushed SQLite snapshot published
/// with atomic visibility. It does not prove directory-entry durability after
/// power loss, account identity, archive completeness or recoverability.
final class LocalBackupPublication {
  final DateTime completedAt;
  final int byteLength;
  final String sha256;

  LocalBackupPublication({
    required DateTime completedAt,
    required this.byteLength,
    required this.sha256,
  }) : completedAt = completedAt.toUtc() {
    if (byteLength <= 0 || !RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256)) {
      throw ArgumentError('Invalid backup publication metadata');
    }
  }
}

/// Process-local scheduling facts, never an acknowledgment of archive dirty
/// state. No pending local mark does not establish a globally current backup.
final class LocalBackupStatus {
  final LocalBackupPublication? lastSuccess;
  final bool pending;
  final ArkWalletFailure? failure;

  LocalBackupStatus({
    required this.lastSuccess,
    required this.pending,
    required this.failure,
  }) {
    if (!pending && (lastSuccess == null || failure != null)) {
      throw ArgumentError('A current backup needs a successful publication');
    }
  }
}

/// Setup binds one existing source/account and one private destination; callers
/// cannot substitute paths here. No Bark/account/parent lease or writer callback
/// is acquired or entered. Persistent dirty state remains archive-owned.
abstract interface class LocalBackupPort {
  /// Initially pending without a last success. Failure preserves last success.
  /// Pending clears only for local notifications covered by a successful copy,
  /// not every native write. Status remains inspectable after [close].
  LocalBackupStatus get status;

  /// Synchronous scheduling only, with no I/O or durable acknowledgment.
  /// Preserves last success and failure; refuses after closing admission.
  @useResult
  Result<void, ArkWalletFailure> markPending();

  /// Attempts one complete SQLite copy outside financial/native writer
  /// callbacks. Success clears failure, but a newer local mark stays pending.
  /// Failure retains last success and pending, even if publication may already
  /// have occurred. Busy/closed admission leaves predecessor state unchanged.
  /// Concurrent attempts refuse busy until admitted work and cleanup settle.
  @useResult
  Future<Result<LocalBackupPublication, ArkWalletFailure>> copyNow();

  /// Closes admission synchronously and repeatably awaits admitted work and
  /// actual cleanup. Timeout, cancellation request or progress is not cleanup.
  Future<void> close();
}
