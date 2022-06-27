# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | значение не будет присвоено, разные типы данных  |
| Как получить для переменной `c` значение 12?  | c = str(a) + b  |
| Как получить для переменной `c` значение 3?  | c = a + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:

```python
#!/usr/bin/env python3

import os

path = "/\\"  # вывел путь в отдельную переменную и изменен путь до локального репозитория
bash_command = ["cd " + path, "git status"]  # путь заменен на переменную
result_os = os.popen(' && '.join(bash_command)).read()
# is_change = False данная переменная не используется
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(path + prepare_result.replace("/", "\\"))  # Добавлен полный путь для файла и заменен "/" на "\"
        # break цикл прерывается после первого найденного изменения

```

### Вывод скрипта при запуске при тестировании:
```
C:\Users\sai_ev\AppData\Local\Programs\Python\Python39\python.exe D:/netology/devops-netology/ex4.2.2.py
D:\netology\devops-netology\README.md
D:\netology\devops-netology\ex4.2.2.py
D:\netology\devops-netology\homeworks\ex4.1.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

#  Вносим путь
path = os.getcwd()+"\\"
if len(sys.argv) >= 2:
    path = sys.argv[1]

#  Проверка наличия .git/
if not os.path.exists(path + "/.git"):
    print("ERROR: " + path + " is not GIT directory")
    exit(1)

bash_command = ["cd " + path, "git status"]  # путь заменен на переменную
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(path + prepare_result.replace("/", "\\"))
```

### Вывод скрипта при запуске при тестировании:
```
PS D:\netology\devops-netology> python3 .\ex4.2.2.py                      
D:\netology\devops-netology\README.md
D:\netology\devops-netology\ex4.2.2.py
D:\netology\devops-netology\homeworks\ex4.1.md
PS D:\netology\devops-netology> python3 .\ex4.2.2.py D:\netology\git-test\
D:\netology\git-test\README.md
D:\netology\git-test\conspect.md
PS D:\netology\devops-netology> python3 .\ex4.2.2.py D:\                  
ERROR: D:\ is not GIT directory
PS D:\netology\devops-netology> 

```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket

from time import sleep

urls = {"drive.google.com": socket.gethostbyname("drive.google.com"),
        'mail.google.com': socket.gethostbyname("mail.google.com"), 'google.com': socket.gethostbyname("google.com")}
i = 0
while i < 50:  # для бесконечного цикла заменить i < 50 на 1 == 1...
    i += 1  # ...и закомментировать эту строчку
    for host in urls:
        sleep(5)
        if urls[host] != socket.gethostbyname(host):
            print("[ERROR] " + host + " IP mismatch: " + urls[host] + " " + socket.gethostbyname(host))
        urls[host] = socket.gethostbyname(host)
        print(host + " - " + urls[host])

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 142.251.1.194
mail.google.com - 64.233.165.19
google.com - 74.125.131.100
drive.google.com - 142.251.1.194
[ERROR] mail.google.com IP mismatch: 64.233.165.19 64.233.165.17
mail.google.com - 64.233.165.17
google.com - 74.125.131.100
drive.google.com - 142.251.1.194
mail.google.com - 64.233.165.17
[ERROR] google.com IP mismatch: 74.125.131.100 74.125.131.101
google.com - 74.125.131.101
drive.google.com - 142.251.1.194
mail.google.com - 64.233.165.17
[ERROR] google.com IP mismatch: 74.125.131.101 74.125.131.102
google.com - 74.125.131.102
drive.google.com - 142.251.1.194
mail.google.com - 64.233.165.17
google.com - 74.125.131.102

```
