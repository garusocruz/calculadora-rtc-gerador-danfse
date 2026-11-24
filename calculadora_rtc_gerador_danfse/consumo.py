"""Fachada de consumo. Sem HTTP, sem WASM e sem telemetria.

O PDF do DANFSe ainda não entra nesta fachada. O pin desenha com folio;
esta lib ainda não reproduz esse render.
"""

from calculadora_rtc_gerador_danfse.situacao import (
    SituacaoNota,
    marca_dagua,
    situacao_por_stc,
)
from calculadora_rtc_gerador_danfse.texto import (
    sanitizar_ampersand,
    truncar_com_reticencias,
    truncar_por_tamanho,
    truncar_texto,
)

__all__ = [
    "SituacaoNota",
    "marca_dagua",
    "sanitizar_ampersand",
    "situacao_por_stc",
    "truncar_com_reticencias",
    "truncar_por_tamanho",
    "truncar_texto",
]
