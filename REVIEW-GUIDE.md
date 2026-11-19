# Commit review guide

Opening head: `4f5809d9272ad4d077a9bbb7937c717b0728a560`. Integrated base: `e4dd3cbb7042f2eeff3a2a8048acadd590e38a90`. Latest shared target on 2026-11-19 16:26:58 UTC: `eb9e414a316d4b1b77f0b8549477d416deda2bb0` (five later PIN commits are not imported). Read-only merge simulation with that target succeeded without conflicts; this is not a runtime test.

91 commits are unique to this branch relative to e4dd. Required author/committer identities verified on each.

| Class | Files | Added | Removed |
| --- | ---: | ---: | ---: |
| source/docs | 56 | 5634 | 1297 |
| generated | 4 | 1255 | 7 |
| localization | 4 | 556 | 3 |
| tests | 80 | 11140 | 843 |
| references | 68 | 0 | 0 |

Review source/localization behavior first, associated tests second. Generated/reference commits can be skipped for behavioral review; reviewed PNG changes are UI regression references, not real-device evidence. The merge brings upstream canonical amount input without changing Ark source.

## source/localization

- `1d8620f8a` fix(l10n): repair malformed French and Spanish catalogs
- `7bdd2395b` fix(send): resolve Ark routing from the local account inventory
- `1be4b1848` fix(ark): exclude retired VTXOs from current totals
- `1978f7b00` fix(wallet): recover interrupted Ark funding delivery
- `c0e9f8544` fix(ark): open Board from a confirmed empty VTXO list
- `c825b9a08` fix(wallet): expose the home logo as a named 48 dp control
- `3da6a02dc` Merge remote-tracking branch 'upstream/develop' into work/ark-final-20261118
- `508d1e6ed` fix(ark): keep Board confirmation reachable above system insets
- `3c1210772` feat(ark): simplify account activity and guard action sheet routes
- `fce6ecfd9` Merge remote-tracking branch 'upstream/develop' into work/ark-final-20261118
- `34211d275` Merge remote-tracking branch 'upstream/develop' into work/ark-final-20261118
- `bdfd141e4` fix(ark): scan the selected source on ordinary Board entry
- `57ae62523` Merge remote-tracking branch 'upstream/develop' into work/ark-final-20261118
- `9d42c3035` feat(bull-ui): expose sailing and info icon aliases
- `ddcb63afd` feat(bull-ui): support centered unfilled amount inputs
- `b5b0c8c84` feat(bull-ui): allow flat detail tables
- `7f6560a5b` feat(ark): retain native exit phases and cached server facts
- `b8d754a1d` feat(bull-ui): expose bounded amount layout primitives
- `cce682345` feat(ark): localize wallet inventory and exit presentations
- `6b1cf7371` feat(ark): present settings server facts and VTXO inventory
- `4be6a4593` fix(bull-ui): restore the inline copy touch target
- `56c054eb8` feat(bull-ui): support compact headings and covering dropdown menus
- `da680369f` feat(ark): present Board amounts reviews and durable submission results
- `325ba04f1` feat(ark): align wallet receive send and transfer presentations
- `80b66b5c4` feat(ark): present observed exits with explicit reviewed navigation
- `9474cf9eb` feat(wallet): connect live Ark sharing and optional source labels
- `57040547c` fix(ark): expire displayed reviews without an automatic quote
- `a9f74d6b7` feat(bull-ui): add accessible compact detail rows
- `87defcaa5` feat(l10n): distinguish absolute Ark expiry block heights
- `4812cebf8` feat(ark): align inventory density and accessible server details
- `ce76dde49` feat(ark): refine wallet receive and transfer layouts
- `b8eff56e7` feat(ark): group observed amounts without changing Board input
- `9e09b83de` feat(ark): identify exit reviews and format their bound amounts
- `2279a75e1` fix(bull-ui): reserve readable space for copyable compact values
- `3e6984523` feat(bull_ui): add themed action button roles
- `6eb417715` fix(bull_ui): support intrinsic compact dialog actions
- `2c9ab88a6` feat(l10n): label operation result details
- `16e9cbb9a` feat(ark): separate accepted results from operation details
- `5a7e68c4a` feat(ark): open exits in dedicated local details
- `55a141c20` fix(ark): keep exit inputs visible before explicit review
- `6792120e9` feat(l10n): name emergency exits refused before confirmation
- `21dc6c83d` fix(ark): retry initial exit refusal only from its current page

