# pymongo-api

## Итоговая структура приложения

![FinalScheme.svg](diagrams%2FFinalScheme.svg)

## Как запустить

1) Перейдем в основную папку 
```shell
cd sharding-repl-cache
```
2) Запустим docker-compose
```shell
docker compose up -d
```
или воспользуйтесь файлом

[1_start-docker-compose.sh](sharding-repl-cache%2Fscripts%2F1_start-docker-compose.sh)

или запустить из intellij IDEA

![startDockerCompose.png](images%2FstartDockerCompose.png)

P.S. Для проверки контейнеров
воспользоваться командой
```shell
docker compose ps
```
или зайти в docker desktop

![dockerDesktop.png](images%2FdockerDesktop.png)

3) Запустим настройку mongo кластера
 
[2_sharding-repl-cache-init.sh](sharding-repl-cache%2Fscripts%2F2_sharding-repl-cache-init.sh)

Проверить корректность выполнения настройки шардирования и репликации по url

http://localhost:8080/

[Mongo.json](responce%2FMongo.json)

4) Запустим настройку redis кластера, если это необходимо

[3_crate-redis-cluster-configuration.sh](sharding-repl-cache%2Fscripts%2F3_crate-redis-cluster-configuration.sh)

## Как проверить

### Если вы запускаете проект на локальной машине

Откройте в браузере http://localhost:8080

### Если вы запускаете проект на предоставленной виртуальной машине

Узнать белый ip виртуальной машины

```shell
curl --silent http://ifconfig.me
```

Откройте в браузере http://<ip виртуальной машины>:8080

## Доступные эндпоинты

Список доступных эндпоинтов, swagger http://<ip виртуальной машины>:8080/docs