# UL Drift Log

> Append-only log of Ubiquitous Language drift detected or resolved.
> Format: one entry per detection. Newest at the bottom.

## Entry template

```
### YYYY-MM-DD — {term detected as drift}
- **Canonical (per glossary)**: {term}
- **Drift observed**: {term used in code/spec/wiki}
- **Location**: {file path(s)}
- **Severity**: low | medium | high
- **Resolution**: {fix applied | TODO | rejected — reason}
- **Detected by**: {agent | human | ul-auditor}
```

---

## Entries

(None yet — log starts fresh with Phase 0 setup.)
