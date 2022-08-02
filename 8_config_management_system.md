# 8. Система управления конфигурациями
## 8.1 Введение в Ansible
### 8.1.1. Ansible
**Ansible** - комплекс ППО для управления инфраструктурной составляющей ваших систем и развёртыванием приложений.
* **Прост в использовании** - написан на python и YAML
* **Не требует установки агентов** - для подключения к удалённому хосту используется SSH
* **Идемпотентен** - независимо от того, сколько раз вы совершите запуск, результат будет идентичным
* **Легко расширяем** - любой дополнительный функционал можно реализовать на bash/python

Основной концепт **ansible** заключается в следующем:
* Существует некоторая **control node** - хост с предустановленным **ansible**. С этой node мы будем исполнять 
инструкции на нужных нам хостах
* **Managed node** - хосты, на которых мы хотим получить результат исполнения инструкций
* **Inventory** - описание **managed node**

Внутри Ansible существуют следующие понятия:
* Playbook
* Play
* Role
* Task
* Handlers
* Inventory
* Group vars
* Facts
* Templates
* Collections

### 8.1.2. Playbook
**Ansible Playbook** - набор plays, содержащих в себе roles и\или tasks, которые выполняются на указанных в inventory 
хостах с определёнными параметрами для каждого из них или для их групп. **Playbook** описывается на языке **YAML**.

Пример содержимого одного **play** в **Playbook**:
```yamlex
---
  - name: Try run Vector # Произвольное название play
    hosts: all # Перечисление хостов
    tasks: # Объявление списка tasks
      - name: Get Vector version # Произвольное имя для task
        ansible.builtin.command: vector --version # Что и как необходимо сделать
        register: is_installed # Запись результата в переменную is_installed
      - name: Get RPM # Произвольное имя для второй task
        ansible.builtin.get_url: # Объявление использования модуля get_url, ниже указание его параметров
          url: "https://package.timber.io/vector/{{ vector_version }}/vector.rpm"
          dest: "{{ ansible_user_dir }}/vector.rpm"
          mode: 0755
        when: # Условия при которых task будет выполняться
          - is_installed is failed
          - ansible_distribution == "CentOS"
```

### 8.1.3. Role
**Role** - группа **tasks**, которая нацелена на выполнение действий, приводящих к единому результату.
* **Role** - выполняет список действий
* Список может состоять из одного действия
* **Role** может быть написана самостоятельно или скопирована из galaxy при помощи команды **ansible-galaxy**
* **Role** хранят по умолчанию в директории roles, у каждой role своя директория внутри
* Пример использования **role** в рамках **play**:
```yamlex
---
  - name: Try run Vector # Произвольное название play
    hosts: all # Перечисление хостов
    roles: # Объявление списка roles
      - vector # Вызов роли vector из директории с roles
```

### 8.1.4. Inventory
**Inventory** - директория с файлом или группой файлов, в которых описано на каких хостах необходимо выполнять действия.
* **Inventory** может быть описан в виде стандартного **host.ini** файла или при помощи **yaml** структуры
* Лучшей практикой является использование **yaml inventory**.
* Пример **inventory** файла:
```yamlex
---
  prod: # Группа серверов
    children:
      nginx:
        hosts:
          prod-ff-74669-02:
            ansible_host: 255.245.12.32
            ansible_user: prod
    children:
      application:
        hosts:
          174.96.45.23:
  test:
    children:
      nginx:
        hosts:
          localhost:
            ansible_connection: local
```

### 8.1.5. Group Vars
**Group vars** - в общем понимании, файлы с переменными для групп хостов или для всех хостов, указанных в **inventory**.
* По умолчанию, хранятся в директории **group_vars**
* Определение переменных для всех хостов происходит в директории **all**
* Определение переменных для групп из **inventory** происходит в соответствующих им директориях
* Файлы с переменными могут называться, основываясь на внутренней логике **playbook**, сами имена имеют большую важность
для пользователей

#### Приоритеты переменных
**Переменные** могут определяться и переопределяться на многих уровнях в **ansible**. Уровень приоритезации (от меньшего
к большему) указаны ниже:
* Значения из командной строки **(-u username)**
* Значения по умолчанию из **roles**
* Значения из файла **inventory**
* Значения из файлов **group_vars/all**
* Значения из файлов **group_vars/{groupname}**
* Переменные из **play**
* Значения переменных **role** из **vars**
* Экстра-аргументы из командной строки **(-e "user=myuser")**

