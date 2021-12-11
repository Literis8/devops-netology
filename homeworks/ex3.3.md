# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"
## 1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной программой, это shell builtin, поэтому запустить `strace` непосредственно на cd не получится. Тем не менее вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к `cd`. Обратите внимание, что `strace` выдаёт результат своей работы в поток `stderr`, а не в `stdout`.
### Ответ:
`chdir("/tmp")                           = 0`
### Решение:
`strace -o strace_cd.txt /bin/bash -c 'cd /tmp'`  
`grep tmp strace_cd.txt`
## 2.Попробуйте использовать команду file на объекты разных типов на файловой системе. Например:
```
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
```
Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
### Ответ:
`/usr/lib/locale/locale-archive`  
`/home/vagrant/.magic.mgc`  
`/home/vagrant/.magic`  
`/etc/magic`  
`/usr/share/misc/magic.mgc`  
### Решение:
`strace file /dev/tty` с дальнейшим поиском во выводу
## 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
### Решение:
```
vagrant@vagrant:~$ bash -c 'vim test.txt '

[1]+  Stopped                 bash -c 'vim test.txt '
vagrant@vagrant:~$ lsof | grep test
vim       1546                       vagrant    4u      REG              253,0     4096     131100 /home/vagrant/.test.txt.swp
vagrant@vagrant:~$ rm .test.txt.swp
vagrant@vagrant:~$ lsof | grep test
vim       1546                       vagrant    4u      REG              253,0     4096     131100 /home/vagrant/.test.txt.swp (deleted)
vagrant@vagrant:~$ echo '' >/proc/1546/fd/4
vagrant@vagrant:~$ lsof | grep test
vim       1546                       vagrant    4u      REG              253,0        1     131100 /home/vagrant/.test.txt.swp (deleted)
vagrant@vagrant:~$ lsof | grep test
vim       1546                       vagrant    4u      REG              253,0        1     131100 /home/vagrant/.test.txt.swp (deleted)
```
## 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
### Ответ:
Зомби не занимают памяти (как процессы-сироты), но блокируют записи в таблице процессов, 
размер которой ограничен для каждого пользователя и системы в целом.
## 5. В iovisor BCC есть утилита opensnoop:
```
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```

На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? 
Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04.
### Ответ:
```
vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
788    vminfo              6   0 /var/run/utmp
584    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
584    dbus-daemon        18   0 /usr/share/dbus-1/system-services
584    dbus-daemon        -1   2 /lib/dbus-1/system-services
584    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
1      systemd            12   0 /proc/400/cgroup
```
## 6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.
### Ответ:
`uname({sysname="Linux", nodename="vagrant", ...}) = 0`  
`man 2 uname`  
>Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
## 7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```
Есть ли смысл использовать в bash `&&`, если применить `set -e`?

### Ответ:
`&&` - следующая команда выполнится только при успешном выполнении предыдущей

`;` - выполнит команды вне зависимости от результатов пердыдущей

`set -e` - завершает работу последовательности команд при ненулевом результате выполнения

Поскольку `&&` не продолжит выполнение команд при ненулевом результате, совместно с `set -e` смысла использовать нет
## 8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
### Ответ:
* `-e` - прервет выполнение сценария при ошибке в какой-либо команде
* `-u` - прервет выполнение при подстановке не существующей переменной и выдаст сообщение об ошибке
* `-x` - будет выдавать результат команды после каждого выполнения в сценарии
* `-o pipefail` - выдаст результат выполнения последней команды в случае если он будет не нулевой

Данную команду хорошо использовать в сценариях так как она поможет в отладке, а так же даст много информации об ошибках
в случае если они произойдут во время выполнения.
### 9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
### Ответ:
```
vagrant@vagrant:~$ ps ax -o stat | grep -c D ;  ps ax -o stat | grep -c I ; ps ax -o stat | grep -c R ; ps ax -o stat | grep -c S ; ps ax -o stat | grep -c
T ; ps ax -o stat | grep -c t ; ps ax -o stat | grep -c W ;  ps ax -o stat | grep -c X ; ps ax -o stat | grep -c Z
0
48
1
50
2
0
0
0
0
```
По результату видно что больше всего процессов с кодами `I` (треды ожидания ядра) `S` (Спящие прерываемые процессы)

Дополнительные обозначения:
* `<` - Высокоприоритетные процессы
* `N` - Низкоприоритетные процессы
* `L` - заблокированные в памяти процессы
* `s` - лидер сеанса (это процесс, в котором идентификатор сеанса равен идентификатору процесса)
* `l` - процесс имеющий треды
* `+` - процесс на переднем плане
