import time
from datetime import datetime
import json
import requests

ARQUIVO_CONFIG = "config.json"
ARQUIVO_SITES = "sites.json"

# FUNÇÕES ---------------------------------------

def ler_json(nome_arquivo):

    try:
        with open(nome_arquivo, "r", encoding="utf-8") as arquivo_json:
            dados = json.load(arquivo_json)
        return dados
    except Exception as erro:
        print("Erro ao ler arquivo JSON:", erro)
        return False

def verificar_url(url, timeout = None):

    if(timeout is None):
        timeout = CONFIG["timeout"]

    try:
        tempo_inicio = time.perf_counter()
        resposta = requests.get(url, headers = HEADERS, timeout = timeout)
        duracao_requisicao = (time.perf_counter() - tempo_inicio)

        return {
            "status": resposta.status_code,
            "duracao": duracao_requisicao
        }

    except requests.RequestException as erro:
        print("Erro na requisição:", erro)
        return False      

# INÍCIO DO SCRIPT ------------------------------

if __name__ == "__main__":

    CONFIG = ler_json(ARQUIVO_CONFIG)
    sites = ler_json(ARQUIVO_SITES)["sites"]

    # Cabeçalho usado nas requisições
    HEADERS = {
        "User-Agent": (CONFIG["userAgent"])
    }

    while True:
        for site in sites:
            hora = datetime.now().strftime("%H:%M:%S.%f")[:-3]
            resposta = verificar_url(site["url"])
            print("Site:", site["nome"])
            print("Status:", resposta["status"])
            print("Hora:", hora)
            print(f'Duração: {resposta["duracao"]:.3f} seg')
            print("-" * 20)
        time.sleep(CONFIG["intervalo"])