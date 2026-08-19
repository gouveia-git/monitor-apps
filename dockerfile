# Define a imagem base
FROM debian:12.15-slim

# CERTIFICADOS ----------------------------------

# Copia o certificado do Tribunal para a imagem
COPY trt16.crt /usr/local/share/ca-certificates/trt16.crt

# Atualiza os pacotes
RUN apt-get update

# Instala os pacotes
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    tzdata \
    locales
    
# Exclui o certificado do Tribunal da imagem
RUN rm /usr/local/share/ca-certificates/trt16.crt
    
# Configuração de local -------------------------

RUN sed -i 's/^# *pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=pt_BR.UTF-8

ENV LANG=pt_BR.UTF-8
ENV TZ=America/Fortaleza

# -----------------------------------------------
        
RUN rm -rf /var/lib/apt/lists/*

# Define a pasta padrão
WORKDIR /root

# Cria a pasta de log
RUN mkdir log && chmod 777 log

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]