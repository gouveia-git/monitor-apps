import time
from datetime import datetime
import json
import requests

ARQUIVO_SITES = "sites.json"
TIMEOUT = 10

# FUNÇÕES ---------------------------------------

def ler_json(nome_arquivo):

    try:
        with open(nome_arquivo, "r", encoding="utf-8") as arquivo_json:
            dados = json.load(arquivo_json)
        return dados
    except:
        print("Erro ao ler arquivo JSON.")
        return False

def verificar_url(url, timeout = TIMEOUT):

    try:
        tempo_inicio = time.perf_counter()

        resposta = requests.get(url, timeout = timeout)

        tempo = (time.perf_counter() - tempo_inicio)

        return {
            "status": resposta.status_code,
            "tempo": tempo
        }

    except requests.RequestException as erro:
        print("Erro na requisição:", erro)
        return False      

# INÍCIO DO SCRIPT ------------------------------

if __name__ == "__main__":

    sites = ler_json(ARQUIVO_SITES)["sites"]

    while True:
        for site in sites:
            hora = datetime.now().strftime("%H:%M:%S.%f")[:-3]
            resposta = verificar_url(site["url"])
            print("Site:", site["nome"])
            print("Status:", resposta["status"])
            print("Hora:", hora)
            print(f'Tempo: {resposta["tempo"]:.3f} seg')
            print("-" * 20)
        time.sleep(2)