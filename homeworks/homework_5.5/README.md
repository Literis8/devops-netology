# Домашнее задание к занятию "5.5. Оркестрация кластером Docker контейнеров на примере Docker Swarm".
## Задача 1
Дайте письменые ответы на следующие вопросы:

* В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
* Какой алгоритм выбора лидера используется в Docker Swarm кластере?
* Что такое Overlay Network?

### Ответ:
* В режиме global сервисы запускаются на всех нодах кластера, в режиме replication сервисы запускаются на указанном 
количестве нод.
* При выборе лидера используется алгоритм RAFT.
* В общем понимании Overlay Network это логическая сеть создаваемая поверх имеющейся, яркий пример это VPN тунели.
в Docker Swarm overlay сеть используется для обмена трафиком между менеджерами и между воркерами и менеджерами.
Он использует технологию vxlan которая инкапсулирует пакеты l2 в l4 в следствии чего все ноды ощущают себя находящимися
в одном широковещательном сегменте сети. Так же в Overlay Network реализуется шифрование трафика обмениваемого между
нодами.

## Задача 2
Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```shell
docker node ls
```
### Решение:
```shell
root@vagrant:/devops-netology/src/terraform# ssh centos@51.250.77.0
[centos@node01 ~]$ docker node ls
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/nodes": dial un
ix /var/run/docker.sock: connect: permission denied
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
ojspn8vchq0lfz95clmrdo9av *   node01.netology.yc   Ready     Active         Leader           20.10.14
vdchg4q11ghx87i3l1iy7nmp9     node02.netology.yc   Ready     Active         Reachable        20.10.14
chkc43jcho1f6wjym27u8palc     node03.netology.yc   Ready     Active         Reachable        20.10.14
2hzmiyufht4g28xeke94xq4jl     node04.netology.yc   Ready     Active                          20.10.14
oo4ash1qcvxr79mvh569onr0w     node05.netology.yc   Ready     Active                          20.10.14
t2h9dnzp555k9ivbf1blekuy0     node06.netology.yc   Ready     Active                          20.10.14
[centos@node01 ~]$ 

```
![docker_node_ls](homeworks/homework_5.5/img/docker_node_ls.PNG)

## Задача 3
Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```shell
docker service ls
```
### Решение:
```shell
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
tnukeihcjw4n   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
mdaxg72jcne2   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9
094->9093-9094/tcp
44eu5mq6rqg1   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
jb1lozzdnxh9   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
zp4z9gvcaxsd   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
utvq5i332ml0   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
ue9d7tyx9urk   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
e7se1s2tpzmk   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
[centos@node01 ~]$ 
```
![docker_service_ls](homeworks/homework_5.5/img/docker_service_ls.PNG)

На всякий случай прилагаю еще скрин что графана работает:
![grafana](homeworks/homework_5.5/img/grafana.PNG)