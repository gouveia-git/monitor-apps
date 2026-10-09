# Monitor de aplicações

Este projeto cria um contêiner que monitora URLs e envia mensagens para um canal do Discord sobre erros ou lentidão de acesso.

O projeto foi testado no `Docker v4.91.0`. Na inicialização do container, o script `entrypoint.sh` é executado, o qual utiliza o utilitário `curl` para realizar o monitoramento das URLs definidas no arquivo `sites.conf`.

No arquivo `compose.yaml` estão as variáveis utilizadas na configuração do script, como intervalo de monitoramento e número máximo de falhas permitidas (antes de enviar uma mensagem).

## Gerar a imagem

Gerar imagem
```
docker build --no-cache -t monitor-apps:0.0.1 .
```

## Iniciar container com docker compose

Gerar e executar imagem
```
docker compose up --build
```

Apenas executar imagem
```
docker compose up
```

## Logs

Os arquivos de logs serão criados na pasta `log`, no mesmo diretório do `dockerfile`.

## Mensagens

Para que o script envie mensagem para um canal do Discord, é necessário criar um arquivo chamado `secrets.env` e colocá-lo na mesma pasta do `compose.yaml`. Após isso, adicione a variável `WEBHOOK` no arquivo, preenchendo `id_webhook` e `token`:

```conf
WEBHOOK=https://discordapp.com/api/webhooks/<id_webhook>/<token>
```