Полный перечень приоритетов можно увидеть в официальной 
[документации](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id16)

### 8.1.6. Vault
**Ansible Vault** - инструмент, позволяющий зашифровать переменные (AES256), скрыв чувствительные данные от общего 
использования
* Удобно хранить параметры пользователей (логины, пароли)
* Можно шифровать как отдельные файлы, так и отдельные переменные
* Для использования шифрованных данных необходимо предоставлять пароль прямым вводом в консоль или в виде файла

Основные команды для управления **vault**:
* ansible-vault create <filename>
* ansible-vault view <filename>
* ansible vault edit <filename>

### 8.1.7. Templates
**Templates** - инструмент, позволяющий создать кастомизированный конфигурационный файл, на основе шаблона. 
Для шаблонизации используется **Jinja**
* Любой конфигурационный файл, даже без переменных внутри, может быть использован
* Шаблон должен иметь расширение **j2** 
 
Шаблонизация напоминает использование форматирования строк:
```
'Привет, {name}!'.format(name='Мир')
>>> Привет, Мир!
```
### 8.1.8. Facts
**Facts** - сбор информации об удалённом хосте, включая сетевую информацию, информацию о системе, информацию 
о пользователе, и прочее.
* Можно собирать данные об одном хосте и использовать эти данные для настройки другого хоста
* Факты собираются автоматически в начале проигрывания **play**
* `ansible <hostname> -m setup` - получить facts с hostname
* **Facts** хранятся в переменной **ansible_facts**
* Сбор **facts** можно принудительно выключить, вписав в **play** `gather_facts: no`

### 8.1.9. Collections
**Collections** - способ распространения контента **Ansible**. Включает в
себя набор **roles**, **modules**, **playbooks**.
* Наименование состоит из **namespace.collections**
* Под **namespace** понимается, например, название компании или нечто объединяющее все **collections** для вашего 
**namespace**
* Под **collections** понимается само название коллекции
* Создаются и публикуются при помощи **ansible-galaxy**

#### Краткий итог
* **Ansible** - занимается автоматизацией рутины
* Весь процесс автоматизации описывается в **playbook**
* **Playbook** содержит информацию о том **что** и **где** необходимо сделать
* То, **что** необходимо сделать описывается в блоке **play**
* **Где** необходимо выполнять **play** написано в **inventory**
* **Play** состоит из перечислений **task** и **role**
* **Task** - атомарное действие над **host** из **inventory**
* **Role** - набор **tasks** вне **playbook**, которые выполняются для получение одного общего результата
* Абсолютно все сущности кастомизируются при помощи переменных
* Переменные **playbook** лучше всего хранить в **group vars**
* Переменные можно хранить и в других местах, существует приоритезация переменных
* Переменные можно шифровать при помощи **vault**
* Переменные можно подставлять в **templates** для создания конфигурационных файлов

### 8.1.10. Первый запуск
#### Подготовка к запуску
Для скачивания необходимо воспользоваться пакетными менеджерами:
* yum install ansbile
* apt install ansible
* pip3 install ansible --user

[Инструкции по установке в разных версиях ОС](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-with-pip)

На текущий момент, стабильная версия - 2.10

Если уже установлен ansible, то перед установкой текущей версии, нужно удалить старую

В пакет входят:
* **ansible** - определение и запуск **playbook** из одного **task** на наборе **hosts**
* **ansible-playbook** - запуск полноценного **playbook**
* **ansible-vault** - шифрование хранилища методом AES256
* **ansible-galaxy** - скачивание **roles** и **collections**
* **ansible-lint** - используется для проверки синтаксиса
* **ansible-console** - консоль для запуска **tasks**
* **ansible-config** - просмотр и управление конфигурацией **ansible**
* **ansible-doc** - просмотр документации **modules**
* **ansible-inventory** - просмотр информации о **hosts** из **inventory**
* **ansible-pull** - скачивание **playbook** и запуск на **localhost**
* **ansible-test** - тестирование **collections**

