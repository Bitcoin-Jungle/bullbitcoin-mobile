import 'labels_snapshot.dart';

/// A label that differs between this phone and the backup.
final class LabelConflict {
  final BackupLabelType type;
  final String ref;
  final String localLabel;
  final String incomingLabel;

  const LabelConflict({
    required this.type,
    required this.ref,
    required this.localLabel,
    required this.incomingLabel,
  });

  /// One conflict per record identity.
  @override
  bool operator ==(Object other) =>
      other is LabelConflict && other.type == type && other.ref == ref;

  @override
  int get hashCode => Object.hash(type, ref);
}

/// Additive merge preview; nothing is written before `apply`.
final class MergePlan {
  final String groupId;

  /// Digest of the local labels the plan was computed from; `apply` rejects
  /// the plan when they changed since.
  final String baseDigest;
  final List<BackupLabelRecord> additions;
  final int unchanged;
  final List<LabelConflict> conflicts;
  final List<String> freezeOutpoints;

  MergePlan({
    required this.groupId,
    required this.baseDigest,
    required List<BackupLabelRecord> additions,
    required this.unchanged,
    required List<LabelConflict> conflicts,
    required List<String> freezeOutpoints,
  }) : additions = List.unmodifiable(additions),
       conflicts = List.unmodifiable(conflicts),
       freezeOutpoints = List.unmodifiable(freezeOutpoints);
}

enum ConflictResolution { keepLocal, useBackup }

/// Missing entries keep the local label.
final class MergeChoices {
  final Map<LabelConflict, ConflictResolution> resolutions;

  MergeChoices(Map<LabelConflict, ConflictResolution> resolutions)
    : resolutions = Map.unmodifiable(resolutions);
}

enum LabelRejection { reservedLabel, notOwned, invalid }

enum FreezeOutcome { applied, pendingDiscovery, failed }

/// Per-channel result; a partial commit is reported, never hidden.
final class ApplyReport {
  final int labelsApplied;
  final int labelsUnchanged;
  final Map<LabelRejection, int> labelsRejected;
  final Map<String, FreezeOutcome> freezes;

  ApplyReport({
    required this.labelsApplied,
    required this.labelsUnchanged,
    required Map<LabelRejection, int> labelsRejected,
    required Map<String, FreezeOutcome> freezes,
  }) : labelsRejected = Map.unmodifiable(labelsRejected),
       freezes = Map.unmodifiable(freezes);
}
