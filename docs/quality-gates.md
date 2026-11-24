# calculadora-rtc-gerador-danfse — quality gates

Os mesmos ganchos locais e os mesmos quality gates de Cloud Build das outras calculadoras. Esta lib não aplica Terraform e não publica no Artifact Registry. Os triggers moram em `lynko-terraform`, no módulo `adapters/gcp/delivery/calculadora_cicd`. A pull request roda os gates e a suíte do pin. O push na `main` repete os gates e, no mesmo run, faz o build da lib, grava o README com esse build e com esse run, publica no PyPI, abre a tag `vX.Y.Z` e abre a pull request do README de volta para a `main`. Um push seguinte cuja árvore já é essa tag não repete nada. Se a versão está no PyPI e a árvore não é a da tag, a esteira para e não publica essa versão de novo. O trigger da tag só confere.

## Cloud Build

| Trigger | Config | Quando |
| --- | --- | --- |
| `calculadora-rtc-gerador-danfse-pr` | `cloudbuild.yaml` | pull request para `main` |
| `calculadora-rtc-gerador-danfse-main` | `cloudbuild-prod.yaml` | push na `main` |
| `calculadora-rtc-gerador-danfse-release` | `cloudbuild-release.yaml` | tag `vX.Y.Z` |

Na pull request: `cancel-superseded-builds` → `equivalencia` → `quality-gates` → `report-pr` → `pipeline-gate`. Na main, depois do quality gate: `build-lib` → `atualizar-readme` → `publicar` → `abrir-pr` → `report-pr` → `pipeline-gate`. O push cuja árvore já é a da tag publicada pula a suíte. Se a versão já está no PyPI e a árvore não é a da tag, a esteira para e não publica essa versão de novo. Na tag, o cancelamento sai sem cancelar e o passo `publicar` só confere o README e o PyPI.

## Gates

| Gate | Notas |
| --- | --- |
| patterns | segredos, caminhos proibidos, `bash -n` |
| pytest + coverage | mínimo **80%** |
| Trivy | `v0.74.0` — HIGH e CRITICAL falham o build |
| pin | `go test` de `enums` e `utils_string`; cada teste Go tem o mesmo nome e o mesmo resultado no pytest; PDF fora do corte |

Terraform fmt e validate ficam registrados como pulados. O `deploy/terraform` é a cópia vendida, com `create_feature_triggers`, `create_rc_triggers` e `create_prod_triggers` em `false`. Este repositório não aplica esses `.tf` no Cloud Build.

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
| pre-push | `scripts/hooks/audit-version.sh`, depois `scripts/ci-quality-gates.sh local` e `scripts/equivalencia.sh` |