#### Запуск команд
```shell
# ansible -m ping localhost # Сделаем ping на locahost
# ansible -m ping -i inventory.yml all # Сделаем ping на всех хостах из inventory
# ansible -m ping -i inventory.yml <group_name> # Сделаем ping на всех хостах группы <group_name>
# ansible-playbook site.yml -i inventory/test.yml # Запуск site на хостах из test
# ansible-inventory -i inventory.yml --graph <group_name> # Показать хосты группы
# ansible-inventory -i inventory.yml --list # Показать все переменные всех хостов из inventory
# ansible-inventory -i inventory.yml --list <hostname> # Показать все переменные хоста из inventory
# ansible-doc <plugin_name> # Показать документацию по плагину
# ansible-vault create <filename> # Создать новый зашифрованные файл
# ansible-vault edit <filename> # Отредактировать зашифрованный файл
# ansible-vault view <filename> # Просмотреть зашифрованный файл
# ansible-vault rekey <filename> # Поменять пароль у файла
# ansible-vault decrypt <filename> # Расшифровать файл 
```

#### Cтруктура директории с Playbook
```
group_vars/
group_vars/all/
group_vars/all/some_variable.yml
group_vars/<group_name>/

inventory/
inventory/prod.yml
inventory/test.yml

roles/
roles/<role_fodlers>/

site.yml

requirement.yml
```


### 8.1.11 Итоги
* **Ansible** - занимается автоматизацией рутины
* Весь процесс автоматизации описывается в **playbook**
* **Playbook** содержит информацию о том **что** и **где** необходимо сделать
* **Role** - набор **tasks** вне **playbook**, которые выполняются для получение одного общего результата
* Переменные **playbook** лучше всего хранить в **group vars**
* Переменные можно хранить и в других местах, существует приоритезация переменных
* Переменные можно подставлять в **templates** для создания конфигурационных файлов
* **ansible** - определение и запуск **playbook** из одного **task** на наборе **hosts**
* **ansible-playbook** - запуск полноценного **playbook**
* **ansible-vault** - шифрование хранилища методом AES256

## 8.2 Работа с Playbook 
### 8.2.1. Что такое Playbook?
**Ansible Playbook** - набор plays, содержащих в себе roles и\или tasks, которые выполняются на указанных в inventory 
хостах с определёнными параметрами для каждого из них или для их групп.

Иными словами, **Playbook** описывает:
* Что делать?
* Какой результат ожидается?
* Какими средствами результат достигается?
* На каких хостах?
* С какими параметрами?

**Playbook** выполняется последовательно от верхнего **play** к нижнему

### 8.2.2. Play
**Play** нужны для **перечисления** действий, которые необходимо воспроизвести на хосте или на указанной группе хостов.
**Play** состоит из:
* **name** - имя **Play**
* **hosts** - перечисление хостов
* **pre_tasks** - необязательный параметр, tasks которые нужно выполнить в первую очередь, до roles и tasks, могут 
обращаться к handlers
* **tasks** - перечисление действий, которые нужно сделать на хостах, могут обращаться к handlers, не рекомендуется 
указывать, если есть roles
* **post_tasks** - необязательный параметр, перечисление tasks, которые необходимо выполнить после tasks и roles

Также, **Play** может содержать:
* **roles** - перечисление ролей, которые необходимо запустить на хостах, могут обращаться к **handlers**, 
не рекомендуется указывать, если есть **tasks**
* **handlers** - обработчики событий, запускаются, если какая-то **task** или **role** обратилась к **handler**, могут 
быть сгруппированы через **listen**
* **tags** - позволяет группировать **roles**, **tasks** и вызывать их запуск отдельно от остальных сущностей

И ещё немного зарезервированных параметров:
* **any_errors_fatal** - любая **tasks**, выполняемая на любом хосте может вызвать fatal и завершить выполнение **play**
на всех хостах
* **become** - позволяет повысить привилегии для выполняемых **tasks**
* **become_user** - позволяет выбрать пользователя под которым будут повышаться привилегии
* **check_mode** - булевая переменная, помогающая определить, происходит ли запуск в **check** моде или нет
* **collections** - позволяет указать имена коллекций
* **debugger** - позволяет запустить **debugger**
* **diff** - переключатель вывода информации при использовании флага **diff**
* **force_handlers** - позволяет принудительно оповестить **handlers** на запуск
* **gather_facts** - булевая переменная для контроля запуска сбора фактов с хостов
* **ignore_errors** - позволяет игнорировать ошибки при выполнении **tasks** и
продолжить выполнение **play**
* **ignore_unreachable** - позволяет игнорировать ошибки недоступности хоста и
продолжать выполнение **play**
* **max_fail_percentage** - позволяет указать процент ошибок среды выполненных
**tasks**, в рамках текущего **batch**, при котором можно продолжить **play**
* **order** - позволяет указать порядок сортировки хостов из **inventory**
* **run_once** - запустить данный play только на первом хосте из inventory в рамках
одного **batch**
* **serial** - позволяет определить количество хостов, на которых запускается данный
**play** в рамках одного **batch**

