"""Situação da NFS-e no DANFSe. Pin ``8d79e6b2``, ``SituacaoNotaPorSTC``."""

from __future__ import annotations

from enum import Enum


class SituacaoNota(Enum):
    VALIDA = "valida"
    SUBSTITUIDA = "substituida"
    CANCELADA = "cancelada"


def situacao_por_stc(stc: int) -> tuple[SituacaoNota, bool]:
    if stc == 0:
        return SituacaoNota.VALIDA, True
    if stc == 1:
        return SituacaoNota.SUBSTITUIDA, True
    if stc == 2:
        return SituacaoNota.CANCELADA, True
    return SituacaoNota.VALIDA, False


def marca_dagua(situacao: SituacaoNota) -> str:
    if situacao is SituacaoNota.CANCELADA:
        return "CANCELADA"
    if situacao is SituacaoNota.SUBSTITUIDA:
        return "SUBSTITUÍDA"
    return ""
