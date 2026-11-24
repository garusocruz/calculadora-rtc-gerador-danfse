"""Corte de texto e o ``&`` solto do XML. Pin ``8d79e6b2``, ``utils_strings``."""

from __future__ import annotations

import math
import re

_ENTIDADE_XML = re.compile(r"^&(?:amp|lt|gt|quot|apos|#[0-9]+|#x[0-9a-fA-F]+);")


def sanitizar_ampersand(xml: str) -> str:
    if "&" not in xml:
        return xml
    partes: list[str] = []
    for indice, caractere in enumerate(xml):
        if caractere == "&" and _ENTIDADE_XML.match(xml[indice:]) is None:
            partes.append("&amp;")
            continue
        partes.append(caractere)
    return "".join(partes)


def truncar_texto(texto: str, max_linhas: int, max_cars: int) -> str:
    if texto == "" or max_linhas <= 0 or max_cars <= 0:
        return ""
    segmentos = texto.split("\n")
    saida: list[str] = []
    usadas = 0
    truncou = False
    for segmento in segmentos:
        if usadas >= max_linhas:
            truncou = True
            break
        runas = list(segmento)
        necess = 1 if len(runas) == 0 else math.ceil(len(runas) / max_cars)
        if usadas + necess <= max_linhas:
            saida.append(segmento)
            usadas += necess
            continue
        limite = (max_linhas - usadas) * max_cars
        saida.append("".join(runas[:limite]) if len(runas) > limite else segmento)
        usadas = max_linhas
        truncou = True
        break
    resultado = "\n".join(saida)
    if truncou:
        resultado = resultado.rstrip(" \n") + "..."
    return resultado


def truncar_por_tamanho(texto: str, max_cars: int) -> str:
    runas = list(texto)
    if len(runas) <= max_cars:
        return texto
    limite = max(max_cars - 3, 0)
    return "".join(runas[:limite]).rstrip(" \n") + "..."


def truncar_com_reticencias(texto: str, max_conteudo: int) -> str:
    runas = list(texto)
    if len(runas) <= max_conteudo:
        return texto
    if max_conteudo < 0:
        max_conteudo = 0
    return "".join(runas[:max_conteudo]).rstrip(" \n") + "..."
