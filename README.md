# Домашнее задание к занятию "3.4. Операционные системы, лекция 2"
## 1. На лекции мы познакомились с node_exporter. В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой unit-файл для node_exporter:
* поместите его в автозагрузку,
* предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на systemctl cat cron),
* удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

### Решение:
1. Скачен архив `wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz`
2. Распакован в `/opt/node_exporter`
3. Создан файл конфигурации сервиса `touch /etc/systemd/system/node_exporter.service` со следующим содержимым:
```
[Unit]
Description=Node Exporter

[Service]
ExecStart=/opt/node_exporter/node_exporter
EnvironmentFile=/etc/default/node_exporter

[Install]
WantedBy=multi-user.target
```
4. Для добавления переменных из файла записана опция `EnvironmentFile=/etc/default/node_exporter` а так же создан данный файл `touch /etc/default/node_exporter`
5. Командой `systemctl enable node_exporter` сервис добавлен в автозагрузку
6. Командами `systemctl start node_exporter` `systemctl stop node_exporter` `systemctl status node_exporter` проверена корректность старта и завершения сервиса
7. После перезагрузки командой `systemctl status node_exporter` убедились что сервис запустился автоматически:
```shell
root@vagrant:/home/vagrant# systemctl status node_exporter
● node_exporter.service - Node Exporter
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-12-06 13:10:00 UTC; 4min 55s ago
   Main PID: 615 (node_exporter)
      Tasks: 4 (limit: 1071)
     Memory: 13.3M
     CGroup: /system.slice/node_exporter.service
             └─615 /opt/node_exporter/node_exporter

Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=thermal_zone
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=time
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=timex
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=udp_queues
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=uname
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=vmstat
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=xfs
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:115 level=info collector=zfs
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.567Z caller=node_exporter.go:199 level=info msg="Listening on" address=:9100
Dec 06 13:10:00 vagrant node_exporter[615]: ts=2021-12-06T13:10:00.570Z caller=tls_config.go:195 level=info msg="TLS is disabled." http2=false
```
## 2. Ознакомьтесь с опциями node_exporter и выводом /metrics по-умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
### Решение:
Для просмотра метрик можно использовать команду `curl localhost:9100/metrics`
### Ответ:
Для CPU:
```
    node_cpu_seconds_total{cpu="0",mode="idle"} 
    node_cpu_seconds_total{cpu="0",mode="system"} 
    node_cpu_seconds_total{cpu="0",mode="user"}
    node_cpu_seconds_total{cpu="1",mode="idle"} 
    node_cpu_seconds_total{cpu="1",mode="system"} 
    node_cpu_seconds_total{cpu="1",mode="user"}
    process_cpu_seconds_total
```
Для памяти:
```
    node_memory_MemAvailable_bytes 
    node_memory_MemFree_bytes
```
Для диска:
```
    node_disk_io_time_seconds_total{device="sda"} 
    node_disk_read_time_seconds_total{device="sda"} 
    node_disk_write_time_seconds_total{device="sda"}
```
Для сети:
```
    node_network_receive_errs_total{device="eth0"} 
    node_network_receive_bytes_total{device="eth0"} 
    node_network_transmit_bytes_total{device="eth0"}
    node_network_transmit_errs_total{device="eth0"}
```
## 3. Установите в свою виртуальную машину `Netdata`. Воспользуйтесь готовыми пакетами для установки (`sudo apt install -y netdata`). После успешной установки:
* в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с `localhost` на `bind to = 0.0.0.0`,
* добавьте в Vagrantfile проброс порта `Netdata` на свой локальный компьютер и сделайте `vagrant reload`:
`config.vm.network "forwarded_port", guest: 19999, host: 19999`
### Решение:
![img.png](img/netdata.png)
## 4. Можно ли по выводу `dmesg` понять, осознает ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?
### Решение:
```
vagrant@vagrant:~$ dmesg | grep virt
[    0.004412] CPU MTRRs all blank - virtualized system.
[    0.126980] Booting paravirtualized kernel on KVM
[    2.935513] systemd[1]: Detected virtualization oracle.
```
### Ответ:
Да, операционная система понимает что запущена в виртуальной среде
## 5. Как настроен sysctl `fs.nr_open` на системе по-умолчанию? Узнайте, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?
### Решение:
```
vagrant@vagrant:~$ sysctl -n fs.nr_open
1048576
vagrant@vagrant:~$ ulimit -n
1024
```
### Ответ:
Данный параметр отвечает за максимальное количество открытых файлов, лимит открытых файлов на пользователя не позволит достичь данного числа одним пользователем.
## 6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в данном задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т.д.
### Решение:
```
root@vagrant:/home/vagrant# unshare -f --pid --mount-proc sleep 10m
^Z
[1]+  Stopped                 unshare -f --pid --mount-proc sleep 10m
root@vagrant:/home/vagrant# bg 1
[1]+ unshare -f --pid --mount-proc sleep 10m &
root@vagrant:/home/vagrant# ps aux | grep slee
root        1498  0.0  0.0   8080   532 pts/0    S    14:23   0:00 unshare -f --pid --mount-proc sleep 10m
root        1499  0.0  0.0   8076   588 pts/0    S    14:23   0:00 sleep 10m
root        1522  0.0  0.0   8900   740 pts/0    S+   14:23   0:00 grep --color=auto slee
root@vagrant:/home/vagrant# nsenter --target 1499 --pid --mount
root@vagrant:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   8076   588 pts/0    S    14:23   0:00 sleep 10m
root           2  0.0  0.3   9836  3928 pts/0    S    14:24   0:00 -bash
root          11  0.0  0.3  11492  3384 pts/0    R+   14:24   0:00 ps aux
```
## 7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (это важно, поведение в других ОС не проверялось). Некоторое время все будет "плохо", после чего (минуты) – ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации. Как настроен этот механизм по-умолчанию, и как изменить число процессов, которое можно создать в сессии?
### Ответ:
`:(){ :|:& };:` - создает функцию `:` которая уходит в фон и создает саму себя снова, получается бесконечная рекурсия с порождением все новых и новых процессов

Стабилизации помог механизм `[ 1872.274270] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope`

По умолчанию число процессов ограничено 3571 (`ulimit -u`) изменить их количество можно командой `ulimit -u <pid-count>`