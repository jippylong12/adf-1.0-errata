# Project Context

## Constraints
- Keep this repository minimal and tool-light; no extra frameworks.
- Treat the user-provided corrected ADF Appendix DTD as canonical for schema structure.
- Preserve ADF 1.0 element and attribute names exactly; do not rename.
- Keep all files UTF-8 with LF line endings and plain, readable formatting.
- Ensure examples validate against both DTD and XSD using `xmllint`.

## Anti-Patterns
- Adding elements/attributes that are not present in the corrected DTD baseline.
- Introducing dependencies beyond shell + `xmllint`.
- Overengineering docs or scripts.

## Patterns & Recipes
- Build DTD first, then derive XSD 1.0 with equivalent sequence/multiplicity rules.
- Capture only necessary corrections in `ERRATA.md` with source snippets and rationale.
- **Topic:** DTD Determinism
  **Rule:** Rewrite ambiguous DTD choices into deterministic-equivalent models before publishing.
  **Reason:** `xmllint` reports non-deterministic content models as validity errors, which obscures real failures.
- **Topic:** Dual-Schema Validation
  **Rule:** Every schema change must pass both `xmllint --dtdvalid` and `xmllint --schema` for all example XML files.
  **Reason:** DTD and XSD must remain behaviorally aligned for a stable baseline.
- **Topic:** Customer Timeframe Semantics
  **Rule:** Model `timeframe` as `description?` followed by one or more of `earliestdate`/`latestdate`, never plain `#PCDATA`.
  **Reason:** This reflects corrected baseline intent and uses the declared timeframe subelements consistently.
- **Topic:** External XML Validation Entry Point
  **Rule:** Keep fixture validation in `scripts/validate.sh` and validate arbitrary user XML through `scripts/validate-input.sh` (`--file`, `--xml`, or `--stdin`).
  **Reason:** This separates repository regression checks from ad-hoc user input validation without adding tooling complexity.
- **Topic:** Practical Payload Validation
  **Rule:** `scripts/validate-input.sh` should default to order-insensitive schema validation (normalize order, then run DTD/XSD), with `--strict` for original-order checks.
  **Reason:** Real-world vendor payloads vary in element order, but we still want full schema constraints enforced.
- **Topic:** Relaxed Contactability Guardrail
  **Rule:** In relaxed mode, require every customer `contact` to have at least one `email` or `phone`.
  **Reason:** Order can vary in vendor payloads, but leads without any customer contact method are not actionable.
