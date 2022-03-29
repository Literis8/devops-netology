# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера".

## Задача 1
Сценарий выполения задачи:
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
vagrant@vagrant:/devops-netology/ex.5.3$ docker build -t literis8/nginx-netology .
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

vagrant@vagrant:/devops-netology/ex.5.3$ docker run --name literis-nginx -d -p 8080:80 literis8/nginx-netology
562bdac3745b32c60fccb244c029d9ae4f186006e4c4413959efe1016ba22980

vagrant@vagrant:/devops-netology/ex.5.3$ curl http://localhost:8080/
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>

vagrant@vagrant:/devops-netology/ex.5.3$ docker push literis8/nginx-netology
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
