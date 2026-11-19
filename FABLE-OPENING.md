# Opening lot — final Fable low verdict, 2026-11-19

Object: merge commit `4f5809d9272ad4d077a9bbb7937c717b0728a560` in `~/repos/ark-final` (branch `feat/ark-ui-parity-20261119`), parents `d99593eb2a8cee0228f6e43ddecbf411b8967d75` (Ark UI line with C1/C2) and `e4dd3cbb7042f2eeff3a2a8048acadd590e38a90` (develop snapshot), merge base `972efcf8a19b325448dc34eca3e9bbbc75cb4f40`. C3 is excluded from this lot and from this verdict.

**Static verdict. I executed no test, analysis, build, generation, phone or GitHub action, today or earlier, on any part of this lot.** The checks below are `git` reads and hash comparisons only.

## Verdict: GO on funds grounds for opening the PR at `4f5809d92`

### What I verified on the final SHA

- It is an ordinary two-parent merge with exactly the stated parents; author `ethicnology <ethicnology@pm.me>`, committer `ethicnology-agent <ethicnology+agent@pm.me>`.
- The five resolved files in the merge are byte-identical to the post-images I reviewed in `integration-e4dd/REVIEW-FABLE.md`.
- `git diff-tree --cc` shows that only five files differ from both parents: the four resolved files that are not simply "incoming" (`send_locator.dart`, both ARBs, `bull_dropdown_menu.dart`) and the auto-merged barrel `packages/bull_ui/lib/bull_ui.dart`, which is byte-identical to the packet's audited copy. Every other file in the merge is taken unchanged from one parent.
- Nothing under `features/ark`, `packages/ark` or `lib/features/wallet` differs between `d99593eb2` and the merge. The Ark code in the opening lot is therefore exactly the Ark line I reviewed.

### What the GO rests on (Ark side, `57ae62523` → `d99593eb2`)

Production changes were reviewed in these frozen ranges, each with a written verdict: `57ae62523..cdb5e67c7` (tranche 1), `cdb5e67c7..be9d79874` (v5), `b8eff56e7` (Board amount grouping), `9e09b83de` (Exits polish), `16e9cbb9a` / `5a7e68c4a` (Exits result and detail), `55a141c20` / `21dc6c83d` (C1, C2). `d1018b2ec..a5c75e0ad` contains no production change.

### Gaps in my own coverage, stated plainly

1. **`494f9e644..453d84ed5`, 13 commits, `bull_ui` only (+221/−69 in 8 files): not reviewed as a lot.** For this verdict I skimmed the behaviour-relevant hunks only: `BullConfirmDialog` changes button styling and keeps its cancel/confirm callbacks; `BullButton` gains primary/secondary constructors where a null `onPressed` means disabled with an inert callback; `BullDetailsTable` adjusts compact label width. I saw nothing that changes what a confirm button does, but this is a skim, not a review. `bull_ui` in the earlier ranges was likewise outside my reviews.
2. **Upstream content** (the 50 develop commits, including the new amount-input flows and the schema change to v16 with `settings.start_amounts_in_fiat`) is not reviewed by me, by instruction. It reaches this PR only as the second parent.
3. **Tests, goldens and generated files** were never reviewed by me beyond titles.

### Execution and capture limits to state in the PR

- All executed evidence is the lead's: the tranche runs, the C1/C2 central result (`candidate-v2central/RESULT.md`), hooks and analysis. I have not seen an execution result on the merged SHA `4f5809d92` itself; if the full suite and analysis were run on it, cite that run, and if not, say so.
- Phone evidence covers the Ark line up to the state captured before C1/C2 at the latest; **C1/C2 and the merged tree have not been exercised on a phone**. The real "insufficient reserve" refusal has only a scripted adapter control and a fake-failure widget test.
- Do not install a build of this merge over funded historical v16 Ark data (standing schema rule, unchanged, not re-examined here).

### Residuals that remain true at opening

No exit path once a Board funding is past its Ark expiry; started-without-bytes recovery (B), Sync replay and the F1 transport fix are not in this tree; emergency-exit fee preview deliberately absent; claim destination entered manually; next-round countdown and mailbox key unavailable; on the exit form the two warnings sit at the end of the scroll with a fixed Review button (phone-capture point). M1 is not closed by this PR.
