# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера".

## Задача 1
Сценарий выполнения задачи:
* создайте свой репозиторий на <https://hub.docker.com>;
* выберете любой образ, который содержит веб-сервер Nginx;
* создайте свой fork образа;
* реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на 
<https://hub.docker.com/username_repo>.

### Решение:
index.html:
```html
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>

```
Dockerfile:
```dockerfile
FROM nginx:1.21.6-alpine

COPY ./index.html /usr/share/nginx/html
```
```shell
vagrant@vagrant:/devops-netology/src$ docker build -t literis8/nginx-netology .
Sending build context to Docker daemon  3.072kB
Step 1/2 : FROM nginx:1.21.6-alpine
1.21.6-alpine: Pulling from library/nginx
3aa4d0bbde19: Pull complete
91a0d98ef348: Pull complete
acdff1cb5e67: Pull complete
dfe2157c7506: Pull complete
0cddbe0663dc: Pull complete
2410dd56c3ee: Pull complete
Digest: sha256:26880313c439230a383ac390b2c352d327fb490b84eb6aa4640a81fce39f804d
Status: Downloaded newer image for nginx:1.21.6-alpine
 ---> d7c7c5df4c3a
Step 2/2 : COPY ./index.html /usr/share/nginx/html
 ---> 7902c0b259d7
Successfully built 7902c0b259d7
Successfully tagged literis8/nginx-netology:latest

vagrant@vagrant:/devops-netology/src$ docker run --name literis-nginx -d -p 8080:80 literis8/nginx-netology
562bdac3745b32c60fccb244c029d9ae4f186006e4c4413959efe1016ba22980

vagrant@vagrant:/devops-netology/src$ curl http://localhost:8080/
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>

vagrant@vagrant:/devops-netology/src$ docker push literis8/nginx-netology
Using default tag: latest
The push refers to repository [docker.io/literis8/nginx-netology]
c5f4a7318c1b: Pushed
527aa7494e14: Pushed
0e558dedd502: Pushed
e163b4581361: Pushed
8e2df9084bbf: Pushed
cd1f51e8059a: Mounted from library/nginx
ff768a1413ba: Mounted from library/nginx
latest: digest: sha256:dcaf80766263e06c43a24375918afe2dd84602bfabfea081470e6c150a32f26e size: 1775

```

Репозиторий: <https://hub.docker.com/r/literis8/nginx-netology/>

## Задача 2
Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование Docker контейнеров или 
лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор:
* Высоконагруженное монолитное java веб-приложение;
* Nodejs веб-приложение;
* Мобильное приложение c версиями для Android и iOS;
* Шина данных на базе Apache Kafka;
* Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash
и две ноды kibana;
* Мониторинг-стек на базе Prometheus и Grafana;
* MongoDB, как основное хранилище данных для java-приложения;
* Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

### Ответ:
1. **Высоконагруженное монолитное java веб-приложение** - в данном случае я бы использовал физическую машину, java 
использует свою виртуальную машину, поэтому излишняя виртуализация только снизит производительность
2. **Nodejs веб-приложение** - контейнеризация, веб приложения всегда отличный вариант для контейнеризации и разбиения
на микросервисы, упростит создание тестовых сред и ускорит выпуски релизов
3. **Мобильное приложение c версиями для Android и iOS** - докер, отлично подойдет для тестирования под различные версии
мобильных ОС
4. **Шина данных на базе Apache Kafka** - docker, позволит быстро поднимать ноды, а так же позволит реализовать хорошую
отказоустойчивость, по крайней мере если верить 
[статье на Хабре](https://dotsandbrackets.com/highly-available-kafka-cluster-docker-ru/)
5. **Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два 
logstash и две ноды kibana** - ну уже из описания видно, что данный сценарий состоит из различных микросервисов. Для
микросервисов - Docker =).
6. **Мониторинг-стек на базе Prometheus и Grafana** - Docker. Контейнер с Prometheus, контейнер с Grafana и подключенным
внешним волюмом для хранения данных мониторинга.
7. **MongoDB, как основное хранилище данных для java-приложения** - хотя мы и использовали на работе PostgreSQL в docker
контейнере с внешним волюмом, на сколько я слышал от коллег, большинство рекомендуют все-таки для СУБД использовать 
отдельную физическую или виртуальную машину с аппаратной виртуализацией. Думаю в данном случае все зависит от
загруженности СУБД.
8. **Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry** - Докер. Оптимальное решение
чтобы в рамках CI/CD в пайплайнах в контейнерах осуществлять конфигурирование, сборку, тестирования кода из репозитория.

## Задача 3
* Запустите первый контейнер из образа _**centos**_ c любым тегом в фоновом режиме, подключив папку `/data` из текущей 
рабочей директории на хостовой машине в `/data` контейнера;
* Запустите второй контейнер из образа **_debian_** в фоновом режиме, подключив папку `/data` из текущей рабочей 
директории на хостовой машине в `/data` контейнера;
* Подключитесь к первому контейнеру с помощью `docker exec` и создайте текстовый файл любого содержания в `/data`;
* Добавьте еще один файл в папку `/data` на хостовой машине;
* Подключитесь во второй контейнер и отобразите листинг и содержание файлов в `/data` контейнера.

### Решение:
```shell
vagrant@vagrant:~$ docker run -dit -v ~/data:/data --name centos centos
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
fede34b51d02478fb7cbba8bc13cf3075e35133a4b34e87c8332b1e64fe3086b

vagrant@vagrant:~$ docker run -dit -v ~/data:/data --name debian debian
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
dbba69284b27: Pull complete
Digest: sha256:87eefc7c15610cca61db5c0fd280911c6a737c0680d807432c0bd80cd0cca39b
Status: Downloaded newer image for debian:latest
2d39b82f2ce25c8943ffb5d65b70d310acef36a900d0221df852235fe34d2ca2

vagrant@vagrant:~$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED              STATUS              PORTS     NAMES
2d39b82f2ce2   debian    "bash"        14 seconds ago       Up 13 seconds                 debian
fede34b51d02   centos    "/bin/bash"   About a minute ago   Up About a minute             centos

vagrant@vagrant:~$ docker exec -ti centos bash
[root@fede34b51d02 /]# echo "this is centos file" > /data/centos_first_file.txt
[root@fede34b51d02 /]# exit

vagrant@vagrant:~$ echo "this is host file" > ~/data/host_secound_file.txt

vagrant@vagrant:~$ docker exec -ti debian bash
root@2d39b82f2ce2:/# ls -la /data
total 16
drwxrwxr-x 2 1000 1000 4096 Mar 30 09:30 .
drwxr-xr-x 1 root root 4096 Mar 30 09:26 ..
-rw-r--r-- 1 root root   20 Mar 30 09:29 centos_first_file.txt
-rw-rw-r-- 1 1000 1000   18 Mar 30 09:30 host_secound_file.txt
root@2d39b82f2ce2:/# cat /data/centos_first_file.txt                             
this is centos file
root@2d39b82f2ce2:/# cat /data/host_secound_file.txt
this is host file
```