# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

### Ваш скрипт:
```json
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import json
import yaml

from time import sleep

urls = {"drive.google.com": socket.gethostbyname("drive.google.com"),
        'mail.google.com': socket.gethostbyname("mail.google.com"), 'google.com': socket.gethostbyname("google.com")}

i = 0
while i < 50:  # для бесконечного цикла заменить i < 50 на 1 == 1...
    i += 1  # ...и закомментировать эту строчку
    for host in urls:
        sleep(1)
        if urls[host] != socket.gethostbyname(host):
            print("[ERROR] " + host + " IP mismatch: " + urls[host] + " " + socket.gethostbyname(host))
        urls[host] = socket.gethostbyname(host)
        print(host + " - " + urls[host])
    with open("hosts.json", "w") as hosts:
        hosts.write(json.dumps(urls, indent=2))
    with open("hosts.yml", "w") as hosts:
        hosts.write(yaml.dump(urls, indent=2))

```

### Вывод скрипта при запуске при тестировании:
```
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.83
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
[ERROR] mail.google.com IP mismatch: 108.177.14.83 108.177.14.18
mail.google.com - 108.177.14.18
google.com - 173.194.222.139
drive.google.com - 142.251.1.194
mail.google.com - 108.177.14.18
google.com - 173.194.222.139

Process finished with exit code 0

```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
  "drive.google.com": "142.251.1.194",
  "mail.google.com": "108.177.14.18",
  "google.com": "173.194.222.139"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 142.251.1.194
google.com: 173.194.222.139
mail.google.com: 108.177.14.18
```
