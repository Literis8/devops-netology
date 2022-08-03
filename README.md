# Домашнее задание к занятию "08.02 Работа с Playbook"

## Подготовка к выполнению
1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook.
4. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 

### Решение:
1. Выполнено
2. Выполнено, размещено в директории ./playbook
3. В качестве хостов будут использованы докер контейнеры поднятые через docker compose. 
(Файл ./docker/docker-compose.yml)
```yaml
version: '3.8'

services:
  elasticsearch:
    image: debian:latest
    container_name: elastic
    restart: always
    command: "sleep 6000000"

  kibana:
    image: debian:latest
    container_name: kibana
    restart: always
    command: "sleep 6000000"
```
4. Скачиваем дистрибутив и указываем версию Java в переменных ./playbook/group_vars/all/vars.yml
```yamlex
---
java_jdk_version: 11.0.16
java_oracle_jdk_package: ./files/jdk-{{ java_jdk_version }}_linux-x64_bin.tar.gz
```

## Основная часть
1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает kibana.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.

### Решение:
1. Подготавливаем prod.yml:
```yamlex
---
elasticsearch:
  hosts:
    elastic:
      ansible_connection: docker
kibana:
  hosts:
    kibana:
      ansible_connection: docker
```
2. (3,4) Добавляем групповые переменные в ./playbook/group_vars/kibana/vars.yml:
```yamlex
kibana_version: 8.3.3
kibana_home: "/opt/kibana/{{ kibana_version }}"
```

Добавляем template ./playbook/templates/kib.sh.j2
```shell
# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
#!/usr/bin/env bash

export KIBANA_HOME={{ kibana_home }}
export PATH=$PATH:$KIBANA_HOME/bin
```

Дописываем playbook:
```yamlex
- name: Install Kibana
  hosts: kibana
  tasks:
    - name: Download Kibana
      get_url:
        url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        mode: 0755
        timeout: 60
    - name: Create directory for Kibana
      file:
        state: directory
        path: "{{ kibana_home }}"
    - name: Extract Kibana in selected directory
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
    - name: Generate configuration whith parameters
      template:
        src: templates/kib.sh.j2
        dest: /etc/profile.d/kib.sh
```

5. Запускаем `ansible-lint site.yml` в выводе чисто
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-lint site.yml
vagrant@vagrant:/devops-netology/playbook$ 
```

6. Запускаем `ansible-playbook -i inventory/prod.yml site.yml --check` и исправляем ошибки:
    * по скольку мы используем докер контейнеры от рута, убираем из playbook `become: true`
    * добавим игнорирование ошибки в чекмоде `ignore_errors: "{{ ansible_check_mode }}"` в задачу "Extract java in the 
installation directory" так как иначе чек остановится на ней. 