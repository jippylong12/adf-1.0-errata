# Active Plan: timeframe model correction

1. Update canonical DTD
- Constraint: adopt user-provided corrected `timeframe` content model as source of truth.
- Constraint: preserve existing ADF element names and keep syntax machine-valid.

2. Update XSD equivalence
- Constraint: represent `timeframe` with ordered `description?` then `(earliestdate | latestdate)+`.
- Constraint: keep XSD readable and consistent with existing style.

3. Update examples and errata
- Constraint: adjust example XML to remain valid under revised schema.
- Constraint: add only necessary correction detail in `ERRATA.md`.

4. Verify and close
- Constraint: run `./scripts/validate.sh`.
- Constraint: run mandatory `Sentinel`, then `Chronicler` + `Historian`.
