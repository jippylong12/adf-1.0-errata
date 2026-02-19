# ERRATA

The ADF 1.0 appendix text as rendered in PDF includes typesetting and transcription issues.
This repository records the minimum corrections needed to produce a machine-valid, internally consistent baseline.

| Location (element/attribute) | PDF text (verbatim snippet if available) | Correction | Why |
| --- | --- | --- | --- |
| `prospect@status` | `<!ATTLIST prospect status (new \| resend) “new”>` | Use ASCII quotes: `"new"` | Typesetting quotes break DTD parsing. |
| `vehicle@status` | `<!ATTLIST vehicle status (new \| used) “new”>` | Use ASCII quotes: `"new"` | Typesetting quotes break DTD parsing. |
| `email@preferredcontact` | `<!ATTLIST email preferredcontact (0 \| 1) “0”>` | Use ASCII quotes: `"0"` | Typesetting quotes break DTD parsing. |
| `vehicle` content model | `... transmission?, odometer?, colorcombination* ...` | Add `condition?` after `odometer?` | `condition` is declared but omitted in the vehicle content model. |
| `colorcombination` content model | `(((interiorcolor \| exteriorcolor) \| (interiorcolor, exteriorcolor)), preference)` | Use deterministic equivalent: `(((interiorcolor, exteriorcolor?) \| exteriorcolor), preference)` | Original form is non-deterministic and triggers parser validity errors. |
| Vehicle core elements | No `<!ELEMENT year ...>`, `make`, `model`, `vin`, `trim`, `doors`, `bodystyle` declarations in appendix excerpt | Add missing `#PCDATA` element declarations | Required for a complete, validating schema because these elements appear in `vehicle`. |
| `option` content model | `<!ELEMENT option (optionname, manufacturercode?, stock?, weighting price?)>` | Insert missing comma: `weighting, price?` | DTD syntax invalid without separator. |
| `contact` content model | `(name+, ((email \| phone+) \| (email, phone+)), address?)` | Use deterministic equivalent: `(name+, ((email, phone*) \| phone+), address?)` | Original form is non-deterministic and triggers parser validity errors. |
| `contact@primarycontact` | Not present in appendix excerpt | Add `<!ATTLIST contact primarycontact (1 \| 0) #IMPLIED>` | Corrected baseline includes this attribute; `#IMPLIED` was required to make the declaration syntactically valid. |
| `timeframe` content model | `<!ELEMENT timeframe (#PCDATA)>` | Use structured model: `description?, (earliestdate \| latestdate)+` | Aligns with corrected baseline and with declared timeframe subelements. |
| `name@part` | `part (surname \| first \| middle \| last \| full)` | Use corrected baseline enumeration: `(first \| middle \| suffix \| last \| full)` | Aligns with intended corrected baseline. |
| `comments` element | `<!ELEMENT comments (PCDATA)>` | Use `<!ELEMENT comments (#PCDATA)>` | DTD syntax invalid without `#`. |
