# Дипломный практикум в YandexCloud
## Чеклист выполненых задач:
- [X] регистрация доманного имени
- [X] Создать инфраструктуру в YC
  - [Инструкция яндекса по созданию хранилища состояний](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-state-storage?ncrnd=640942&status=ok)
  - Подгатавливаем виртуальную машину c Terraform и YC для работы (./vagrant/Vagrantfile).
  - Инициализируем yc `yc init`
  - Генерируем ssh ключ `ssh-keygen -t rsa -b 2048`
  - Добавляем зеркало провайдера в ~/.terraformrc
```shell
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```
  - [X] Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой 
с необходимыми и достаточными правами. Не стоит использовать права суперпользователя. Порядок выполнения:
    - Создаем сервис-аккаунт `yc iam service-account create --name tf-sa --description "service account for Terraform"`
    - Выдаем права на сервис-аккаунт `yc resource-manager folder add-access-binding default --role editor --subject serviceAccount:<sa_id>`
    - Генерируем ключ для сервис-аккаунта `yc iam access-key create --service-account-name tf-sa`   
    - сервисный аккаунт для bucket создается средствами Terraform
  - [X] Подготовьте backend для Terraform:  S3 bucket в созданном YC аккаунте. Порядок выполнения:
    - [Инструкция по созданию s3 bucket в yc](https://cloud.yandex.ru/docs/storage/operations/buckets/create)
    - создаем [tf файл для бакета](./terraform/bucket/main.tf)
  - [X] Настройте workspaces создайте два workspace: stage и prod. В случае выбора этого варианта все последующие шаги 
должны учитывать факт существования нескольких workspace, не используйте workspace, создаваемый Terraform-ом 
по-умолчанию (default).
    - **в целях экономии денег данные действия надо будет выполнять каждый раз после пересоздавания бакета!** 
    - Подготоавливаем [provider.tf файл для работы с бэкэндом](./terraform/bucket/provider.tf)
    - берем ключи сервис акаунта из [terraform.tfstate](./terraform/bucket/terraform.tfstate) и вставляем в backend.conf
    - инициализируем TF с файлом конфига бэкэнда `terraform init --backend-config=backend.conf`
    - создаем воркспейс `terraform workspace new stage`
    - создаем воркспейс `terraform workspace new prod`
  - [X] Создайте VPC с подсетями в разных зонах доступности.
    - Создадим 2 тестовые виртуальные машины в зависимости от выбранного workspace [main.tf](./terraform/main.tf)
```terraform
resource "yandex_compute_instance" "nginx" {
  count = local.instance_count[terraform.workspace]
  boot_disk {
    initialize_params {
      image_id = "fd80d7fnvf399b1c207j"
    }
  }
  network_interface {
    subnet_id = "e9bk73fbfmdaiuimu8bf"
    nat       = true
    nat_ip_address = local.public_ip[terraform.workspace]
  }
  resources {
    cores  = 2
    memory = 2
  }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

locals {
  instance_count = {
    stage = "1"
    prod = "1"
  }
  public_ip = {
    stage = "62.84.116.251"
    prod = "62.84.116.237"
  }
}
```
  - [X] Убедитесь, что теперь вы можете выполнить команды terraform destroy и terraform apply без дополнительных ручных 
действий.
  - [X] Зарезервировать статический IP адрес по [инструкции](https://cloud.yandex.ru/docs/vpc/operations/get-static-ip)
  - [X] Установка Nginx и LetsEncrypt
    - [X] Необходимо разработать Ansible роль для установки Nginx.
    - [X] Необходимо разработать Ansible роль для установки LetsEncrypt.
    - [X] Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.
    - [X] В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - [X] https://www.you.domain (WordPress)
    - [X] https://gitlab.you.domain (Gitlab)
    - [X] https://grafana.you.domain (Grafana)
    - [X] https://prometheus.you.domain (Prometheus)
    - [X] https://alertmanager.you.domain (Alert Manager)
    - [X] Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их 
отредактируете и укажите верные значения. В браузере можно открыть любой из этих URL и увидеть ответ сервера 
(502 Bad Gateway). На текущем этапе выполнение задания это нормально!
  - [X] Установка кластера MySQL
    - [X] Необходимо разработать Ansible роль для установки кластера MySQL. Имена серверов: db01.you.domain 
и db02.you.domain Характеристики: 4vCPU, 4 RAM, Internal address.
В качестве роли выбрана готовая роль из ansible galaxy [geerlingguy.mysql](https://galaxy.ansible.com/geerlingguy/mysql),
но в ней почему-то не работала настройка репликации, пришлось переделать 
[replication.yml](ansible/geerlingguy.mysql/tasks/replication.yml) так как там не правильно указана переменная 
`slave.Is_Slave` заменид на `slave.Is_Replica`, все заработало. 
    - [X] MySQL работает в режиме репликации Master/Slave.
    - [X] В кластере автоматически создаётся база данных c именем wordpress.
    - [X] В кластере автоматически создаётся пользователь wordpress с полными правами на базу wordpress и паролем 
wordpress.
  - [X] Установка WordPress
    - [X] Необходимо разработать Ansible роль для установки WordPress. Имя сервера: **app.you.domain** Характеристики: 
4vCPU, 4 RAM, Internal address.
    - [X] Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение)
    - [X] В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy: https://www.you.domain (WordPress)
    - [X] На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на 
которой установлен WordPress.
    - [X] В браузере можно открыть URL https://www.you.domain и увидеть главную страницу WordPress.
  - [X] Установка Gitlab CE и Gitlab Runner 
    - [X] Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода. Имена 
серверов: gitlab.you.domain и runner.you.domain Характеристики: 4vCPU, 4 RAM, Internal address.
    - [X] Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер 
app.you.domain при коммите в репозиторий с WordPress.

    - [X] Интерфейс Gitlab доступен по https.
    - [X] В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy: https://gitlab.you.domain (Gitlab)
    - [X] На сервере you.domain отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину 
на которой установлен Gitlab.
    - [X] При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой 
на виртуальную машину.
```yaml
before_script:
  - 'which ssh-agent || ( apt-get update -y && apt-get install openssh-client -y )'
  - eval $(ssh-agent -s)
  - echo "$ssh_key" | tr -d '\r' | ssh-add -
  - mkdir -p ~/.ssh
  - chmod 700 ~/.ssh
  - ssh-keyscan app.literis.ru >> ~/.ssh/known_hosts
  - chmod 644 ~/.ssh/known_hosts


stages:
  - deploy

deploy-job:
  stage: deploy
  only:
    - tags
  script:
    - ssh -o StrictHostKeyChecking=no ubuntu@app.literis.ru sudo chown ubuntu /var/www/wordpress/ -R
    - rsync -vz -e "ssh -o StrictHostKeyChecking=no" ./* ubuntu@app.literis.ru:/var/www/wordpress/
    - ssh -o StrictHostKeyChecking=no ubuntu@app.literis.ru sudo chown www-data:www-data /var/www/wordpress/ -R
```
    - [X] Получена резервная копия
```shell
cp -r /var/www/wordpress/ ~/wordperess
cd ~/wordpress
git init 
```
    - [X] Создана роль для развертывания резервной копии гитлаб.
  - [X] Установка Prometheus, Alert Manager, Node Exporter и Grafana
    - [X] Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana. Имя сервера: 
monitoring.you.domain Характеристики: 4vCPU, 4 RAM, Internal address.
    - [X] Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
    - [X] В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
https://grafana.you.domain (Grafana)
https://prometheus.you.domain (Prometheus)
https://alertmanager.you.domain (Alert Manager)
    - [X] На сервере you.domain отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину 
на которой установлены Prometheus, Alert Manager и Grafana.
    - [X] На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
    - [X] У Alert Manager есть необходимый набор правил для создания алертов.
    - [X] В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
    - [X] В Grafana есть дашборд отображающий метрики из MySQL (*).
    - [X] В Grafana есть дашборд отображающий метрики из WordPress (*).
- [X] необходимо для сдачи задания
  - [X] Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
  - [X] Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
  - [X] Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени. https://www.you.domain (WordPress)
https://gitlab.you.domain (Gitlab)
https://grafana.you.domain (Grafana)
https://prometheus.you.domain (Prometheus)
https://alertmanager.you.domain (Alert Manager)
  - [X] Все репозитории рекомендуется хранить на одном из ресурсов (github.com или gitlab.com).






---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Подойдет любое доменное имя на ваш выбор в любой доменной зоне.

ПРИМЕЧАНИЕ: Далее в качестве примера используется домен `you.domain` замените его вашим доменом.

Рекомендуемые регистраторы:
  - [nic.ru](https://nic.ru)
  - [reg.ru](https://reg.ru)

Цель:

1. Получить возможность выписывать [TLS сертификаты](https://letsencrypt.org) для веб-сервера.

Ожидаемые результаты:

1. У вас есть доступ к личному кабинету на сайте регистратора.
2. Вы зарезистрировали домен и можете им управлять (редактировать dns записи в рамках этого домена).

### Создание инфраструктуры

Для начала необходимо подготовить инфраструктуру в YC при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
- Следует использовать последнюю стабильную версию [Terraform](https://www.terraform.io/).

Предварительная подготовка:

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:
   а. Рекомендуемый вариант: [Terraform Cloud](https://app.terraform.io/)  
   б. Альтернативный вариант: S3 bucket в созданном YC аккаунте.
3. Настройте [workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
   а. Рекомендуемый вариант: создайте два workspace: *stage* и *prod*. В случае выбора этого варианта все последующие шаги должны учитывать факт существования нескольких workspace.  
   б. Альтернативный вариант: используйте один workspace, назвав его *stage*. Пожалуйста, не используйте workspace, создаваемый Terraform-ом по-умолчанию (*default*).
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Цель:

1. Повсеместно применять IaaC подход при организации (эксплуатации) инфраструктуры.
2. Иметь возможность быстро создавать (а также удалять) виртуальные машины и сети. С целью экономии денег на вашем аккаунте в YandexCloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Установка Nginx и LetsEncrypt

Необходимо разработать Ansible роль для установки Nginx и LetsEncrypt.

**Для получения LetsEncrypt сертификатов во время тестов своего кода пользуйтесь [тестовыми сертификатами](https://letsencrypt.org/docs/staging-environment/), так как количество запросов к боевым серверам LetsEncrypt [лимитировано](https://letsencrypt.org/docs/rate-limits/).**

Рекомендации:
  - Имя сервера: `you.domain`
  - Характеристики: 2vCPU, 2 RAM, External address (Public) и Internal address.

Цель:

1. Создать reverse proxy с поддержкой TLS для обеспечения безопасного доступа к веб-сервисам по HTTPS.

Ожидаемые результаты:

1. В вашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.you.domain` (WordPress)
    - `https://gitlab.you.domain` (Gitlab)
    - `https://grafana.you.domain` (Grafana)
    - `https://prometheus.you.domain` (Prometheus)
    - `https://alertmanager.you.domain` (Alert Manager)
2. Настроены все upstream для выше указанных URL, куда они сейчас ведут на этом шаге не важно, позже вы их отредактируете и укажите верные значения.
2. В браузере можно открыть любой из этих URL и увидеть ответ сервера (502 Bad Gateway). На текущем этапе выполнение задания это нормально!

___
### Установка кластера MySQL

Необходимо разработать Ansible роль для установки кластера MySQL.

Рекомендации:
  - Имена серверов: `db01.you.domain` и `db02.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получить отказоустойчивый кластер баз данных MySQL.

Ожидаемые результаты:

1. MySQL работает в режиме репликации Master/Slave.
2. В кластере автоматически создаётся база данных c именем `wordpress`.
3. В кластере автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.

**Вы должны понимать, что в рамках обучения это допустимые значения, но в боевой среде использование подобных значений не приемлимо! Считается хорошей практикой использовать логины и пароли повышенного уровня сложности. В которых будут содержаться буквы верхнего и нижнего регистров, цифры, а также специальные символы!**

___
### Установка WordPress

Необходимо разработать Ansible роль для установки WordPress.

Рекомендации:
  - Имя сервера: `app.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Установить [WordPress](https://wordpress.org/download/). Это система управления содержимым сайта ([CMS](https://ru.wikipedia.org/wiki/Система_управления_содержимым)) с открытым исходным кодом.


По данным W3techs, WordPress используют 64,7% всех веб-сайтов, которые сделаны на CMS. Это 41,1% всех существующих в мире сайтов. Эту платформу для своих блогов используют The New York Times и Forbes. Такую популярность WordPress получил за удобство интерфейса и большие возможности.

Ожидаемые результаты:

1. Виртуальная машина на которой установлен WordPress и Nginx/Apache (на ваше усмотрение).
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://www.you.domain` (WordPress)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен WordPress.
4. В браузере можно открыть URL `https://www.you.domain` и увидеть главную страницу WordPress.
---
### Установка Gitlab CE и Gitlab Runner

Необходимо настроить CI/CD систему для автоматического развертывания приложения при изменении кода.

Рекомендации:
  - Имена серверов: `gitlab.you.domain` и `runner.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:
1. Построить pipeline доставки кода в среду эксплуатации, то есть настроить автоматический деплой на сервер `app.you.domain` при коммите в репозиторий с WordPress.

Подробнее об [Gitlab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/)

Ожидаемый результат:

1. Интерфейс Gitlab доступен по https.
2. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy:
    - `https://gitlab.you.domain` (Gitlab)
3. На сервере `you.domain` отредактирован upstream для выше указанного URL и он смотрит на виртуальную машину на которой установлен Gitlab.
3. При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Необходимо разработать Ansible роль для установки Prometheus, Alert Manager и Grafana.

Рекомендации:
  - Имя сервера: `monitoring.you.domain`
  - Характеристики: 4vCPU, 4 RAM, Internal address.

Цель:

1. Получение метрик со всей инфраструктуры.

Ожидаемые результаты:

1. Интерфейсы Prometheus, Alert Manager и Grafana доступены по https.
2. В вашей доменной зоне настроены A-записи на внешний адрес reverse proxy:
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
3. На сервере `you.domain` отредактированы upstreams для выше указанных URL и они смотрят на виртуальную машину на которой установлены Prometheus, Alert Manager и Grafana.
4. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.
5. У Alert Manager есть необходимый [набор правил](https://awesome-prometheus-alerts.grep.to/rules.html) для создания алертов.
2. В Grafana есть дашборд отображающий метрики из Node Exporter по всем серверам.
3. В Grafana есть дашборд отображающий метрики из MySQL (*).
4. В Grafana есть дашборд отображающий метрики из WordPress (*).

*Примечание: дашборды со звёздочкой являются опциональными заданиями повышенной сложности их выполнение желательно, но не обязательно.*

---
## Что необходимо для сдачи задания?

1. Репозиторий со всеми Terraform манифестами и готовность продемонстрировать создание всех ресурсов с нуля.
2. Репозиторий со всеми Ansible ролями и готовность продемонстрировать установку всех сервисов с нуля.
3. Скриншоты веб-интерфейсов всех сервисов работающих по HTTPS на вашем доменном имени.
  - `https://www.you.domain` (WordPress)
  - `https://gitlab.you.domain` (Gitlab)
  - `https://grafana.you.domain` (Grafana)
  - `https://prometheus.you.domain` (Prometheus)
  - `https://alertmanager.you.domain` (Alert Manager)
4. Все репозитории рекомендуется хранить на одном из ресурсов ([github.com](https://github.com) или [gitlab.com](https://gitlab.com)).

---
## Как правильно задавать вопросы дипломному руководителю?

**Что поможет решить большинство частых проблем:**

1. Попробовать найти ответ сначала самостоятельно в интернете или в
  материалах курса и ДЗ и только после этого спрашивать у дипломного
  руководителя. Навык поиска ответов пригодится вам в профессиональной
  деятельности.
2. Если вопросов больше одного, то присылайте их в виде нумерованного
  списка. Так дипломному руководителю будет проще отвечать на каждый из
  них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой
  покажите, где не получается.

**Что может стать источником проблем:**

1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения курсового проекта на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители работающие разработчики, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)
