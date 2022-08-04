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
    * при попытке доступа даже под впн к еластику получил 403 ошибку, в связи с этим переделываю плейбук для работы с
локальными дистрибутивами:
```yamlex
- name: Install Elasticsearch
  hosts: elasticsearch
  tasks:
    - name: Upload .tar.gz Elasticsearch from local storage # Меняем имя
      copy:                                                 # настраиваем локальную копию
        src: "{{ elastic_package }}"
        dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
      register: get_elastic
      until: get_elastic is succeeded
      tags: elastic
```
   * добавим игнорирование ошибки в чекмоде `ignore_errors: "{{ ansible_check_mode }}"` в задачу "Extract Elasticsearch 
in the installation directory" так как иначе чек остановится на ней. 
   * Аналогично эластику, меняем способ получения дистрибутива кибана на локальный:
```yamlex
- name: Install Kibana
  hosts: kibana
  tasks:
    - name: Download Kibana
      copy:
        src: "{{ kibana_package }}"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
```
   * добавим игнорирование ошибки в чекмоде `ignore_errors: "{{ ansible_check_mode }}"` в задачу "Extract Kibana 
in selected directory" так как иначе чек остановится на ней.
   
Конечный вывод:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check
[WARNING]: Found both group and host with same name: kibana

PLAY [Install Java] ***********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host kibana is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [kibana]
[WARNING]: Platform linux on host elastic is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [elastic]

TASK [Set facts for Java 11 vars] *********************************************************************************************************************************************************************************************************
ok: [elastic]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] *************************************************************************************************************************************************************************
changed: [kibana]
changed: [elastic]

TASK [Ensure installation dir exists] *****************************************************************************************************************************************************************************************************
changed: [elastic]
changed: [kibana]

TASK [Extract java in the installation directory] *****************************************************************************************************************************************************************************************
fatal: [elastic]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.16' must be an existing dir"}
...ignoring
fatal: [kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/jdk/11.0.16' must be an existing dir"}
...ignoring

TASK [Export environment variables] *******************************************************************************************************************************************************************************************************
changed: [elastic]
changed: [kibana]

PLAY [Install Elasticsearch] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [elastic]

TASK [Upload .tar.gz Elasticsearch from local storage] ************************************************************************************************************************************************************************************
changed: [elastic]

TASK [Create directrory for Elasticsearch] ************************************************************************************************************************************************************************************************
changed: [elastic]

TASK [Extract Elasticsearch in the installation directory] ********************************************************************************************************************************************************************************
fatal: [elastic]: FAILED! => {"changed": false, "msg": "dest '/opt/elastic/7.10.1' must be an existing dir"}
...ignoring

TASK [Set environment Elastic] ************************************************************************************************************************************************************************************************************
changed: [elastic]

PLAY [Install Kibana] *********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Download Kibana] ********************************************************************************************************************************************************************************************************************
changed: [kibana]

TASK [Create directory for Kibana] ********************************************************************************************************************************************************************************************************
changed: [kibana]

TASK [Extract Kibana in selected directory] ***********************************************************************************************************************************************************************************************
fatal: [kibana]: FAILED! => {"changed": false, "msg": "dest '/opt/kibana/8.3.3' must be an existing dir"}
...ignoring

TASK [Generate configuration whith parameters] ********************************************************************************************************************************************************************************************
changed: [kibana]