Чаще всего, **play** будет выглядеть следующим образом:
```yamlex
---
  - name: Try run Vector # Произвольное название
    play hosts: all # Перечисление хостов
    tasks: # Объявление списка tasks
      - name: Get Vector version # Произвольное имя для task
        ansible.builtin.command: vector --version # Что и как необходимо сделать
        register: is_installed # Запись результата в переменную is_installed
      - name: Get RPM # Произвольное имя для второй task
        ansible.builtin.get_url: # Объявление использования module get_url, ниже указание его параметров
          url: "https://package.timber.io/vector/{{ vector_version }}/vector.rpm"
          dest: "{{ ansible_user_dir }}/vector.rpm"
          mode: 0755
        when: # Условия при которых task будет выполняться
          - is_installed is failed
          - ansible_distribution == "CentOS"         
```

При этом, для жизнеобеспечения **play** достаточно указать **hosts** и хотя бы один **task**:
```yamlex
---
  - hosts: all # Перечисление хостов
    tasks: # Объявление списка tasks
      - name: Get Vector version # Произвольное имя для task
        ansible.builtin.command: vector --version # Что и как необходимо сделать
```

### 8.2.3. Task
**Tasks** нужны для **указания** действий, которые необходимо
воспроизвести на хосте или на указанной в **play** группе хостов.
* **Task** - одно атомарное **действие**
* Можно сохранить результат выполнения в **переменную**
* Директива **when** помогает указать при каких условиях
необходимо выполнить **task**
* Директива **notify** позволяет обратиться к **handlers**, чтобы он был
исполнен в конце выполнения всех **tasks**
```yamlex
tasks: # Объявление списка tasks
  - name: Get Vector version # Произвольное имя для task
    ansible.builtin.command: vector --version # Что и как необходимо сделать
    register: is_installed # Запись результата в переменную is_installed
    notify:
      - Restart Vector # Вызов handler Restart Vector
  - name: Get RPM # Произвольное имя для второй task
    ansible.builtin.get_url: # Объявление использования module get_url, ниже указание его параметров
      url: "https://package.timber.io/vector/{{ vector_version }}/vector.rpm"
    when: # Условия при которых task будет выполняться
      - is_installed is failed
```

**Tasks** можно принудительно воспроизвести на указанном хосте:
* Для того, чтобы определить на каком хосте необходимо выполнить **task** - нужно использовать **delegate_to**
* Если действие необходимо делать на **localhost**, можно использовать инструкцию **local_action**
```yamlex
tasks: # Объявление списка tasks
  - name: Take out of balance # Произвольное имя для task
    ansible.builtin.command: "/usr/bin/pool/take_out {{ inventory_hostname }}" # Что и как необходимо сделать
    delegate_to: 127.0.0.1
  - name: Install Latest NGINX # Произвольное имя для второй task
    ansible.builtin.yum:
      name: nginx
      state: latest
```

```yamlex
tasks: # Объявление списка tasks
  - name: Take out of balance # Произвольное имя для task
    local_action:
      ansible.builtin.command:
        cmd: "/usr/bin/pool/take_out {{ inventory_hostname }}" # Что и как необходимо сделать
  - name: Install Latest NGINX # Произвольное имя для второй task
    ansible.builtin.yum:
      name: nginx
      state: latest
```

**Tasks** можно и нужно разделять на **pre_tasks**, **tasks** и **post_tasks**:
* Разделение группируется по вашей собственной внутренней логике
* Если **task** внутри этих групп вызвала **handler**, то он выполнится после того, как закончит исполнение последней 
**task** из текущей группы
* Внутри набора **tasks** их можно также группировать при помощи **group**
```yamlex
tasks: # Объявление списка tasks
  - name: Get Vector version # Произвольное имя для task
    ansible.builtin.command: vector --version # Что и как необходимо сделать
    register: is_installed # Запись результата в переменную is_installed
    notify:
      - Restart Vector # Вызов handler Restart Vector
  - name: Get RPM # Произвольное имя для второй task
    ansible.builtin.get_url: # Объявление использования module get_url, ниже указание его параметров
      url: "https://package.timber.io/vector/{{ vector_version }}/vector.rpm"
    when: # Условия при которых task будет выполняться
      - is_installed is failed
```

