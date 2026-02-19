# Active Plan: relaxed rule gap fix

1. Tighten relaxed customer checks
- Constraint: relaxed mode stays order-insensitive.
- Constraint: enforce customer contact has at least one `email` or `phone`.

2. Keep strict mode unchanged
- Constraint: `--strict` continues to use DTD/XSD as-is.

3. Validate behavior
- Constraint: confirm provided sample still passes relaxed mode.
- Constraint: confirm missing customer contact method fails relaxed mode.

4. Close with mandatory audits
- Constraint: run `Sentinel`, then `Chronicler` + `Historian`.
