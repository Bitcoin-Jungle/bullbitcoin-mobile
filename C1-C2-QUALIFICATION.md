# C1/C2 central qualification result

PASS on 2026-11-19, base a5c75e0ada1a5732729928d085f514b2ff79fbd6, warm runner /home/debian/repos/ark-final. Pipeline duration 81.6 seconds. FVM 4.3.1, Flutter pin 3.50.0, Dart 3.14.0. The runner entered clean, with the exact expected HEAD and all named preimage SHA256s. Session 3462793e-80cf-4ab2-9f5c-ba74d0acab77 held both atomic locks; both were removed by their owning PID after completion. HAPI job c1c2-central completed. No stage, index mutation, commit, fetch, push, GitHub or phone action was performed.

| Check | Observed result |
| --- | --- |
| Canonical ARB helper + make translations once | exit 0; exact candidate EN/FR, 3 generated Dart files |
| C1 minimal Red | exit 1, two behavioral failures: summary y=416 fails before-warning y=64; persistent address label absent |
| C2 minimal Red | exit 1, two behavioral failures: Exit not started absent; covered-page callback adds a second quote |
| Identical C1 minimal after SOURCE only | exit 0, 2 tests passed |
| Identical C2 minimal after SOURCE only | exit 0, 2 tests passed |
| Full C1/C2 plus 5 existing suites | exit 0, 98 tests passed |
| Scripted Dart comparator 899/900/901 | exit 0, 3 tests passed |
| Whole-project make analyze | exit 0, No issues found |
| make fix-check | exit 0, Nothing to fix! |
| EN/FR and generated SHA256 Red/Green/final | identical |
| Source postimages | byte-identical to immutable v1, +45/-8 across 2 sources |
| Complete patch reconstruction from a5 | all 12 final file SHA256s reproduced |

Red failures were test assertions, with no load or compilation failure. The only changes between the two minimal phases were C1/SOURCE.patch and C2/SOURCE.patch; test files, helper files and localizations were unchanged. Full extras were applied only after both minimal Greens. Adapter controls were run after Green and exercise the unmodified production Dart adapter with scripted public records. They are positive controls, not Red defects, and provide no Rust FFI or real-phone refusal proof. They were not separately executed before SOURCE application.

Operational deviation: the canonical make analyze target invokes flutter analyze without --no-pub and triggered an implicit Pub resolution (Resolving dependencies..., Downloading packages..., Got dependencies!). This was discovered in its completed log and reported immediately to Root; it was not repeated. No tracked pubspec.yaml or pubspec.lock change occurred. Test commands used --no-pub; no explicit pub command, tool installation or native build command was issued. The Pub output does not establish whether any package required a fresh network download; cache changes were not snapshotted. The process guard detected no cargo/rustc/native build child. Warm Dart build hooks ran during tests, as recorded in the raw logs. Do not describe the entire pipeline as no-Pub.

The runner was left with exactly 12 paths: 2 production sources, 2 existing helper tests, 3 new tests (557 lines), 2 canonical ARBs, 3 generated Dart localizations. Git diff --stat covers only 9 tracked paths (+73/-12); include the 3 untracked tests (+557) for the complete delta (+630/-12 across 12 paths). final-complete.patch contains both tracked and new files. final-status.txt, final-sha256.json, SOURCE-PROOF.json and commands.json record the precise handoff. Root may now integrate C3 over the frozen C1 postimage. Do not rerun this pipeline over a changed integration tree.

Phone Choose/filled/Review layout evidence and a genuinely insufficient-reserve device case remain Root-owned follow-up evidence. This result qualifies the tested presentation and callback behavior, not final visual parity or real native refusal on a phone.
