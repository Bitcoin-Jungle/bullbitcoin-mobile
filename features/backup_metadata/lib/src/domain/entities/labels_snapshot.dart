/// BIP329 record types.
enum BackupLabelType { tx, addr, pubkey, input, output, xpub }

/// One BIP329 record; coin freezes travel as `spendable` on outputs.
final class BackupLabelRecord {
  final BackupLabelType type;
  final String ref;
  final String? label;
  final String? origin;
  final bool? spendable;

  BackupLabelRecord({
    required this.type,
    required this.ref,
    this.label,
    this.origin,
    this.spendable,
  }) {
    if (ref.isEmpty) throw ArgumentError('Label reference must not be empty');
    if (spendable != null && type != BackupLabelType.output) {
      throw ArgumentError('Only outputs carry spendable');
    }
  }
}

/// Immutable capture of one group's labels at a point in time.
final class LabelsSnapshot {
  final List<BackupLabelRecord> records;

  /// Labels that belong to no wallet of any group: never reported as saved.
  final int unattributedCount;

  /// Stored rows that could not be read: a complete backup is never claimed.
  final int skippedCount;

  LabelsSnapshot({
    required List<BackupLabelRecord> records,
    required this.unattributedCount,
    required this.skippedCount,
  }) : records = List.unmodifiable(records);
}
