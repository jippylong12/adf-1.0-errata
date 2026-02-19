# Project Memory

## Architectural Decisions
- This repository maintains a machine-valid errata baseline for ADF 1.0 Appendix DTD content, with both DTD and XSD 1.0 kept semantically aligned.
- When appendix expressions are non-deterministic in practical validators, use deterministic-equivalent content models and document the rewrite in `ERRATA.md`.
- Validation is intentionally constrained to `xmllint` + shell for local and CI parity.
- `timeframe` is modeled as structured content (`description?` + one or more date markers), not free text.
- User-facing XML validation is provided by `scripts/validate-input.sh` with three input modes: `--file`, `--xml`, and `--stdin`.
- `scripts/validate-input.sh` defaults to order-insensitive schema validation by normalizing known child order before running DTD/XSD checks.
- `--strict` enforces DTD/XSD on the original input order; `--relaxed` remains available for lightweight business checks only.
- Even in relaxed mode, customer contact must include at least one `email` or `phone`.

## Gotchas
- Typographic quotes from PDF extracts (`“` and `”`) must always be converted to ASCII quotes for parser compatibility.
- Keep example XML instances dual-valid (DTD and XSD) before accepting schema changes.
- When changing `timeframe`, update `examples/full-prospect.xml` and XSD type definitions together to avoid schema drift.
- XML strings copied from files can contain relative DOCTYPE references; suppress warning noise and validate against explicit local errata schema paths.
- Users may send valid real-world payloads that fail strict schema ordering; use relaxed mode for practical intake checks and strict mode for canonical conformance.
- Relaxed mode should still enforce core contactability constraints for leads (customer must be reachable by phone or email).
