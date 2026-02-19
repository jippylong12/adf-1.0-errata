# adf-1.0-errata

Community-maintained errata: a clean, machine-valid ADF 1.0 DTD + XSD, plus documentation of spec typos.

This repository is an errata baseline for Appendix DTD content from ADF 1.0.
It is not an official standard publication, and it does not define a new ADF version.

## Quickstart

Prerequisite: `xmllint` (from `libxml2`).

Validate both examples against both schemas:

```bash
./scripts/validate.sh
```

Validate your own ADF XML input (file/string/stdin):

```bash
# default: order-insensitive schema validation (reorders known children, then validates DTD/XSD)
./scripts/validate-input.sh --file /path/to/lead.xml
./scripts/validate-input.sh --xml '<adf>...</adf>'
cat /path/to/lead.xml | ./scripts/validate-input.sh --stdin

# strict: original-order DTD/XSD validation
./scripts/validate-input.sh --file /path/to/lead.xml --strict

# relaxed: lightweight checks (well-formed + required business tags)
./scripts/validate-input.sh --file /path/to/lead.xml --relaxed
```

Run one-off checks manually:

```bash
xmllint --noout --dtdvalid schema/adf-1.0-errata.dtd examples/minimal-prospect.xml
xmllint --noout --schema schema/adf-1.0-errata.xsd examples/minimal-prospect.xml
```

## Repository layout

```text
.
├── CONTRIBUTING.md
├── ERRATA.md
├── LICENSE
├── README.md
├── examples/
│   ├── full-prospect.xml
│   └── minimal-prospect.xml
├── schema/
│   ├── adf-1.0-appendix-verbatim.txt
│   ├── adf-1.0-errata.dtd
│   └── adf-1.0-errata.xsd
└── scripts/
    ├── validate-input.sh
    └── validate.sh
```

## Compatibility note

Real-world vendor endpoints may accept subsets/supersets; this repo provides a consistent baseline.
