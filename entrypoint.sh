#!/bin/bash

# ===============================================
# VARIÁVEIS
# ===============================================

: "${USER_AGENT:="Monitor-apps"}"
: "${INTERVALO:=5}"
: "${SITE_LENTO:=5}"
: "${TIMEOUT:=15}"
: "${MAX_FALHAS:=3}"

: "${MAX_FALHAS_HIST:=3}"
: "${TEMPO_MAX_HIST:=600}"

declare -A SITES # Lista de sites
declare -A ERROS # Sites com erro
declare -A LENTOS # Sites lentos
declare -A HIST_PROBLEMAS # Histórico de problemas
ARQUIVO_SITES="sites.conf"
PRIMEIRA_EXECUCAO="N"
LINHA="---------------------"

# ===============================================
# FUNÇÕES DE EXIBIÇÃO
# ===============================================

exibir-cabecalho() {
    echo $LINHA
    echo "Monitorando apps"
    echo "[$(obter-data)]"
    echo $LINHA
    echo "Logs: /root/log"
    echo "Intervalo: $INTERVALO seg"
    echo "Timeout: $TIMEOUT seg"
    echo "Sites: ${#SITES[@]}"
}

exibir-info() {
    echo $LINHA
    echo -e "$1"
}

# ===============================================
# FUNÇÕES DE MONITORAMENTO
# ===============================================

obter-resposta() {
    curl -Ls \
        -A "$USER_AGENT" \
        -o /dev/null \
        -w "%{http_code} %{time_total}" \
        --connect-timeout "$TIMEOUT" \
        --max-time "$TIMEOUT" \
        "https://$1"
}

# ===============================================
# FUNÇÕES AUXILIARES
# ===============================================

obter-data() {
    date "+%d/%m/%Y %H:%M:%S"
}

enviar-mensagem() {
    curl -H "Content-Type: application/json" \
        -X POST \
        -d "$(printf '{"content":"%s"}' "$1")" \
        --connect-timeout 30 \
        --max-time 30 \
        "$WEBHOOK" \
        >/dev/null 2>&1
}

enviar-cartao() {

    if [[ "$3" == "VERDE" ]]
    then
        COR=5763719
    elif [[ "$3" == "AMARELO" ]]
    then
        COR=16776960
    elif [[ "$3" == "VERMELHO" ]]
    then
        COR=16711680
    elif [[ "$3" == "AZUL" ]]
    then
        COR=3447003
    else 
        COR=16777215 # Branco
    fi

    curl -H "Content-Type: application/json" \
        -X POST \
        -d "$(printf \
            '{
                "embeds":[
                    {
                        "title":"%s",
                        "description":"%s",
                        "color":%d
                    }
                ]
            }' "$1" "$2" "$COR")" \
        --connect-timeout 30 \
        --max-time 30 \
        "$WEBHOOK" \
        >/dev/null 2>&1
}

# ===============================================
# FUNÇÕES DE ARQUIVO
# ===============================================

escrever-arquivo() {
    echo $1 >> $2
}

ler-arquivo-sites() {
    while IFS='=' read -r NOME URL
    do
        [[ -z "$NOME" ]] && continue
        SITES["$NOME"]="$URL"
    done < "$ARQUIVO_SITES"
}

# ===============================================
# LOOP DE MONITORAMENTO
# ===============================================

ler-arquivo-sites
exibir-cabecalho
TIMESTAMP_INICIO_HIST=$(date +"%s")

