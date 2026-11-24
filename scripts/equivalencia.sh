#!/usr/bin/env bash
# Baixa o gerador oficial no pin e roda o go test dos pacotes portados.
# A equivalência só fecha quando cada teste Go passou e a lib tem o mesmo
# nome, com o mesmo resultado. O PDF, o Echo, o WASM e a telemetria ficam
# fora do corte, como o controller fica fora nas outras calculadoras.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="${HOME}/.local/bin:${HOME}/.asdf/shims:${PATH}"
OFICIAL_URL="${OFICIAL_URL:-https://github.com/ReceitaFederal/calculadora-rtc-gerador-danfse.git}"
OFICIAL_SHA="${OFICIAL_SHA:-8d79e6b2f7fad6375340afcb51c85ed370c64a14}"
CACHE="${ROOT}/.cache/oficial"
PIN_DIR="${CACHE}/pin"
RELATORIO="${CACHE}/relatorio"
GO_SDK="${CACHE}/go-sdk"
CORTE=(
  ./internal/domain/enums
  ./internal/domain/utils/utils_string
)

clonar() {
  local url="$1" sha="$2" destino="$3"
  if [[ ! -d "${destino}/.git" ]]; then
    rm -rf "${destino}"
    git init "${destino}"
    git -C "${destino}" remote add origin "${url}"
  fi
  git -C "${destino}" fetch --depth 1 origin "${sha}"
  git -C "${destino}" checkout --detach FETCH_HEAD
}

garantir_go() {
  local menor="$1"
  if [[ -x "${GO_SDK}/bin/go" ]] && "${GO_SDK}/bin/go" version | grep -q "go${menor}"; then
    return 0
  fi
  local arch arquivo
  case "$(uname -m)" in
    x86_64|amd64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *)
      echo "Arquitetura sem toolchain Go: $(uname -m)" >&2
      exit 1
      ;;
  esac
  arquivo="$(curl -fsSL 'https://go.dev/dl/?mode=json&include=all' | python3 -c '
import json, sys
menor, arch = sys.argv[1], sys.argv[2]
for rel in json.load(sys.stdin):
    if not rel["version"].startswith("go" + menor + "."):
        continue
    for item in rel["files"]:
        if item.get("os") == "linux" and item.get("arch") == arch and item.get("kind") == "archive":
            print(item["filename"])
            raise SystemExit
raise SystemExit("sem tarball linux/" + arch + " para go " + menor)
' "${menor}" "${arch}")"
  echo "── baixando ${arquivo} ──"
  local pacote
  pacote="$(mktemp)"
  curl -fsSL "https://go.dev/dl/${arquivo}" -o "${pacote}"
  rm -rf "${GO_SDK}"
  mkdir -p "${CACHE}"
  tar -C "${CACHE}" -xzf "${pacote}"
  rm -f "${pacote}"
  rm -rf "${GO_SDK}"
  mv "${CACHE}/go" "${GO_SDK}"
}

echo "── equivalência: baixando ${OFICIAL_SHA} ──"
clonar "${OFICIAL_URL}" "${OFICIAL_SHA}" "${PIN_DIR}"
menor="$(awk '/^go[[:space:]]/{print $2; exit}' "${PIN_DIR}/go.mod")"
if [[ -z "${menor}" ]]; then
  echo "go.mod do pin sem versão." >&2
  exit 1
fi
garantir_go "${menor}"
export PATH="${GO_SDK}/bin:${PATH}"
export GOTOOLCHAIN="local"

mkdir -p "${RELATORIO}"
echo "── go test ${CORTE[*]} ──"
(
  cd "${PIN_DIR}"
  go test -json "${CORTE[@]}" >"${RELATORIO}/go.json"
)

echo "── suíte Python ──"
cd "${ROOT}"
if [[ -x "${ROOT}/.venv/bin/python" ]]; then
  PY="${ROOT}/.venv/bin/python"
else
  PY="python3"
fi
"${PY}" -m pytest -q --junitxml="${RELATORIO}/python.xml"

mkdir -p "${ROOT}/.ci/steps"
"${PY}" - "${RELATORIO}/go.json" "${RELATORIO}/python.xml" "${ROOT}/.ci/steps/equivalencia-resumo.json" "${ROOT}/.ci/steps/cobertura-python.txt" <<'PY'
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

go_json, python_xml, resumo_path, cob_path = map(Path, sys.argv[1:])

def chave(nome: str) -> str:
    return nome.replace("/", "_")

go = {}
for linha in go_json.read_text(encoding="utf-8").splitlines():
    if not linha.strip():
        continue
    evento = json.loads(linha)
    nome = evento.get("Test") or ""
    acao = evento.get("Action") or ""
    if not nome or acao not in {"pass", "fail", "skip"}:
        continue
    go[chave(nome)] = "passou" if acao == "pass" else ("ignorado" if acao == "skip" else "falha")

python = {}
for caso in ET.parse(python_xml).getroot().iter("testcase"):
    nome = caso.get("name") or ""
    if caso.find("failure") is not None or caso.find("error") is not None:
        estado = "falha"
    elif caso.find("skipped") is not None:
        estado = "ignorado"
    else:
        estado = "passou"
    python[chave(nome)] = estado

faltam = []
divergem = []
for nome, estado_go in sorted(go.items()):
    estado_python = python.get(nome)
    if estado_python is None:
        faltam.append(nome)
        continue
    if estado_go == estado_python == "ignorado":
        continue
    if estado_go != "passou" or estado_python != "passou":
        divergem.append((nome, estado_go, estado_python))

raiz = ET.parse(python_xml).getroot()
suites = [raiz] if raiz.tag == "testsuite" else list(raiz.findall("testsuite"))
testes = ignorados = falhas = erros = 0
tempo = 0.0
for suite in suites:
    testes += int(suite.get("tests") or 0)
    ignorados += int(suite.get("skipped") or 0)
    falhas += int(suite.get("failures") or 0)
    erros += int(suite.get("errors") or 0)
    tempo += float(suite.get("time") or 0)

print(f"Go: {len(go)}")
print(f"Python: {len(python)} casos no relatório")
print(f"Casos Go sem o mesmo teste na lib: {len(faltam)}")
print(f"Casos com resultado diferente: {len(divergem)}")
for nome in faltam[:20]:
    print(f"  falta {nome}")
for nome, eg, ep in divergem[:20]:
    print(f"  diverge {nome} go={eg} python={ep}")
if faltam or divergem:
    raise SystemExit(1)

resumo = {
    "pytest_passaram": testes - ignorados - falhas - erros,
    "pytest_ignorados": ignorados,
    "pytest_segundos": round(tempo, 2),
    "go_testes": len(go),
    "python_chaves": len(python),
    "sem_par": 0,
    "diferente": 0,
    "pdf": "nao",
}
resumo_path.write_text(json.dumps(resumo), encoding="utf-8")
print("Equivalência: a mesma suíte passou nas duas.")
PY
echo "── equivalência OK ──"