### 8.2.4. Handler
**Handlers** используются для проведения одного действия в рамках одного **play**, например, для рестарта сервиса, 
после обновления конфигурации
* **Указывается** в директиве **Play**
* На **handler** могут ссылаться **task**, **role**, **pre_task**, **post_task**
* Вне зависимости от того, сколько раз **handler** был вызван - он исполнится один раз
* Если **handler** вызван в **role** - он исполнится после всех roles
* Если **handler** вызван в **tasks** любого вида - он исполнится в конце **tasks**, в рамках которого был вызван
* **Handler**, который определён в рамках одного **playbook** может быть вызван в любом **play**

Пример синтаксиса Handlers:
```yamlex
handlers: # Объявление списка handlers
  - name: restart-vector # Произвольное имя для handler
    ansible.builtin.service: # Вызов module, обрабатывающего операции с сервисами
      name: vector # Имя сервиса
      state: restarted # Ожидаемый результат работы модуля
    listen: "restart monitoring" # Группировка handlers для возможности вызова группы
  - name: restart-memcached
    ansible.builtin.service:
      name: memcached
      state: restarted
    listen: "restart monitoring"
```

### 8.2.5. Role
В рамках использования role в playbook нам достаточно знать несколько пунктов:
* **Role** можно скачивать через **ansible-galaxy**
* Какие **role** скачивать - лучше указать в **requirements.yml**
* Чтобы использовать **role** в **playbook** - необходимо использовать следующий синтаксис:
```yamlex
roles: # Объявление списка roles
  - vector
  - java
```

### 8.2.6. Tag
**Tag** позволяет пометить какую-либо сущность **ansible** для отдельного исполнения. Их можно выставлять для:
* Отдельной task
* Группы tasks
* Include
* Play
* Role
* Import

Синтаксис Tag достаточно прост:
```yamlex
tasks: # Объявление списка tasks
  - name: Get Vector version # Произвольное имя для task
    ansible.builtin.command: vector --version # Что и как необходимо сделать
    register: is_installed # Запись результата в переменную is_installed
    notify:
      - Restart Vector # Вызов handler Restart Vector
  - name: Get RPM # Произвольное имя для второй task
    ansible.builtin.get_url: # Объявление использования module get_url, ниже указание его параметров
      url: "https://package.timber.io/vector/{{ vector_version }}/vector.rpm"
    when: # Условия при которых task будет выполняться
      - is_installed is failed
    tags:
      - install 
```

Существует два выделенных **tags**:
* **always** - выполняется всегда, если явно не указано пропустить
* **never** - не выполняется никогда, если явно не указано запустить

Список ключей для использования **tags**:
* --tags all
* --tags tagged
* --tags untagged
* --tags [tag1, tag2]
* --skip-tags [tag1, tag2]
* --list-tags
* --list-tasks (with --tags or --skip-tags)

### 8.2.7. Как написать Playbook?
Изначально, нужно ответить на два вопроса:
* Для чего нам нужен **playbook**?
* На какие подзадачи можно разделить цель?

Далее, нужно работать над содержанием **playbook**:
* Приготовить структуру директорий
* Приготовить стартовые файлы
* Организовать **inventory** для тестовых прогонов
* Описать структуру **plays** и **tasks** внутри
* При необходимости - параметризировать все tasks при помощи **vars**

### 8.2.8. Как запускать Playbook?
* Первый запуск стоит осуществлять или на тестовом окружении или с флагом: 
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --check`
* Если были найдены ошибки: 
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --start-at-task <task_name>`
* Для запуска исполнения в полуинтерактивном виде:
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --step`
* Полноценный запуск playbook в целевом виде должен выглядеть: 
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml`'

### 8.2.9. Как тестировать Playbook?
* В первую очередь, нужно использовать **debugger**
* Необходимо использовать возможности **check**
* Организовать запуск на тестовом окружении
* Нужно не забывать про идемпотентность и использовать флаг:
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --diff`
* Тестировать **playbook** против разного окружения на **control node**
* Тестировать **playbook** против разного окружения на **managed node**
* Активно использовать флаг **-vvv**

Чтобы использовать debugger, об этом необходимо объявить:
* через ключевое слово **debugger**
* через переменную окружения (ANSIBLE_STRATEGY)
* указать **debug** как стратегию (deprecated)