## tests

- `b83b3bcf4` test(settings): pass the required environment to settings fixtures
- `d3378ce1f` test(send): cover composed Ark routing without native startup
- `07cace83d` test(ark): cover retired inventory totals and counts
- `ee7169244` test(wallet): cover persisted Ark funding recovery windows
- `789f9958f` test(ark): cover empty inventory Board capability lifetime
- `a47b8f9ae` test(wallet): cover localized logo semantics and shared tap counter
- `bc815a893` test(ark): cover Board confirmation hit targets and visual states
- `08a6bf2ec` test(ark): cover account actions, stale sheets and visual states
- `092e7d567` test: migrate remaining native bindings imports
- `ad090e715` test(ark): navigate account actions through the current menu
- `e57679e8c` test(ark): cover Board source refresh and passive transfers
- `a8deac559` test(bull-ui): preserve input defaults and controlled amount edits
- `11883a50e` test(bull-ui): preserve flat table rows and exact clipboard writes
- `c886e896f` test(ark): preserve legacy observations and optional server bindings
- `d61fed969` test(ark): cover inventory consent and scoped server observations
- `742058e10` test(bull-ui): exercise the copy target at its edge
- `795541351` test(bull-ui): preserve field defaults and accessible layout variants
- `3ae9d9dae` test(ark): cover Board presentation and retired funding actions
- `630a4b433` test(ark): preserve exact amounts privacy and wallet action ownership
- `2f6cc97ab` test(ark): bind exit holds cancellation and completion to current reviews
- `a1518f9da` test(wallet): cover Ark host sharing and nonblocking source labels
- `cdb5e67c7` test(ark): cover elapsed reviews and accessible confirmation expiry
- `9f3670c5c` test(bull-ui): preserve legacy details and compact action semantics
- `f61786e8b` test(ark): verify inventory geometry copying and localized block heights
- `be9d79874` test(ark): verify wallet layout privacy and real action targets
- `a9c66df61` test(ark): preserve exact Board edits across localized display changes
- `494f9e644` test(ark): preserve exit review facts titles and explicit action guards
- `87612e20e` test(ark): select the explicit claim action in composition
- `a7b537116` test(ark): capture whole server status and the actual fee reserve section
- `390624404` test(bull_ui): cover button roles and activation semantics
- `28d778ee5` test(bull_ui): cover compact dialog intrinsic sizing
- `16ebd2dfc` test(ark): keep root visual scenarios in their owning feature
- `24fecc593` test(ark): move inventory layout contracts to their owner
- `453d84ed5` test(ark): isolate wallet visual contracts behind test helpers
- `686ff7bdd` test(ark): cover result navigation and guarded completion
- `d1018b2ec` test(ark): cover exit detail ownership and scroll resets
- `27b5333e5` test(ark): cover exit selection and persistent fee inputs
- `d99593eb2` test(ark): cover initial exit refusal and reserve comparison

## generated/references

- `91b5d92f7` chore(ark): regenerate Board review translations and snapshots
- `ea5cf0f3f` chore(ark): regenerate account action labels and snapshots
- `f44846e83` chore(ark): regenerate presentation localizations
- `b968d0ec1` chore(l10n): generate absolute Ark block labels
- `eb3399ab7` chore(goldens): refresh the existing Settings typography baseline
- `82c8a211f` chore(goldens): refresh reviewed Ark presentation references
- `d4c81ba78` chore(bull_ui): regenerate the action button catalogue
- `de7546349` chore(l10n): generate operation result labels
- `a5c75e0ad` chore(goldens): refresh reviewed exit result and detail references
- `31a67bfe6` chore(l10n): regenerate initial exit refusal heading

## merge

- `4f5809d92` merge: integrate develop amount flows with Ark UI parity
