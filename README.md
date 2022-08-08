# Домашнее задание к занятию "08.03 Работа с Roles"

## Подготовка к выполнению
1. Создайте два пустых публичных репозитория в любом своём проекте: elastic-role и kibana-role.
2. Скачайте [role](./roles/) из репозитория с домашним заданием и перенесите его в свой репозиторий elastic-role.
3. Скачайте дистрибутив [java](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html) и положите его в директорию `playbook/files/`. 
4. Установите molecule: `pip3 install molecule`
5. Добавьте публичную часть своего ключа к своему профилю в github.

### Решение:
1. Созданы репозитории [elastic-role](https://github.com/Literis8/elastic-role) и [kibana-role](https://github.com/Literis8/kibana-role).
2. Выполнено
3. Выполнено, на всякий случай еще скачал дистрибутивы elasticsearch и kibana
4. Выполнено
5. Ключ сгенерирован `vagrant@vagrant:~$ ssh-keygen -t ed25519 -C "literis8@gmail.com"` и добавлен

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana и написать 
playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий 
с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:
   ```yaml
   ---
     - src: git@github.com:netology-code/mnt-homeworks-ansible.git
       scm: git
       version: "1.0.1"
       name: java 
   ```
2. При помощи `ansible-galaxy` скачать себе эту роль. Запустите  `molecule test`, посмотрите на вывод команды.
3. Перейдите в каталог с ролью elastic-role и создайте сценарий тестирования по умолчаню при помощи `molecule init scenario --driver-name docker`.
4. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
5. Создайте новый каталог с ролью при помощи `molecule init role --driver-name docker kibana-role`. Можете использовать другой драйвер, который более удобен вам.
6. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`. Проведите тестирование на разных дистрибитивах (centos:7, centos:8, ubuntu).
7. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию.
8. Добавьте roles в `requirements.yml` в playbook.
9. Переработайте playbook на использование roles.
10. Выложите playbook в репозиторий.
11. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

### Решение

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для elastic, kibana и написать 
playbook для использования этих ролей. Ожидаемый результат: существуют два ваших репозитория с roles и один репозиторий 
с playbook.

1. Файл создан

2. Доустанавливаем `molecule-docker` и выполняем команды:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-galaxy install -r requirements.yml -p roles
- extracting java to /devops-netology/playbook/roles/java
- java (1.0.1) was installed successfully
```
Исправляем ошибки в `molecule test`:
   * добавляем в `.playbook/roles/java/meta/main.yml`:
```shell
  role_name: my_name
  namespace: my_galaxy_namespace
```
Запускаем `molecule test`:
```shell
vagrant@vagrant:/devops-netology/playbook/roles/java$ molecule test
INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/vagrant/.cache/ansible-compat/38a096/modules:/home/vagrant/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/vagrant/.cache/ansible-compat/38a096/collections:/home/vagrant/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/vagrant/.cache/ansible-compat/38a096/roles:/home/vagrant/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Using /home/vagrant/.cache/ansible-compat/38a096/roles/my_galaxy_namespace.my_name symlink to current repository in order to enable Ansible to find the role using its expected full name.
INFO     Running default > dependency
INFO     Running ansible-galaxy collection install -v --pre community.docker:>=3.0.0-a2
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running default > lint
INFO     Lint is disabled.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy
INFO     Sanity checks: 'docker'

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
ok: [localhost] => (item=centos8)
ok: [localhost] => (item=centos7)
ok: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running default > syntax

playbook: /devops-netology/playbook/roles/java/molecule/default/converge.yml
INFO     Running default > create

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
skipping: [localhost] => (item=None) 
skipping: [localhost] => (item=None) 
skipping: [localhost] => (item=None) 
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create Dockerfiles from image names] *************************************
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}) 
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}) 
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}) 

TASK [Discover local Docker images] ********************************************
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 2, 'ansible_index_var': 'i'})

TASK [Build an Ansible compatible image (new)] *********************************
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8) 
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7) 
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest) 

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) creation to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (299 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (298 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (297 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (296 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (295 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (294 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (293 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (292 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (291 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (290 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (289 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (288 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (287 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (286 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (285 retries left).
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '787928893330.26274', 'results_file': '/home/vagrant/.ansible_async/787928893330.26274', 'changed': True, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var':
 'item'})
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '752873175817.26302', 'results_file': '/home/vagrant/.ansible_async/752873175817.26302', 'changed': True, 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var':
 'item'})
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (299 retries left).
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '139126147085.26335', 'results_file': '/home/vagrant/.ansible_async/139126147085.26335', 'changed': True, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_v
ar': 'item'})

PLAY RECAP *********************************************************************
localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

INFO     Running default > prepare
WARNING  Skipping, prepare playbook not configured.
INFO     Running default > converge

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ubuntu]
ok: [centos8]
ok: [centos7]

TASK [Include mnt-homeworks-ansible] *******************************************
ERROR! the role 'mnt-homeworks-ansible' was not found in /devops-netology/playbook/roles/java/molecule/default/roles:/home/vagrant/.cache/ansible-compat/38a096/roles:/home/vagrant/.cache/molecule/java/default/roles:/devops-netology/playbook/roles:/home/vagrant/.ansible/roles:/usr/share/ansible/roles:/etc/ansibl
e/roles:/devops-netology/playbook/roles/java/molecule/default

The error appears to be in '/devops-netology/playbook/roles/java/molecule/default/converge.yml': line 7, column 15, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

      include_role:
        name: "mnt-homeworks-ansible"
              ^ here

PLAY RECAP *********************************************************************
centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
centos8                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

WARNING  Retrying execution failure 2 of: ansible-playbook --inventory /home/vagrant/.cache/molecule/java/default/inventory --skip-tags molecule-notest,notest /devops-netology/playbook/roles/java/molecule/default/converge.yml
CRITICAL Ansible return code was 2, command was: ['ansible-playbook', '--inventory', '/home/vagrant/.cache/molecule/java/default/inventory', '--skip-tags', 'molecule-notest,notest', '/devops-netology/playbook/roles/java/molecule/default/converge.yml']
WARNING  An error occurred during the test sequence action: 'converge'. Cleaning up.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
```

3. Выполнено:
```shell
vagrant@vagrant:/devops-netology/playbook/roles/elastic-role$ molecule init scenario --driver-name docker
INFO     Initializing new scenario default...
INFO     Initialized scenario in /devops-netology/playbook/roles/elastic-role/molecule/default successfully.
```

4. Добавляем изменения в ./playbook/roles/elastic-role/meta/main.yml
```yamlex
  role_name: my_name 
  namespace: my_galaxy_namespace 
  platforms:
    - name: CentOS
      versions:
        - 8
    - name: ubuntu
      versions: latest
```

Добавляем изменения в ./playbook/roles/elastic-role/molecule/default/molecule.yml:
```yamlex
platforms:
  - name: centos8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: ubuntu
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
```

Изменяем ./playbook/roles/elastic-role/tasks/main.yml для локальной загрузки дистрибутива:
```yamlex
---
  - name: Upload tar.gz Elasticsearch from remote URL
    copy:
      src: "{{ elastic_package }}"
      dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
...
```

Изменяем переменную с путем дистрибутива ./playbook/roles/elastic-role/defaults/main.yml:
```yamlex
  elastic_package: "../../files/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
```

Запускаем тест роли:
```shell
vagrant@vagrant:/devops-netology/playbook/roles/elastic-role$ molecule test
INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/vagrant/.cache/ansible-compat/12e536/modules:/home/vagrant/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/vagrant/.cache/ansible-compat/12e536/collections:/home/vagrant/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/vagrant/.cache/ansible-compat/12e536/roles:/home/vagrant/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Using /home/vagrant/.cache/ansible-compat/12e536/roles/my_galaxy_namespace.my_name symlink to current repository in order to enable Ansible to find the role using its expected full name.
INFO     Running default > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running default > lint
INFO     Lint is disabled.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy
INFO     Sanity checks: 'docker'

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
ok: [localhost] => (item=centos8)
ok: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running default > syntax

playbook: /devops-netology/playbook/roles/elastic-role/molecule/default/converge.yml
INFO     Running default > create

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
skipping: [localhost] => (item=None) 
skipping: [localhost] => (item=None) 
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create Dockerfiles from image names] *************************************
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}) 
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}) 

TASK [Discover local Docker images] ********************************************
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 0, 'ansible_index_var': 'i'})
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i': 1, 'ansible_index_var': 'i'})

TASK [Build an Ansible compatible image (new)] *********************************
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8) 
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest) 

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) creation to complete] *******************************
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '964141084615.35443', 'results_file': '/home/vagrant/.ansible_async/964141084615.35443', 'changed': True, 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var':
 'item'})
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '81124846356.35471', 'results_file': '/home/vagrant/.ansible_async/81124846356.35471', 'changed': True, 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var
': 'item'})

PLAY RECAP *********************************************************************
localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

INFO     Running default > prepare
WARNING  Skipping, prepare playbook not configured.
INFO     Running default > converge

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ubuntu]
ok: [centos8]

TASK [Include elastic-role] ****************************************************

TASK [elastic-role : Upload tar.gz Elasticsearch from remote URL] **************
changed: [ubuntu]
changed: [centos8]

TASK [elastic-role : Create directrory for Elasticsearch] **********************
changed: [ubuntu]
changed: [centos8]

TASK [elastic-role : Extract Elasticsearch in the installation directory] ******
changed: [centos8]
changed: [ubuntu]

TASK [elastic-role : Set environment Elastic] **********************************
changed: [centos8]
changed: [ubuntu]

PLAY RECAP *********************************************************************
centos8                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Running default > idempotence

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [centos8]
ok: [ubuntu]

TASK [Include elastic-role] ****************************************************

TASK [elastic-role : Upload tar.gz Elasticsearch from remote URL] **************
ok: [centos8]
ok: [ubuntu]

TASK [elastic-role : Create directrory for Elasticsearch] **********************
ok: [centos8]
ok: [ubuntu]

TASK [elastic-role : Extract Elasticsearch in the installation directory] ******
skipping: [centos8]
skipping: [ubuntu]

TASK [elastic-role : Set environment Elastic] **********************************
ok: [centos8]
ok: [ubuntu]

PLAY RECAP *********************************************************************
centos8                    : ok=4    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
ubuntu                     : ok=4    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Idempotence completed successfully.
INFO     Running default > side_effect
WARNING  Skipping, side effect playbook not configured.
INFO     Running default > verify
INFO     Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Example assertion] *******************************************************
ok: [centos8] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [ubuntu] => {
    "changed": false,
    "msg": "All assertions passed"
}

PLAY RECAP *********************************************************************
centos8                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Verifier completed successfully.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
```

5. Создаем роль:
```shell
vagrant@vagrant:/devops-netology/playbook/roles$ molecule init role -d docker netology.kibana
INFO     Initializing new role kibana...
No config file found; using defaults
- Role kibana was created successfully
Invalid -W option ignored: unknown warning category: 'CryptographyDeprecationWarning'
Invalid -W option ignored: unknown warning category: 'CryptographyDeprecationWarning'
[WARNING]: No inventory was parsed, only implicit localhost is available
localhost | CHANGED => {"backup": "","changed": true,"msg": "line added"}
INFO     Initialized role in /devops-netology/playbook/roles/kibana successfully.
```

6. Заполняем ./playbook/roles/kibana/tasks/main.yml:
```yamlex
---
---
- name: Download Kibana
  copy:
    src: "{{ kibana_package }}"
    dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
  register: get_kibana
  until: get_kibana is succeeded
  tags: kibana
- name: Create directory for Kibana
  file:
    state: directory
    path: "{{ kibana_home }}"
  tags: kibana
- name: Extract Kibana in selected directory
  become: true
  unarchive:
    copy: false
    src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
    dest: "{{ kibana_home }}"
  ignore_errors: "{{ ansible_check_mode }}"
  tags: kibana
- name: Generate configuration whith parameters
  template:
    src: templates/kib.sh.j2
    dest: /etc/profile.d/kib.sh
  tags: kibana
# tasks file for kibana
```

Запролняем ./playbook/roles/kibana/defaults/main.yml:
```yamlex
---
  kibana_version: 8.3.3
  kibana_home: "/opt/kibana/{{ kibana_version }}"
  kibana_package: "../../files/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
# defaults file for kibana
```

Добавляем дистрибутивы для тестирования в ./playbook/roles/kibana/molecule/default/molecule.yml:
```yamlex
platforms:
  - name: centos8
    image: docker.io/pycontribs/centos:8
    pre_build_image: true
  - name: centos7
    image: docker.io/pycontribs/centos:7
    pre_build_image: true
  - name: ubuntu
    image: docker.io/pycontribs/ubuntu:latest
    pre_build_image: true
```

Запускаем `molekule test`:
```shell
vagrant@vagrant:/devops-netology/playbook/roles/kibana$ molecule test
INFO     default scenario test matrix: dependency, lint, cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect, verify, cleanup, destroy
INFO     Performing prerun with role_name_check=0...
INFO     Set ANSIBLE_LIBRARY=/home/vagrant/.cache/ansible-compat/805c02/modules:/home/vagrant/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/home/vagrant/.cache/ansible-compat/805c02/collections:/home/vagrant/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/home/vagrant/.cache/ansible-compat/805c02/roles:/home/vagrant/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Using /home/vagrant/.cache/ansible-compat/805c02/roles/netology.kibana symlink to current repository in order to enable Ansible to find the role using its expected full name.
INFO     Running default > dependency
WARNING  Skipping, missing the requirements file.
WARNING  Skipping, missing the requirements file.
INFO     Running default > lint
INFO     Lint is disabled.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy
INFO     Sanity checks: 'docker'

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
ok: [localhost] => (item=centos8)
ok: [localhost] => (item=centos7)
ok: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running default > syntax

playbook: /devops-netology/playbook/roles/kibana/molecule/default/converge.yml
INFO     Running default > create

PLAY [Create] ******************************************************************

TASK [Log into a Docker registry] **********************************************
skipping: [localhost] => (item=None) 
skipping: [localhost] => (item=None) 
skipping: [localhost] => (item=None) 
skipping: [localhost]

TASK [Check presence of custom Dockerfiles] ************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create Dockerfiles from image names] *************************************
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}) 
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}) 
skipping: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}) 

TASK [Discover local Docker images] ********************************************
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i'
: 0, 'ansible_index_var': 'i'})
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item', 'i'
: 1, 'ansible_index_var': 'i'})
ok: [localhost] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'item': {'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item',
 'i': 2, 'ansible_index_var': 'i'})

TASK [Build an Ansible compatible image (new)] *********************************
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:8) 
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/centos:7) 
skipping: [localhost] => (item=molecule_local/docker.io/pycontribs/ubuntu:latest) 

TASK [Create docker network(s)] ************************************************

TASK [Determine the CMD directives] ********************************************
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:8', 'name': 'centos8', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7', 'pre_build_image': True})
ok: [localhost] => (item={'image': 'docker.io/pycontribs/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True})

TASK [Create molecule instance(s)] *********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) creation to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) creation to complete (300 retries left).
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '950775924649.34561', 'results_file': '/home/vagrant/.ansible_async/950775924649.34561', 'changed': True, 'item': {'image': 'docker.io/pycontrib
s/centos:8', 'name': 'centos8', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '318096305093.34589', 'results_file': '/home/vagrant/.ansible_async/318096305093.34589', 'changed': True, 'item': {'image': 'docker.io/pycontrib
s/centos:7', 'name': 'centos7', 'pre_build_image': True}, 'ansible_loop_var': 'item'})
changed: [localhost] => (item={'failed': 0, 'started': 1, 'finished': 0, 'ansible_job_id': '716358132197.34616', 'results_file': '/home/vagrant/.ansible_async/716358132197.34616', 'changed': True, 'item': {'image': 'docker.io/pycontrib
s/ubuntu:latest', 'name': 'ubuntu', 'pre_build_image': True}, 'ansible_loop_var': 'item'})

PLAY RECAP *********************************************************************
localhost                  : ok=5    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

INFO     Running default > prepare
WARNING  Skipping, prepare playbook not configured.
INFO     Running default > converge

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [ubuntu]
ok: [centos8]
ok: [centos7]

TASK [Include netology.kibana] *************************************************

TASK [netology.kibana : Download Kibana] ***************************************
changed: [centos7]
changed: [ubuntu]
changed: [centos8]

TASK [netology.kibana : Create directory for Kibana] ***************************
changed: [centos8]
changed: [centos7]
changed: [ubuntu]

TASK [netology.kibana : Extract Kibana in selected directory] ******************
changed: [centos8]
changed: [ubuntu]
changed: [centos7]

TASK [netology.kibana : Generate configuration whith parameters] ***************
changed: [ubuntu]
changed: [centos7]
changed: [centos8]

PLAY RECAP *********************************************************************
centos7                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
centos8                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Running default > idempotence

PLAY [Converge] ****************************************************************

TASK [Gathering Facts] *********************************************************
ok: [centos8]
ok: [ubuntu]
ok: [centos7]

TASK [Include netology.kibana] *************************************************

TASK [netology.kibana : Download Kibana] ***************************************
ok: [centos8]
ok: [centos7]
ok: [ubuntu]

TASK [netology.kibana : Create directory for Kibana] ***************************
ok: [centos7]
ok: [centos8]
ok: [ubuntu]

TASK [netology.kibana : Extract Kibana in selected directory] ******************
ok: [ubuntu]
ok: [centos7]
ok: [centos8]

TASK [netology.kibana : Generate configuration whith parameters] ***************
ok: [centos7]
ok: [ubuntu]
ok: [centos8]

PLAY RECAP *********************************************************************
centos7                    : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
centos8                    : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=5    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Idempotence completed successfully.
INFO     Running default > side_effect
WARNING  Skipping, side effect playbook not configured.
INFO     Running default > verify
INFO     Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Example assertion] *******************************************************
ok: [centos7] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [centos8] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [ubuntu] => {
    "changed": false,
    "msg": "All assertions passed"
}

PLAY RECAP *********************************************************************
centos7                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
centos8                    : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Verifier completed successfully.
INFO     Running default > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running default > destroy

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (300 retries left).
FAILED - RETRYING: [localhost]: Wait for instance(s) deletion to complete (299 retries left).
changed: [localhost] => (item=centos8)
changed: [localhost] => (item=centos7)
changed: [localhost] => (item=ubuntu)

TASK [Delete docker networks(s)] ***********************************************

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
```

7. Репозитории выложены, теги проставлены

8. Добавляем roles в `requirements.yml` в playbook.
```yamlex
---
  - src: git@github.com:netology-code/mnt-homeworks-ansible.git
    scm: git
    version: "1.0.1"
    name: java
  - src: git@github.com:Literis8/elastic-role.git
    scm: git
    version: "1.0.1"
    name: elastic
  - src: git@github.com:Literis8/kibana-role.git
    scm: git
    version: "1.0.0"
    name: kibana
```
9. Заполняем playbook ./playbook/site.yml
```yamlex
---
- hosts: all
  roles:
  - java
- hosts: elasticsearch
  roles:
  - elastic
- hosts: kibana
  roles:
  - kibana
```

Скачиваем роли:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-galaxy install -r requirements.yml -p roles
Starting galaxy role install process
- java (1.0.1) is already installed, skipping.
- extracting elastic to /devops-netology/playbook/roles/elastic
- elastic (1.0.1) was installed successfully
- extracting kibana to /devops-netology/playbook/roles/kibana
- kibana (1.0.0) was installed successfully
```

Исправляем ошибки и пробуем запустить playbook:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook -i inventory/prod.yml site.yml
[WARNING]: Found both group and host with same name: kibana
[WARNING]: Found both group and host with same name: elasticsearch

PLAY [all] ********************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
[WARNING]: Distribution debian 11.4 on host kibana should use /usr/bin/python3, but is using /usr/bin/python2.7, since the discovered platform python interpreter was not present. See https://docs.ansible.com/ansible-
core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [kibana]
[WARNING]: Distribution debian 11.4 on host elasticsearch should use /usr/bin/python3, but is using /usr/bin/python2.7, since the discovered platform python interpreter was not present. See https://docs.ansible.com/ansible-
core/2.13/reference_appendices/interpreter_discovery.html for more information.
ok: [elasticsearch]

TASK [java : Set facts for Java 11 vars] **************************************************************************************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [java : Upload .tar.gz file containing binaries from local storage] ******************************************************************************************************************************************************************
ok: [kibana]
ok: [elasticsearch]

TASK [java : Ensure installation dir exists] **********************************************************************************************************************************************************************************************
ok: [elasticsearch]
ok: [kibana]

TASK [java : Extract java in the installation directory] **********************************************************************************************************************************************************************************
skipping: [elasticsearch]
skipping: [kibana]

TASK [java : Export environment variables] ************************************************************************************************************************************************************************************************
ok: [kibana]
ok: [elasticsearch]

PLAY [elasticsearch] **********************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [elastic : Upload tar.gz Elasticsearch from remote URL] ******************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [elastic : Create directrory for Elasticsearch] **************************************************************************************************************************************************************************************
ok: [elasticsearch]

TASK [elastic : Extract Elasticsearch in the installation directory] **********************************************************************************************************************************************************************
changed: [elasticsearch]

TASK [elastic : Set environment Elastic] **************************************************************************************************************************************************************************************************
changed: [elasticsearch]

PLAY [kibana] *****************************************************************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************************************
ok: [kibana]

TASK [kibana : Download Kibana] ***********************************************************************************************************************************************************************************************************
changed: [kibana]

TASK [kibana : Create directory for Kibana] ***********************************************************************************************************************************************************************************************
changed: [kibana]

TASK [kibana : Extract Kibana in selected directory] **************************************************************************************************************************************************************************************
changed: [kibana]

TASK [kibana : Generate configuration whith parameters] ***********************************************************************************************************************************************************************************
changed: [kibana]

PLAY RECAP ********************************************************************************************************************************************************************************************************************************
elasticsearch              : ok=10   changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
kibana                     : ok=10   changed=4    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```
10. Репозитории выложены.
11. Ссылка на репозиторий с playbook, ссылка на репозиторий с elastic-role, ссылка на репозиторий kibana-role.

