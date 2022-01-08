# Домашнее задание по лекции "3.8 Компьютерные сети (лекция 3)"
## 1. Подключитесь к публичному маршрутизатору в интернет. Найдите маршрут к вашему публичному IP
```shell
telnet route-views.routeviews.org
Username: rviews
show ip route x.x.x.x/32
show bgp x.x.x.x/32
```
### Решение:
```
route-views>sh ip route 31.135.47.87
Routing entry for 31.135.40.0/21
  Known via "bgp 6447", distance 20, metric 0
  Tag 6939, type external
  Last update from 64.71.137.241 3w0d ago
  Routing Descriptor Blocks:
  * 64.71.137.241, from 64.71.137.241, 3w0d ago
      Route metric is 0, traffic share count is 1
      AS Hops 3
      Route tag 6939
      MPLS label: none
route-views>show bgp 31.135.47.87
BGP routing table entry for 31.135.40.0/21, version 1419588615
Paths: (23 available, best #16, table default)
  Not advertised to any peer
  Refresh Epoch 1
  57866 9002 9049 48858 48327 48327 48327
    37.139.139.17 from 37.139.139.17 (37.139.139.17)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 9002:0 9002:64667
      path 7FE15529E7A8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  53767 174 31133 48327 48327 48327 48327
    162.251.163.2 from 162.251.163.2 (162.251.162.3)
      Origin IGP, localpref 100, valid, external
      Community: 174:21101 174:22005 53767:5000
      path 7FE128F6BFA8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3333 48858 48858 48327 48327 48327
    193.0.0.56 from 193.0.0.56 (193.0.0.56)
      Origin IGP, localpref 100, valid, external
      Community: 48858:50042
      Extended Community: RT:48858:50
      path 7FE13701EC90 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1351 6939 13094 48327
    132.198.255.253 from 132.198.255.253 (132.198.255.253)
      Origin IGP, localpref 100, valid, external
      path 7FE0AD44AC60 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  20912 3257 28917 28917 28917 28917 28917 28917 28917 48858 48858 48858 48327 48327 48327
    212.66.96.126 from 212.66.96.126 (212.66.96.126)
      Origin IGP, localpref 100, valid, external
      Community: 3257:4000 3257:8133 3257:50001 3257:50110 3257:54901 20912:65004
      path 7FE0563CE948 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 3
  3303 6939 13094 48327
    217.192.89.50 from 217.192.89.50 (138.187.128.158)
      Origin IGP, localpref 100, valid, external
      Community: 3303:1006 3303:1021 3303:1030 3303:3067 6939:7040 6939:8752 6939:9002
      path 7FE043ADC9F8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  1221 4637 31133 48327 48327 48327 48327
    203.62.252.83 from 203.62.252.83 (203.62.252.83)
      Origin IGP, localpref 100, valid, external
      path 7FE10F00A648 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  2497 1299 48858 48327 48327 48327
    202.232.0.2 from 202.232.0.2 (58.138.96.254)
      Origin IGP, localpref 100, valid, external
      path 7FE111406930 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3549 3356 9002 9002 9002 9002 9002 9049 48858 48327 48327 48327
    208.51.134.254 from 208.51.134.254 (67.16.168.191)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 3356:2 3356:22 3356:100 3356:123 3356:503 3356:903 3356:2067 3549:2581 3549:30840
      path 7FE15051FA10 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3356 9002 9002 9002 9002 9002 9049 48858 48327 48327 48327
    4.68.4.46 from 4.68.4.46 (4.69.184.201)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 3356:2 3356:22 3356:100 3356:123 3356:503 3356:903 3356:2067
      path 7FE055CAC0B8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  701 1299 48858 48327 48327 48327
    137.39.3.55 from 137.39.3.55 (137.39.3.55)
      Origin IGP, localpref 100, valid, external
      path 7FE0C57363B8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  101 11164 2603 31133 48327 48327 48327 48327
    209.124.176.223 from 209.124.176.223 (209.124.176.223)
      Origin IGP, localpref 100, valid, external
      Community: 0:714 0:2854 0:3216 0:5580 0:6461 0:6939 0:8075 0:8359 0:9002 0:12389 0:12876 0:12989 0:13335 0:15169 0:16265 0:16276 0:16302 0:16509 0:16
625 0:20485 0:20764 0:20940 0:21859 0:22697 0:24940 0:32338 0:32590 0:33438 0:33891 0:39832 0:42668 0:46489 0:47541 0:47542 0:49544 0:49981 0:56550 0:56630
 0:57976 0:60280 101:20100 101:22100 2603:302 2603:666 2603:65100 11164:1170 11164:7880
      Extended Community: RT:101:22100
      path 7FE0AB501AF8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7018 1299 48858 48327 48327 48327
    12.0.1.63 from 12.0.1.63 (12.0.1.63)
      Origin IGP, localpref 100, valid, external
      Community: 7018:5000 7018:37232
      path 7FE1003BF670 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  7660 2516 3257 28917 28917 28917 28917 28917 28917 28917 48858 48858 48858 48327 48327 48327
    203.181.248.168 from 203.181.248.168 (203.181.248.168)
      Origin IGP, localpref 100, valid, external
      Community: 2516:1030 7660:9003
      path 7FE14DE70400 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  49788 12552 48858 48327 48327 48327
    91.218.184.60 from 91.218.184.60 (91.218.184.60)
      Origin IGP, localpref 100, valid, external
      Community: 12552:12000 12552:12600 12552:12601 12552:22000
      Extended Community: 0x43:100:1
      path 7FE153B27A58 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  6939 13094 48327
    64.71.137.241 from 64.71.137.241 (216.218.252.164)
      Origin IGP, localpref 100, valid, external, best
      path 7FE0DBCF1A68 RPKI State not found
      rx pathid: 0, tx pathid: 0x0
  Refresh Epoch 1
  3561 3910 3356 9002 9002 9002 9002 9002 9049 48858 48327 48327 48327
    206.24.210.80 from 206.24.210.80 (206.24.210.80)
      Origin IGP, localpref 100, valid, external
      path 7FE0215A92F8 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 2
  8283 1299 48858 48327 48327 48327
    94.142.247.3 from 94.142.247.3 (94.142.247.3)
      Origin IGP, metric 0, localpref 100, valid, external
      Community: 1299:30000 8283:1 8283:101
      unknown transitive attribute: flag 0xE0 type 0x20 length 0x18
        value 0000 205B 0000 0000 0000 0001 0000 205B
              0000 0005 0000 0001
      path 7FE0C0772648 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  20130 6939 13094 48327
    140.192.8.16 from 140.192.8.16 (140.192.8.16)
      Origin IGP, localpref 100, valid, external
      path 7FE115E65D38 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  852 31133 48327 48327 48327 48327
    154.11.12.212 from 154.11.12.212 (96.1.209.43)
      Origin IGP, metric 0, localpref 100, valid, external
      path 7FE0FD7E9120 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  4901 6079 31133 48327 48327 48327 48327
    162.250.137.254 from 162.250.137.254 (162.250.137.254)
      Origin IGP, localpref 100, valid, external
      Community: 65000:10100 65000:10300 65000:10400
      path 7FE038421F80 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  3257 28917 28917 28917 28917 28917 28917 28917 48858 48858 48858 48327 48327 48327
    89.149.178.10 from 89.149.178.10 (213.200.83.26)
      Origin IGP, metric 10, localpref 100, valid, external
      Community: 3257:4000 3257:8133 3257:50001 3257:50110 3257:54901
      path 7FE0C3D9EF70 RPKI State not found
      rx pathid: 0, tx pathid: 0
  Refresh Epoch 1
  19214 174 31133 48327 48327 48327 48327
    208.74.64.40 from 208.74.64.40 (208.74.64.40)
      Origin IGP, localpref 100, valid, external
      Community: 174:21101 174:22005
      path 7FE0E48BEE30 RPKI State not found
      rx pathid: 0, tx pathid: 0

```
## 2. Создайте dummy0 интерфейс в Ubuntu. Добавьте несколько статических маршрутов. Проверьте таблицу маршрутизации.
### Решение:
```shell
vagrant@vagrant:~$ sudo vim /etc/netplan/02-dummy.yaml

network:
  version: 2
  renderer: networkd
  bridges:
    dummy0:
      dhcp4: no
      dhcp6: no
      accept-ra: no
      interfaces: [ ]
      addresses:
        - 169.254.1.1/32

vagrant@vagrant:~$ sudo netplan apply
vagrant@vagrant:~$ ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:73:60:cf brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 86368sec preferred_lft 86368sec
    inet6 fe80::a00:27ff:fe73:60cf/64 scope link
       valid_lft forever preferred_lft forever
3: dummy0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether f2:d7:3c:14:ba:28 brd ff:ff:ff:ff:ff:ff
    inet 169.254.1.1/32 scope global dummy0
       valid_lft forever preferred_lft forever
    inet6 fe80::f0d7:3cff:fe14:ba28/64 scope link
       valid_lft forever preferred_lft forever
```
## 3. Проверьте открытые TCP порты в Ubuntu, какие протоколы и приложения используют эти порты? Приведите несколько примеров.
### Решение:
```
State    Recv-Q   Send-Q     Local Address:Port     Peer Address:Port   Process
LISTEN   0        4096             0.0.0.0:111           0.0.0.0:*       users:(("rpcbind",pid=608,fd=4),("systemd",pid=1,fd=83))
LISTEN   0        511              0.0.0.0:80            0.0.0.0:*       users:(("nginx",pid=1857,fd=6),("nginx",pid=1856,fd=6),("nginx",pid=1855,fd=6))
LISTEN   0        4096       127.0.0.53%lo:53            0.0.0.0:*       users:(("systemd-resolve",pid=609,fd=13))
LISTEN   0        128              0.0.0.0:22            0.0.0.0:*       users:(("sshd",pid=865,fd=3))
ESTAB    0        0              10.0.2.15:22           10.0.2.2:25699   users:(("sshd",pid=1178,fd=4),("sshd",pid=1141,fd=4))
LISTEN   0        4096                [::]:111              [::]:*       users:(("rpcbind",pid=608,fd=6),("systemd",pid=1,fd=85))
LISTEN   0        511                 [::]:80               [::]:*       users:(("nginx",pid=1857,fd=7),("nginx",pid=1856,fd=7),("nginx",pid=1855,fd=7))
LISTEN   0        128                 [::]:22               [::]:*       users:(("sshd",pid=865,fd=4))

```
Примеры: 80 порт открыт Nginx, 22 порт SSH, 111 порт демоном rpcbind, внутренняя служба разрешения доменных имен на 53 
порту loopback интерфейса
## 4. Проверьте используемые UDP сокеты в Ubuntu, какие протоколы и приложения используют эти порты?
### Решение:
```
vagrant@vagrant:~$ sudo ss -paun
State       Recv-Q      Send-Q            Local Address:Port           Peer Address:Port     Process
UNCONN      0           0                 127.0.0.53%lo:53                  0.0.0.0:*         users:(("systemd-resolve",pid=609,fd=12))
UNCONN      0           0                10.0.2.15%eth0:68                  0.0.0.0:*         users:(("systemd-network",pid=1405,fd=20))
UNCONN      0           0                       0.0.0.0:111                 0.0.0.0:*         users:(("rpcbind",pid=608,fd=5),("systemd",pid=1,fd=84))
UNCONN      0           0                          [::]:111                    [::]:*         users:(("rpcbind",pid=608,fd=7),("systemd",pid=1,fd=86))

```
Аналогичная внутренняя служба доменных имен на loopback интерфейсе 53 UDP порт, Bootstrap Protocol Client - 68 порт, rpcbind на 111 udp порту

## 5. Используя diagrams.net, создайте L3 диаграмму вашей домашней сети или любой другой сети, с которой вы работали.
### Решение:
К сожалению у меня не сохранилась L3 схема с прошлой работы, а на текущей она еще не составлена, так что я изобразил
вариант типичной схемы с одним удаленным офисом соединенным с центральным по средствам VPN и DMZ сетью в центральном 
офисе.

![](scheme/l3.png)

Но дополнительно могу приложить совмещенную L1-2 схему которую я составлял на прошлой работе:

![](scheme/l1-2.png)
