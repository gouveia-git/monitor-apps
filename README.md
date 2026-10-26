# Monitor de aplicações

Este projeto cria um contêiner que monitora URLs e envia mensagens para um canal do Discord sobre erros ou lentidão de acesso.

O projeto utiliza o `Python 3.13` e os contêineres foram testados no `Docker v4.91.0`.

## Gerar a imagem

Gerar imagem
```
docker build --no-cache -t monitor-apps:1.0.0 .
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

## Mensagens

Para que o script envie mensagem para um canal do Discord, é necessário criar um arquivo chamado `secrets.json` e colocá-lo na mesma pasta do `compose.yaml`.:

```json
{
    "WEBHOOK": "https://discordapp.com/api/webhooks/<id_webhook>/<token>"
}
```