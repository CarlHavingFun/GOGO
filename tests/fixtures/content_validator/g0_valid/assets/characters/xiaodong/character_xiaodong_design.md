# Static Xiaodong governance fixture

This prose and the ordinary JSON fence below are intentionally ignored by the
loader. Only the exact governance fence is machine input.

```json
{"subject":"ignored-human-example"}
```

```gogo-governance+json
{
  "schema_version": 1,
  "subject": "xiaodong",
  "design_stage": "C0",
  "asset_stage": "A5",
  "artifact_state": "not_generated",
  "decision": "pending_review",
  "candidate_count": 0,
  "reference": {
    "path": "assets/source/references/characters/xiaodong/reference_01.jpg",
    "bytes": 77554,
    "width": 853,
    "height": 1280,
    "sha256": "fa61d571bc7a78a297703c0174ab4d435413def09d478223b1f5f7df06738d52",
    "rights_policy": "R2"
  },
  "boundary": {
    "c0_changes_a5_status": false,
    "c0_enters_godot": false,
    "a5_status": "planned",
    "a5_gate": "M4"
  }
}
```
