import 'package:ark/src/data/local_backup/local_backup_port.dart';
import 'package:ark/src/domain/ark_wallet_failure.dart';
import 'package:primitives/primitives.dart';
import 'package:test/test.dart';

import 'fake_local_backup.dart';

LocalBackupPublication publication() => LocalBackupPublication(
  completedAt: DateTime(2026, 11, 16),
  byteLength: 4096,
  sha256: 'ab' * 32,
);

void main() {
  test('publication normalizes UTC and validates only metadata shape', () {
    expect(publication().completedAt.isUtc, isTrue);
    for (final bytes in [0, -1]) {
      expect(
        () => LocalBackupPublication(
          completedAt: DateTime.utc(2026),
          byteLength: bytes,
          sha256: 'ab' * 32,
        ),
        throwsArgumentError,
      );
    }
    for (final digest in [
      '',
      'a' * 63,
      'a' * 65,
      'A' * 64,
      'g' * 64,
      '${'a' * 64}\n',
    ]) {
      expect(
        () => LocalBackupPublication(
          completedAt: DateTime.utc(2026),
          byteLength: 1,
          sha256: digest,
        ),
        throwsArgumentError,
      );
    }
  });

  test('no pending mark requires a publication without failure', () {
    for (final lastSuccess in [null, publication()]) {
      expect(
        () => LocalBackupStatus(
          lastSuccess: lastSuccess,
          pending: false,
          failure: const ArkStorageFailure(),
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => LocalBackupStatus(lastSuccess: null, pending: false, failure: null),
      throwsArgumentError,
    );
  });

  test('starts pending without claimed publication or failure', () async {
    final fake = FakeLocalBackup();
    expect(fake.status.lastSuccess, isNull);
    expect(fake.status.pending, isTrue);
    expect(fake.status.failure, isNull);
    await fake.close();
  });

  test(
    'success covers local marks and a new mark preserves last success',
    () async {
      final fake = FakeLocalBackup();
      expect(fake.markPending(), isA<Ok<void, ArkWalletFailure>>());
      final copy = fake.copyNow();
      final saved = publication();
      fake.completeCopy(Ok(saved));
      expect(await copy, isA<Ok<LocalBackupPublication, ArkWalletFailure>>());
      expect(fake.status.pending, isFalse);
      expect(fake.status.lastSuccess, same(saved));
      expect(fake.markPending(), isA<Ok<void, ArkWalletFailure>>());
      expect(fake.status.pending, isTrue);
      expect(fake.status.lastSuccess, same(saved));
      await fake.close();
    },
  );

  test(
    'inflight dirtiness remains pending after successful settlement',
    () async {
      final fake = FakeLocalBackup();
      final copy = fake.copyNow();
      expect(fake.markPending(), isA<Ok<void, ArkWalletFailure>>());
      fake.completeCopy(Ok(publication()));
      await copy;
      expect(fake.status.pending, isTrue);
      await fake.close();
    },
  );

  test(
    'failure preserves publication and later success clears failure',
    () async {
      final fake = FakeLocalBackup();
      final first = fake.copyNow();
      final saved = publication();
      fake.completeCopy(Ok(saved));
      await first;
      final failed = fake.copyNow();
      const failure = ArkStorageFailure();
      fake.completeCopy(const Err(failure));
      expect(
        await failed,
        isA<Err<LocalBackupPublication, ArkWalletFailure>>(),
      );
      expect(fake.status.lastSuccess, same(saved));
      expect(fake.status.failure, same(failure));
      expect(fake.markPending(), isA<Ok<void, ArkWalletFailure>>());
      expect(fake.status.failure, same(failure));
      final retry = fake.copyNow();
      fake.completeCopy(Ok(publication()));
      await retry;
      expect(fake.status.pending, isFalse);
      expect(fake.status.failure, isNull);
      await fake.close();
    },
  );

  test(
    'busy and duplicate completion preserve the admitted predecessor',
    () async {
      final fake = FakeLocalBackup();
      final copy = fake.copyNow();
      final before = fake.status;
      fake.completeCopy(Ok(publication()));
      expect(() => fake.completeCopy(Ok(publication())), throwsStateError);
      final busy = fake.copyNow();
      expect(fake.status, same(before));
      expect(
        await busy,
        isA<Err<LocalBackupPublication, ArkWalletFailure>>().having(
          (r) => r.failure,
          'failure',
          isA<ArkWriterBusyFailure>(),
        ),
      );
      await copy;
      expect(() => fake.completeCopy(Ok(publication())), throwsStateError);
      await fake.close();
    },
  );

  test(
    'close gates admission immediately and awaits simulated cleanup',
    () async {
      final fake = FakeLocalBackup();
      expect(() => fake.completeCopy(Ok(publication())), throwsStateError);
      final copy = fake.copyNow();
      final closing = fake.close();
      expect(fake.close(), same(closing));
      var settled = false;
      closing.then((_) => settled = true);
      await Future<void>.delayed(Duration.zero);
      expect(settled, isFalse);
      final before = fake.status;
      expect(fake.markPending(), isA<Err<void, ArkWalletFailure>>());
      expect(
        await fake.copyNow(),
        isA<Err<LocalBackupPublication, ArkWalletFailure>>().having(
          (r) => r.failure.reason,
          'reason',
          ArkFailureReason.closed,
        ),
      );
      expect(fake.status, same(before));
      fake.completeCopy(Ok(publication()));
      await copy;
      await closing;
      expect(settled, isTrue);
      expect(fake.status.lastSuccess, isNotNull);
    },
  );
}
