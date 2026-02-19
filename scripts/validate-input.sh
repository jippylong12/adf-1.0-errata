#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DTD_PATH="${ROOT_DIR}/schema/adf-1.0-errata.dtd"
XSD_PATH="${ROOT_DIR}/schema/adf-1.0-errata.xsd"

INPUT_MODE=""
INPUT_FILE=""
INPUT_XML=""
VALIDATION_MODE="both"
VALIDATION_PROFILE="relaxed"
MODE_EXPLICIT="0"
TMP_FILE=""

usage() {
  cat <<'EOF'
Validate a user-provided ADF XML input against adf-1.0-errata schemas.

Usage:
  ./scripts/validate-input.sh --file <path> [--strict] [--mode dtd|xsd|both]
  ./scripts/validate-input.sh --xml '<xml-string>' [--strict] [--mode dtd|xsd|both]
  ./scripts/validate-input.sh --stdin [--strict] [--mode dtd|xsd|both]

Examples:
  # default: relaxed/order-insensitive checks
  ./scripts/validate-input.sh --file ./examples/full-prospect.xml

  # strict: enforce DTD/XSD ordering/content model
  ./scripts/validate-input.sh --file ./examples/full-prospect.xml --strict

  ./scripts/validate-input.sh --xml '<adf>...</adf>'
  cat ./examples/minimal-prospect.xml | ./scripts/validate-input.sh --stdin
EOF
}

cleanup() {
  if [[ -n "${TMP_FILE}" && -f "${TMP_FILE}" ]]; then
    rm -f "${TMP_FILE}"
  fi
}
trap cleanup EXIT

if ! command -v xmllint >/dev/null 2>&1; then
  echo "xmllint is required (install libxml2/libxml2-utils)." >&2
  exit 1
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      [[ $# -ge 2 ]] || { echo "Missing value for --file" >&2; exit 2; }
      [[ -z "${INPUT_MODE}" ]] || { echo "Choose only one input mode." >&2; exit 2; }
      INPUT_MODE="file"
      INPUT_FILE="$2"
      shift 2
      ;;
    --xml)
      [[ $# -ge 2 ]] || { echo "Missing value for --xml" >&2; exit 2; }
      [[ -z "${INPUT_MODE}" ]] || { echo "Choose only one input mode." >&2; exit 2; }
      INPUT_MODE="xml"
      INPUT_XML="$2"
      shift 2
      ;;
    --stdin)
      [[ -z "${INPUT_MODE}" ]] || { echo "Choose only one input mode." >&2; exit 2; }
      INPUT_MODE="stdin"
      shift
      ;;
    --mode)
      [[ $# -ge 2 ]] || { echo "Missing value for --mode" >&2; exit 2; }
      case "$2" in
        dtd|xsd|both) VALIDATION_MODE="$2" ;;
        *) echo "Invalid mode: $2 (expected dtd|xsd|both)" >&2; exit 2 ;;
      esac
      MODE_EXPLICIT="1"
      shift 2
      ;;
    --strict)
      VALIDATION_PROFILE="strict"
      shift
      ;;
    --relaxed)
      VALIDATION_PROFILE="relaxed"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

[[ -n "${INPUT_MODE}" ]] || {
  echo "You must provide one input mode: --file, --xml, or --stdin" >&2
  usage >&2
  exit 2
}

if [[ "${MODE_EXPLICIT}" == "1" && "${VALIDATION_PROFILE}" == "relaxed" ]]; then
  # Backwards-compatible behavior for users already using --mode.
  VALIDATION_PROFILE="strict"
fi

TARGET_XML=""
case "${INPUT_MODE}" in
  file)
    [[ -f "${INPUT_FILE}" ]] || { echo "File not found: ${INPUT_FILE}" >&2; exit 2; }
    TARGET_XML="${INPUT_FILE}"
    ;;
  xml)
    TMP_FILE="$(mktemp)"
    printf '%s\n' "${INPUT_XML}" > "${TMP_FILE}"
    TARGET_XML="${TMP_FILE}"
    ;;
  stdin)
    TMP_FILE="$(mktemp)"
    cat > "${TMP_FILE}"
    TARGET_XML="${TMP_FILE}"
    ;;
esac

overall=0

check_xpath() {
  local label="$1"
  local expr="$2"
  local out=""

  if ! out="$(xmllint --nonet --nowarning --xpath "boolean(${expr})" "${TARGET_XML}" 2>/dev/null)"; then
    echo "  FAIL: ${label}"
    overall=1
    return
  fi

  if [[ "${out}" == "true" ]]; then
    echo "  PASS: ${label}"
  else
    echo "  FAIL: ${label}"
    overall=1
  fi
}

if [[ "${VALIDATION_PROFILE}" == "relaxed" ]]; then
  echo "Relaxed validation (order-insensitive)"
  if xmllint --nonet --nowarning --noout "${TARGET_XML}"; then
    echo "  PASS: XML is well-formed"
  else
    echo "  FAIL: XML is not well-formed"
    overall=1
  fi

  if [[ "${overall}" -eq 0 ]]; then
    check_xpath "root element is <adf>" "/adf"
    check_xpath "at least one <prospect> exists" "count(/adf/prospect) >= 1"
    check_xpath "each <prospect> has a <requestdate>" "count(/adf/prospect[count(requestdate) < 1]) = 0"
    check_xpath "each <prospect> has one or more <vehicle>" "count(/adf/prospect[count(vehicle) < 1]) = 0"
    check_xpath "each <prospect> has a <customer>" "count(/adf/prospect[count(customer) < 1]) = 0"
    check_xpath "each <prospect> has a <vendor>" "count(/adf/prospect[count(vendor) < 1]) = 0"
    check_xpath "each <vehicle> has <year>, <make>, and <model>" "count(/adf/prospect/vehicle[count(year) < 1 or count(make) < 1 or count(model) < 1]) = 0"
    check_xpath "each <customer> has a <contact>" "count(/adf/prospect/customer[count(contact) < 1]) = 0"
    check_xpath "each customer <contact> has at least one <name>" "count(/adf/prospect/customer/contact[count(name) < 1]) = 0"
    check_xpath "each customer <contact> has at least one <email> or <phone>" "count(/adf/prospect/customer/contact[count(email) + count(phone) < 1]) = 0"
    check_xpath "each <vendor> has <vendorname> and <contact>" "count(/adf/prospect/vendor[count(vendorname) < 1 or count(contact) < 1]) = 0"
    check_xpath "each vendor <contact> has at least one <name>" "count(/adf/prospect/vendor/contact[count(name) < 1]) = 0"
  fi
else
  if [[ "${VALIDATION_MODE}" == "dtd" || "${VALIDATION_MODE}" == "both" ]]; then
    echo "DTD validation (strict)"
    if xmllint --nonet --nowarning --noout --dtdvalid "${DTD_PATH}" "${TARGET_XML}"; then
      echo "  PASS"
    else
      echo "  FAIL"
      overall=1
    fi
  fi

  if [[ "${VALIDATION_MODE}" == "xsd" || "${VALIDATION_MODE}" == "both" ]]; then
    echo "XSD validation (strict)"
    if xmllint --nonet --nowarning --noout --schema "${XSD_PATH}" "${TARGET_XML}"; then
      echo "  PASS"
    else
      echo "  FAIL"
      overall=1
    fi
  fi
fi

if [[ "${overall}" -eq 0 ]]; then
  echo "Validation PASSED."
else
  echo "Validation FAILED." >&2
  exit 1
fi
