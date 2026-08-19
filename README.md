# Monitor de aplicações

Este projeto cria um contêiner que monitora URLs e envia mensagens para um canal do Discord sobre erros ou lentidão de acesso.

Na inicialização do container, o script `entrypoint.sh` é executado, o qual utiliza o utilitário `curl` para realizar o monitoramento das URLs definidas no arquivo `sites.conf`.

No arquivo `compose.yaml` estão as variáveis utilizadas na configuração do script, como intervalo de monitoramento e número máximo de falhas permitidas (antes de enviar uma mensagem).

## Iniciar container

Se a imagem já foi gerada
```
docker compose up
```

Se a imagem não foi gerada
```
docker compose up --build
```

## Logs

Os arquivos de logs serão criados na pasta `log`, no mesmo diretório do `dockerfile`.

## Mensagens

Para que o script envie mensagem para um canal do Discord, é necessário criar um arquivo chamado `secrets.env` e colocá-lo na mesma pasta do `compose.yaml`. Após isso, adicione a variável `WEBHOOK` no arquivo, preenchendo `id_webhook` e `token`:

```conf
WEBHOOK=https://discordapp.com/api/webhooks/<id_webhook>/<token>
```