from calculadora_rtc_gerador_danfse import (
    PIN_OFICIAL_COMMIT,
    PIN_OFICIAL_DATA,
    PIN_OFICIAL_VERSAO,
)
from calculadora_rtc_gerador_danfse.situacao import SituacaoNota, marca_dagua, situacao_por_stc
from calculadora_rtc_gerador_danfse.texto import sanitizar_ampersand, truncar_por_tamanho, truncar_texto


def test_pin_oficial_e_o_danfse_1_0_0() -> None:
    assert PIN_OFICIAL_VERSAO == "1.0.0"
    assert PIN_OFICIAL_COMMIT == "8d79e6b2f7fad6375340afcb51c85ed370c64a14"
    assert PIN_OFICIAL_DATA == "2026-10-22"


def test_situacao_por_stc_segue_o_pin() -> None:
    # situacao_test.go TestSituacaoNotaPorSTC
    assert situacao_por_stc(0) == (SituacaoNota.VALIDA, True)
    assert situacao_por_stc(1) == (SituacaoNota.SUBSTITUIDA, True)
    assert situacao_por_stc(2) == (SituacaoNota.CANCELADA, True)
    assert situacao_por_stc(3) == (SituacaoNota.VALIDA, False)


def test_marca_dagua() -> None:
    assert marca_dagua(SituacaoNota.CANCELADA) == "CANCELADA"
    assert marca_dagua(SituacaoNota.SUBSTITUIDA) == "SUBSTITUÍDA"
    assert marca_dagua(SituacaoNota.VALIDA) == ""


def test_ampersand_repete_os_quatro_casos_do_pin() -> None:
    # utils_strings_test.go TestSanitizarAmpersand_*
    entidades = "&amp; &lt; &gt; &quot; &apos; &#65; &#x41;"
    assert sanitizar_ampersand(entidades) == entidades
    assert sanitizar_ampersand("A & B") == "A &amp; B"
    assert sanitizar_ampersand("no ampersand here") == "no ampersand here"
    assert sanitizar_ampersand("safe &amp; unsafe & evil") == "safe &amp; unsafe &amp; evil"


def test_a_fachada_nao_expoe_pdf() -> None:
    import calculadora_rtc_gerador_danfse.consumo as consumo

    nomes = [nome.lower() for nome in consumo.__all__]
    assert not any("pdf" in nome or "render" in nome or "folio" in nome for nome in nomes)


def test_truncar_reserva_as_reticencias() -> None:
    assert truncar_por_tamanho("abcdef", 5) == "ab..."
    assert truncar_texto("", 2, 10) == ""
    assert truncar_texto("linha", 1, 3) == "lin..."