PLAY RECAP ********************************************************************************************************************************************************************************************************************************
elastic                    : ok=11   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=2   
kibana                     : ok=11   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=2   
```

7. запускаем playbook с флагом `--diff`:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: kibana

PLAY [Install Java] ***********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host kibana is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [kibana]
[WARNING]: Platform linux on host elastic is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [elastic]

TASK [Set facts for Java 11 vars] *********************************************************************************************************************************************************************************************************
ok: [elastic]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] *************************************************************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [kibana]
diff skipped: source file size is greater than 104448
changed: [elastic]

TASK [Ensure installation dir exists] *****************************************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.16",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/jdk/11.0.16",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elastic]

TASK [Extract java in the installation directory] *****************************************************************************************************************************************************************************************
changed: [elastic]
changed: [kibana]

TASK [Export environment variables] *******************************************************************************************************************************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-296651leu7wb4/tmpf3rxkbjh/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.16
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [kibana]
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-296651leu7wb4/tmpwwm090pz/jdk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export JAVA_HOME=/opt/jdk/11.0.16
+export PATH=$PATH:$JAVA_HOME/bin
\ No newline at end of file

changed: [elastic]

PLAY [Install Elasticsearch] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [elastic]

TASK [Upload .tar.gz Elasticsearch from local storage] ************************************************************************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [elastic]

TASK [Create directrory for Elasticsearch] ************************************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/elastic/7.10.1",
-    "state": "absent"
+    "state": "directory"
 }

changed: [elastic]

TASK [Extract Elasticsearch in the installation directory] ********************************************************************************************************************************************************************************
changed: [elastic]

TASK [Set environment Elastic] ************************************************************************************************************************************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-296651leu7wb4/tmppoq2by5y/elk.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export ES_HOME=/opt/elastic/7.10.1
+export PATH=$PATH:$ES_HOME/bin
\ No newline at end of file

changed: [elastic]

PLAY [Install Kibana] *********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Download Kibana] ********************************************************************************************************************************************************************************************************************
diff skipped: source file size is greater than 104448
changed: [kibana]

TASK [Create directory for Kibana] ********************************************************************************************************************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
     "path": "/opt/kibana/8.3.3",
-    "state": "absent"
+    "state": "directory"
 }

changed: [kibana]

TASK [Extract Kibana in selected directory] ***********************************************************************************************************************************************************************************************
changed: [kibana]

TASK [Generate configuration whith parameters] ********************************************************************************************************************************************************************************************
--- before
+++ after: /home/vagrant/.ansible/tmp/ansible-local-296651leu7wb4/tmpnh2tpuat/kib.sh.j2
@@ -0,0 +1,5 @@
+# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
+#!/usr/bin/env bash
+
+export KIBANA_HOME=/opt/kibana/8.3.3
+export PATH=$PATH:$KIBANA_HOME/bin
\ No newline at end of file

changed: [kibana]

PLAY RECAP ********************************************************************************************************************************************************************************************************************************
elastic                    : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
kibana                     : ok=11   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

8. Запускаем повторно:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
[WARNING]: Found both group and host with same name: kibana

PLAY [Install Java] ***********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
[WARNING]: Platform linux on host kibana is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [kibana]
[WARNING]: Platform linux on host elastic is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change this. See
https://docs.ansible.com/ansible/2.9/reference_appendices/interpreter_discovery.html for more information.
ok: [elastic]

TASK [Set facts for Java 11 vars] *********************************************************************************************************************************************************************************************************
ok: [elastic]
ok: [kibana]

TASK [Upload .tar.gz file containing binaries from local storage] *************************************************************************************************************************************************************************
ok: [elastic]
ok: [kibana]

TASK [Ensure installation dir exists] *****************************************************************************************************************************************************************************************************
ok: [elastic]
ok: [kibana]

TASK [Extract java in the installation directory] *****************************************************************************************************************************************************************************************
skipping: [elastic]
skipping: [kibana]

TASK [Export environment variables] *******************************************************************************************************************************************************************************************************
ok: [kibana]
ok: [elastic]

PLAY [Install Elasticsearch] **************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [elastic]

TASK [Upload .tar.gz Elasticsearch from local storage] ************************************************************************************************************************************************************************************
ok: [elastic]

TASK [Create directrory for Elasticsearch] ************************************************************************************************************************************************************************************************
ok: [elastic]

TASK [Extract Elasticsearch in the installation directory] ********************************************************************************************************************************************************************************
skipping: [elastic]

TASK [Set environment Elastic] ************************************************************************************************************************************************************************************************************
ok: [elastic]

PLAY [Install Kibana] *********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Download Kibana] ********************************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Create directory for Kibana] ********************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Extract Kibana in selected directory] ***********************************************************************************************************************************************************************************************
ok: [kibana]

TASK [Generate configuration whith parameters] ********************************************************************************************************************************************************************************************
ok: [kibana]

PLAY RECAP ********************************************************************************************************************************************************************************************************************************
elastic                    : ok=9    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
kibana                     : ok=10   changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

9. (todo после мерджа в main) [./playbook/README.md](https://example.com)

10. Ссылка на готовый playbook: (todo после мерджа в main) [./playbook/site.yml](https://example.com)
```yamlex
---
- name: Install Java
  hosts: all
  tasks:
    - name: Set facts for Java 11 vars
      set_fact:
        java_home: "/opt/jdk/{{ java_jdk_version }}"
      tags: java
    - name: Upload .tar.gz file containing binaries from local storage
      copy:
        src: "{{ java_oracle_jdk_package }}"
        dest: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
      register: download_java_binaries
      until: download_java_binaries is succeeded
      tags: java
    - name: Ensure installation dir exists
      file:
        state: directory
        path: "{{ java_home }}"
      tags: java
    - name: Extract java in the installation directory
      unarchive:
        copy: false
        src: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
        dest: "{{ java_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ java_home }}/bin/java"
      tags:
        - java
      ignore_errors: "{{ ansible_check_mode }}"
    - name: Export environment variables
      template:
        src: jdk.sh.j2
        dest: /etc/profile.d/jdk.sh
      tags: java
- name: Install Elasticsearch
  hosts: elasticsearch
  tasks:
    - name: Upload .tar.gz Elasticsearch from local storage
      copy:
        src: "{{ elastic_package }}"
        dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
      register: get_elastic
      until: get_elastic is succeeded
      tags: elastic
    - name: Create directrory for Elasticsearch
      file:
        state: directory
        path: "{{ elastic_home }}"
      tags: elastic
    - name: Extract Elasticsearch in the installation directory
      unarchive:
        copy: false
        src: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
        dest: "{{ elastic_home }}"
        extra_opts: [--strip-components=1]
        creates: "{{ elastic_home }}/bin/elasticsearch"
      ignore_errors: "{{ ansible_check_mode }}"
      tags:
        - elastic
    - name: Set environment Elastic
      template:
        src: templates/elk.sh.j2
        dest: /etc/profile.d/elk.sh
      tags: elastic
- name: Install Kibana
  hosts: kibana
  tasks:
    - name: Download Kibana
      copy:
        src: "{{ kibana_package }}"
        dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
    - name: Create directory for Kibana
      file:
        state: directory
        path: "{{ kibana_home }}"
    - name: Extract Kibana in selected directory
      unarchive:
        copy: false
        src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
        dest: "{{ kibana_home }}"
      ignore_errors: "{{ ansible_check_mode }}"
    - name: Generate configuration whith parameters
      template:
        src: templates/kib.sh.j2
        dest: /etc/profile.d/kib.sh
```