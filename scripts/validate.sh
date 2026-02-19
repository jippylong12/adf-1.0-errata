#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DTD_PATH="${ROOT_DIR}/schema/adf-1.0-errata.dtd"
XSD_PATH="${ROOT_DIR}/schema/adf-1.0-errata.xsd"
EXAMPLES=(
  "${ROOT_DIR}/examples/minimal-prospect.xml"
  "${ROOT_DIR}/examples/full-prospect.xml"
)

if ! command -v xmllint >/dev/null 2>&1; then
  echo "xmllint is required (install libxml2/libxml2-utils)." >&2
  exit 1
fi

echo "DTD validation"
for xml in "${EXAMPLES[@]}"; do
  echo "  - ${xml##*/}"
  xmllint --noout --dtdvalid "${DTD_PATH}" "${xml}"
done

echo "XSD validation"
for xml in "${EXAMPLES[@]}"; do
  echo "  - ${xml##*/}"
  xmllint --noout --schema "${XSD_PATH}" "${xml}"
done

echo "All validations passed."

