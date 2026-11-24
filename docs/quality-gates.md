# calculadora-rtc-gerador-danfse — quality gates

O mesmo gancho local e o mesmo Cloud Build das outras calculadoras. Esta lib não aplica Terraform e não publica no Artifact Registry. Os triggers moram em `lynko-terraform`, no módulo `adapters/gcp/delivery/calculadora_cicd`.

A pull request roda a suíte do pin e os quality gates. Não publica. O push na `main` repete a suíte e, no mesmo run, faz o build, grava o README, publica no PyPI, abre a tag `vX.Y.Z` e abre a pull request do README de volta para a `main`. A tag só confere o que a `main` já publicou.

A suíte do pin é o pytest de situação da nota e de texto. Ela não compara PDF. O render com folio não entra enquanto essa comparação não existir. O código Go do pin não entra neste repositório.

## Cloud Build

| Trigger | Config | Quando |
| --- | --- | --- |
| `calculadora-rtc-gerador-danfse-pr` | `cloudbuild.yaml` | pull request para `main` |
| `calculadora-rtc-gerador-danfse-main` | `cloudbuild-prod.yaml` | push na `main` |
| `calculadora-rtc-gerador-danfse-release` | `cloudbuild-release.yaml` | tag `vX.Y.Z` |

Na pull request: `cancel-superseded-builds` → `equivalencia` → `quality-gates` → `report-pr` → `pipeline-gate`. O passo `equivalencia` roda `scripts/equivalencia.sh`, que é a suíte do pin sem PDF.

## Gates

| Gate | Notas |
| --- | --- |
| patterns | segredos, caminhos proibidos, `bash -n` |
| pytest + coverage | mínimo **80%** |
| Trivy | `v0.74.0` — HIGH e CRITICAL falham o build |
| pin | pytest de situação e texto; sem PDF |

Terraform fmt e validate ficam registrados como pulados. Este repositório não aplica `.tf` no Cloud Build.

## Local

```bash
bash scripts/bootstrap-dev.sh
bash scripts/ci-quality-gates.sh local
bash scripts/equivalencia.sh
```

| Gancho | Ferramenta |
| --- | --- |
| pre-commit | `scripts/hooks/check-patterns.sh staged` |
| commit-msg | conventional commit, sem atribuição ao Cursor |
| pre-push | `scripts/ci-quality-gates.sh local` e `scripts/equivalencia.sh` |
