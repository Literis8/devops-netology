# Домашнее задание к занятию "08.01 Введение в Ansible"

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

### Решение
1. `some_fact` имеет значение 12. Запуск playbook:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/test.yml
PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP ************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

2. Это файл playbook/group_vars/all/examp.yml. Вывод после внесения изменений:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/test.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP ************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

3. Запускаем 2 контейнера (в контейнер с ubuntu устанавливаем python так как его там почему-то нет):
```shell
vagrant@vagrant:/devops-netology/playbook$ docker run -d --name centos7 centos:7 sleep 100000000
1723efcae40e0156dbc922c1b5dec0feb8a3f856db57ac0d516c4189e6e8dbaf
vagrant@vagrant:/devops-netology/playbook$ docker run -d --name ubuntu ubuntu sleep 100000000
b2ca917dc64011b1e6e446df116870cabf76b08866000173429fa786341c91fe
vagrant@vagrant:/devops-netology/playbook$ docker ps
CONTAINER ID   IMAGE      COMMAND             CREATED          STATUS          PORTS     NAMES
b2ca917dc640   ubuntu     "sleep 100000000"   7 seconds ago    Up 5 seconds              ubuntu
1723efcae40e   centos:7   "sleep 100000000"   55 seconds ago   Up 54 seconds             centos7
vagrant@vagrant:/devops-netology/playbook$

```

4. Запускаем Ansible на prod.yml значения some_fact для centos7 - el, для ubuntu - deb
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

5. меняем значения в файлах playbook/group_vars/deb/examp.yml и playbook/group_vars/el/examp.yml

6. получаем вывод:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

7. Шифруем факты:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-vault encrypt group_vars/deb/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
vagrant@vagrant:/devops-netology/playbook$ ansible-vault encrypt group_vars/el/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```

8. Запускаем playbook:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Для работы на control node подойдет плагин local:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-doc plugin -t connection -l
```

10. Добавляем localhost в prod.yml:
```shell
  local:
    hosts:
      localhost:
        ansible_connection: local
```

11. Запускаем Ansible:
```shell
vagrant@vagrant:/devops-netology/playbook$ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password:

PLAY [Print os facts] *************************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] *******************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] *****************************************************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP ************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

12. Репозиторий находится в ./playbook