# Loop principal
while true
do
    # Loop de leitura de SITES
    for SITE in "${!SITES[@]}"
    do
        DATA=$(obter-data)
        URL=${SITES[$SITE]}

        RESPOSTA=$(obter-resposta $URL)
        STATUS=$(echo "$RESPOSTA" | awk '{print $1}')
        TEMPO_RESPOSTA=$(echo "$RESPOSTA" | awk '{print $2}')

        CONTEUDO_ARQUIVO="[$DATA] Status = $STATUS, tempo = $TEMPO_RESPOSTA seg"

        PASTA="log/$(date "+%Y/%m/%d")"
        ARQUIVO="${PASTA}/${SITE}.log"
        mkdir -p $PASTA

        if [ "$PRIMEIRA_EXECUCAO" == "N" ]
        then
            escrever-arquivo "$LINHA" "$ARQUIVO"
            escrever-arquivo "$URL" "$ARQUIVO"
            escrever-arquivo "$LINHA" "$ARQUIVO"
        fi

        escrever-arquivo "$CONTEUDO_ARQUIVO" "${PASTA}/${SITE}.log"
        
        # Sucesso ao acessar site
        if [[ "$STATUS" -ge 200 && "$STATUS" -lt 400 ]]
        then
            
            # Site com tempo de resposta normal
            if awk "BEGIN {exit !($TEMPO_RESPOSTA < $SITE_LENTO)}"
            then
                # Site restabelecido
                if (( ERROS[$SITE] == MAX_FALHAS + 1 || LENTOS[$SITE] == MAX_FALHAS + 1 ))
                then
                    URL="https://${SITES[$SITE]}"
                    MENSAGEM="${DATA}\nSite restabelecido: $SITE\n${URL}"
                    enviar-cartao "Site restabelecido" "$MENSAGEM" "VERDE" &
                    exibir-info "$MENSAGEM"
                fi

                ERROS["$SITE"]=0
                LENTOS["$SITE"]=0

            # Site com tempo de resposta alto
            else
                ((LENTOS["$SITE"] += 1))
                ((HIST_PROBLEMAS["$SITE"] += 1))
            fi
        
        # Erro ao acessar site
        else
            ((ERROS["$SITE"] += 1))
            ((HIST_PROBLEMAS["$SITE"] += 1))
        fi

        # Site lento
        if (( LENTOS[$SITE] == MAX_FALHAS + 1 ))
        then
            URL="https://${SITES[$SITE]}"
            MENSAGEM="${DATA}\nSite lento: $SITE\n${URL}"
            enviar-cartao "Site lento" "$MENSAGEM" "LARANJA" &
            exibir-info "$MENSAGEM"
            HIST_PROBLEMAS["$SITE"]=0
        fi

        # Site inacessível
        if (( ERROS[$SITE] == MAX_FALHAS + 1 ))
        then
            URL="https://${SITES[$SITE]}"
            MENSAGEM="${DATA}\nSite inacessível: $SITE\n${URL}"
            enviar-cartao "Site inacessível" "$MENSAGEM" "VERMELHO" &
            exibir-info "$MENSAGEM"
            HIST_PROBLEMAS["$SITE"]=0
        fi

        # Site com histórico ruim
        if (( HIST_PROBLEMAS[$SITE] == MAX_FALHAS_HIST + 1 ))
        then
            URL="https://${SITES[$SITE]}"
            MENSAGEM="${DATA}\nSite com problemas: $SITE\n${URL}"
            enviar-cartao "Site com histórico ruim" "$MENSAGEM" "AMARELO" &
            exibir-info "$MENSAGEM"
            HIST_PROBLEMAS["$SITE"]=0
        fi

    done

    # Primeira execução do script
    if [ "$PRIMEIRA_EXECUCAO" == "N" ]
    then
        PRIMEIRA_EXECUCAO="S"
        DATA="$(obter-data)"
        MENSAGEM="${DATA}\nAplicação iniciada\nSites monitorados: ${#SITES[@]}"
        enviar-cartao "Monitoramento iniciado" "$MENSAGEM" &
    fi

    # Verifica se o tempo máximo do histórico foi atingido
    if (( $(date +"%s") - TIMESTAMP_INICIO_HIST > TEMPO_MAX_HIST ))
    then
        # Zera o histórico dos sites
        for SITE in "${!SITES[@]}"
        do
            HIST_PROBLEMAS["$SITE"]=0
        done

        # Redefine o tempo de início do histórico
        TIMESTAMP_INICIO_HIST=$(date +"%s")
    fi

    sleep $INTERVALO
done