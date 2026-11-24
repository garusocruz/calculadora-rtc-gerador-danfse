#!/usr/bin/env bash
# Suíte do pin: pytest de situação e texto. Não clona o Go.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"
STEPS="${ROOT}/.ci/steps"
mkdir -p "${STEPS}"

if [[ -x "${ROOT}/.venv/bin/python" ]]; then
  PY="${ROOT}/.venv/bin/python"
elif command -v poetry >/dev/null 2>&1; then
  PY="$(poetry env info -e)"
else
  PY="python3"
fi

echo "── pin (situação e texto) ──"
set +e
"${PY}" -m pytest -q --junitxml="${STEPS}/pin-pytest.xml" >"${STEPS}/pin-pytest.txt" 2>&1
rc=$?
set -e
cat "${STEPS}/pin-pytest.txt"
if [[ "${rc}" -ne 0 ]]; then
  exit "${rc}"
fi

"${PY}" - "${STEPS}/pin-pytest.xml" "${STEPS}/pin-pytest.txt" "${STEPS}/equivalencia-resumo.json" "${STEPS}/cobertura-python.txt" <<'PY'
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

import calculadora_rtc_gerador_danfse.consumo as consumo

junit, log, resumo_path, cob_path = map(Path, sys.argv[1:])
root = ET.parse(junit).getroot()
suites = [root] if root.tag == "testsuite" else list(root.findall("testsuite"))
tests = failures = errors = skipped = 0
seconds = 0.0
for suite in suites:
    tests += int(suite.attrib.get("tests", 0))
    failures += int(suite.attrib.get("failures", 0))
    errors += int(suite.attrib.get("errors", 0))
    skipped += int(suite.attrib.get("skipped", 0))
    seconds += float(suite.attrib.get("time") or 0)
if failures or errors:
    raise SystemExit("a suíte do pin falhou")
text = log.read_text(encoding="utf-8")
match = re.search(r"^TOTAL\s+(\d+)\s+\d+\s+([0-9.]+)%", text, re.M)
if match is None:
    raise SystemExit("sem a linha TOTAL da cobertura")
cob_path.write_text(f"{match.group(1)} {match.group(2)}\n", encoding="utf-8")
banned = [
    nome
    for nome in consumo.__all__
    if any(parte in nome.lower() for parte in ("pdf", "render", "folio"))
]
if banned:
    raise SystemExit(
        "a fachada expõe desenho que esta suíte não cobre: " + ", ".join(banned)
    )
payload = {
    "pytest_passaram": tests - failures - errors - skipped,
    "pytest_ignorados": skipped,
    "pytest_segundos": round(seconds, 2),
}
resumo_path.write_text(json.dumps(payload), encoding="utf-8")
print(f"Pin: {payload['pytest_passaram']} passaram.")
PY
