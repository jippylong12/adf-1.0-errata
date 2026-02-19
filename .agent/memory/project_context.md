# Project Memory

## Architectural Decisions
- This repository maintains a machine-valid errata baseline for ADF 1.0 Appendix DTD content, with both DTD and XSD 1.0 kept semantically aligned.
- When appendix expressions are non-deterministic in practical validators, use deterministic-equivalent content models and document the rewrite in `ERRATA.md`.
- Validation is intentionally constrained to `xmllint` + shell for local and CI parity.
- `timeframe` is modeled as structured content (`description?` + one or more date markers), not free text.

## Gotchas
- Typographic quotes from PDF extracts (`“` and `”`) must always be converted to ASCII quotes for parser compatibility.
- Keep example XML instances dual-valid (DTD and XSD) before accepting schema changes.
- When changing `timeframe`, update `examples/full-prospect.xml` and XSD type definitions together to avoid schema drift.
