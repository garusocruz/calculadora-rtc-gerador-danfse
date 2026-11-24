# Publicação do gerador de DANFSe

O push na `main` de uma versão que ainda não está no PyPI passa pelo quality gate e pela suíte do pin. No mesmo run faz o build da lib, grava o README com os insumos desse build e desse run, publica no PyPI, abre a tag `vX.Y.Z` e abre a pull request do README para a `main`. O merge seguinte encontra a versão no PyPI e na tag e não repete o build. O trigger da tag não publica. Não sobe para o Artifact Registry.

A suíte do pin não gera PDF. O README gravado por esse run diz isso. O render só entra quando houver uma suíte que compare com o folio do pin.

```mermaid
flowchart TD
  pr[Pull request para main] --> cancelaPr[cancela o build anterior da mesma pull request]
  cancelaPr --> pin[suíte do pin sem PDF]
  pin --> qg[quality-gates]
  qg --> comentarioPr[report-pr]
  comentarioPr --> fimPr[Não publica e não abre tag]
  merge[Push na main] --> cancelaMain[cancela o build anterior da main]
  cancelaMain --> tipo{Esta árvore já é a tag publicada?}
  tipo -->|não| jaPy{Esta versão já está no PyPI?}
  jaPy -->|sim| recusa[para e não publica de novo]
  jaPy -->|não| suite[suíte do pin e quality-gates]
  suite --> verde{Build verde?}
  verde -->|não| paraSuite[Não grava o README e não publica]
  verde -->|sim| build[build da lib]
  build --> readme[grava o README com o build e com o run]
  readme --> publica[constrói de novo, publica no PyPI e abre a tag]
  publica --> prReadme[abre a pull request do README para a main]
  tipo -->|sim| nada[não repete build, tag nem PyPI]
```
