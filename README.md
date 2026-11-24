# calculadora-rtc-gerador-danfse

DANFSe em Python. É uma implementação independente do gerador que a Receita Federal publicou em Go, no commit pinado. Não é um fork: o código Go não entra neste repositório.

Não é projeto oficial, produto homologado, certificado ou mantido pela Receita Federal do Brasil nem pelo Serpro. Não é parecer, orientação ou consultoria tributária. Não emite NFS-e e não chama a Sefin.

**Nossas** (esta implementação em Python, MIT, Copyright (c) 2026 Garuso Cruz)

[![nossa licença MIT](https://img.shields.io/badge/nossa%20licen%C3%A7a-MIT%20Garuso%20Cruz-green)](LICENSE)

**Do pin oficial** (danfse-service 1.0.0, commit `8d79e6b2`, MIT, Copyright (c) 2026 Receita Federal do Brasil)

[![pin oficial 8d79e6b2](https://img.shields.io/badge/pin%20oficial-8d79e6b2-orange)](https://github.com/ReceitaFederal/calculadora-rtc-gerador-danfse/commit/8d79e6b2f7fad6375340afcb51c85ed370c64a14)
[![licença do pin MIT](https://img.shields.io/badge/licen%C3%A7a%20do%20pin-MIT%20Receita%20Federal-blue)](LICENSE-RECEITA.md)

| | |
| --- | --- |
| Fonte oficial | [ReceitaFederal/calculadora-rtc-gerador-danfse](https://github.com/ReceitaFederal/calculadora-rtc-gerador-danfse) |
| Versão oficial do pin | danfse-service `1.0.0`, commit de 2026-10-22 |
| Commit pinado | [`8d79e6b2f7fad6375340afcb51c85ed370c64a14`](https://github.com/ReceitaFederal/calculadora-rtc-gerador-danfse/commit/8d79e6b2f7fad6375340afcb51c85ed370c64a14) |
| Licenças | [LICENSE](LICENSE) (nossa) e [LICENSE-RECEITA.md](LICENSE-RECEITA.md) (Receita, sobre o Go do pin) |

## Limite de uso

Quem consome chama `calculadora_rtc_gerador_danfse.consumo`. O servidor Echo, o WASM, o Swagger e a telemetria ficam no Go.

| O que | Nesta versão |
| --- | --- |
| Situação da nota (`stc`) e marca d'água | sim, o mesmo `SituacaoNotaPorSTC` do pin |
| `&` solto no XML e corte de texto | sim, o mesmo `utils_strings` do pin |
| PDF do DANFSe | não; o pin desenha com folio e esta lib ainda não reproduz esse render |
| HTTP, WASM, OTel e health | não |
| Emissão de NFS-e e chamada à Sefin | não |
| Parecer ou enquadramento tributário | não |

O cálculo de CBS e IBS não mora aqui. Ele está nas libs `calculadora-rtc-regime-regular` e `calculadora-rtc-simples-nacional`.

## Licença

| Obra | Licença | Arquivo |
| --- | --- | --- |
| Esta implementação em Python | MIT, Copyright (c) 2026 Garuso Cruz | [LICENSE](LICENSE) |
| danfse-service, commit `8d79e6b2f7fad6375340afcb51c85ed370c64a14` | MIT, Copyright (c) 2026 Receita Federal do Brasil | [LICENSE-RECEITA.md](LICENSE-RECEITA.md) |

A MIT da Receita não transfere a titularidade do código dela.

## CI

O CI é o Cloud Build, sem workflow do GitHub Actions. A pull request dispara `calculadora-rtc-gerador-danfse-pr` e não publica. O push na `main` dispara `calculadora-rtc-gerador-danfse-main`. Depois do quality gate, o mesmo run faz o build da lib, grava o README com esse build e com esse run, publica no PyPI, abre a tag `vX.Y.Z` e abre a pull request que devolve o README para a `main`. O merge dessa pull request vê a versão já publicada e não repete o build.

A tag `vX.Y.Z` dispara `calculadora-rtc-gerador-danfse-release`. Esse passo não publica de novo: confere o README e que o PyPI já tem a versão gravada no bloco abaixo.

A suíte do pin é o pytest de situação da nota e de texto. Ela não compara PDF. O render com folio não entra enquanto essa comparação não existir. O código Go do pin não entra neste repositório.

O número deste repositório não vira release no GitHub.

<!-- release-runs:start -->
Ainda não há release publicada.
<!-- release-runs:end -->

<a id="ultima-validacao"></a>

## Última validação

Ainda não há run de publicação. O PDF não entra.

<a id="atualizacao-do-pin"></a>

## Desenvolvimento

```bash
cd libs/calculadora-rtc-gerador-danfse
bash scripts/bootstrap-dev.sh
```
