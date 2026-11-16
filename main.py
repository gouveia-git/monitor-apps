import sys, time, json, requests
from datetime import datetime
from zoneinfo import ZoneInfo

ARQUIVO_CONFIG = "config.json"
ARQUIVO_SITES = "sites.json"
FUSO_BR = ZoneInfo("America/Fortaleza")

# FUNÇÕES AUXILIARES ----------------------------

def obter_hora():
    return datetime.now(FUSO_BR).strftime("%H:%M:%S.%f")[:-3]

def ler_json(nome_arquivo):

    try:
        with open(nome_arquivo, "r", encoding="utf-8") as arquivo_json:
            dados = json.load(arquivo_json)
        return dados
    except Exception as excecao:
        print("Erro ao ler JSON:", excecao)
        sys.exit(1)

def verificar_url(url, timeout = None):

    if(timeout is None):
        timeout = CONFIG["timeout"]

    tempo_inicio = time.perf_counter()

    try:
        status = requests.get(url, headers = HEADERS, timeout = timeout).status_code
    except:
        status = 0

    duracao_requisicao = (time.perf_counter() - tempo_inicio)

    return {
        "status": status,
        "duracao": duracao_requisicao
    }

# FUNÇÕES PRINCIPAIS ----------------------------

def ler_arquivos():

    global CONFIG, SITES

    CONFIG = ler_json(ARQUIVO_CONFIG)
    SITES = ler_json(ARQUIVO_SITES)["sites"]

def monitorar_apps():

    while True:
        for site in SITES:
            hora = obter_hora()
            resposta = verificar_url(site["url"])
            print(f'{hora} [{resposta["status"]}] {resposta["duracao"]:.3f} {site["nome"]}')
            print("-" * 20)
        time.sleep(CONFIG["intervalo"])

# INÍCIO DO SCRIPT ------------------------------

if __name__ == "__main__":

    ler_arquivos()

    # Cabeçalho usado nas requisições
    HEADERS = {
        "User-Agent": (CONFIG["userAgent"])
    }

    monitorar_apps()