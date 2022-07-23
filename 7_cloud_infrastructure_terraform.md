# 7.Облачная инфраструктура. Terraform.

## 7.1 Инфраструктура как код.

### 7.1.1. IaC в контексте DevOps
**До эры DevOps:**

![До DevOps](img/7_iac/iac_1_1_1.PNG)

**Появление DevOps:**

![C DevOps](img/7_iac/iac_1_1_2.PNG)

DevOps - не название команды, должности или какой-то определенной технологии. Это набор процессов, идей и методик. 
Каждый понимает под DevOps что-то свое, но для этого раздела:

Цель DevOps: **значительно повысить эффективность доставки ПО.**

### 7.1.2. Инфраструктура как код (IaC)
Идея, стоящая за IaC (infrastructure as code), заключается в том, что для определения, развертывания, обновления 
и удаления инфраструктуры нужно писать и выполнять код.

#### Специализированные скрипты
Самый простой и понятный способ что-либо автоматизировать — написать для этого специальный скрипт.
```shell
#!/bin/bash
# Обновляем кэш apt-get sudo apt-get update
apt-get update
# Устанавливаем PHP и Apache
apt-get install -y php apache2
# Копируем код из репозитория
git clone https://github.com/your_account/php-app.git /var/www/html/app
# Запускаем Apache
service apache2 start
```
#### Средства управления конфигурацией
Chef, Puppet, Ansible и SaltStack являются средствам управления конфигурацией. Это означает, что они предназначены 
для установки и администрирования программного обеспечения на существующих серверах.

Тот же скрипт на Ansible:
```yamlex
- name: Update the apt-get cache
    apt:
        update_cache: yes
- name: Install PHP
    apt:
        name: php
- name: Install Apache
    apt:
        name: apache2
- name: Copy the code from the repository
    git: repo=https://github.com/your_account/php-app.git dest=/var/www/html/app
- name: Start Apache
    service: name=apache2 state=started enabled=yes
```

#### Ansible vs bash скрипт
Преимущества:
* Стандартизированное оформление кода.
* Идемпотентность (свойство объекта или операции при повторном применении операции к объекту давать тот же результат, 
что и при первом).
* Распределенность.

![Ansible](img/7_iac/iac_1_2_1.PNG)

#### Средства шаблонизации серверов
Docker, Packer и Vagrant. Вместо того чтобы вводить кучу серверов и настраивать их, запуская на каждом один и тот же 
код, средства шаблонизации создают образ сервера, содержащий полностью самодостаточный «снимок» операционной системы 
(ОС), программного обеспечения, файлов и любых других важных деталей.

Конфиг packer:
```json
{
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "apt-get update",
        "apt-get install -y php",
        "apt-get install -y apache2"
      ]
    }
  ]
}
```
![packer](img/7_iac/iac_1_2_2.PNG)

#### Средства для работы с образами
* Виртуальные машины: эмулируют весь компьютер включая аппаратное обеспечение.
  * Для виртуализации оборудования запускается гипервизор.
  * Любой образ ВМ видит только виртуальное оборудование, поэтому он полностью изолирован от физического компьютера 
и других ВМ.
  * Много накладных расходов на виртуализацию.
  * Образы можно описывать при помощи кода, например, используя Packer и Vagrant. 
* **Контейнеры**: эмулируют пользовательское пространства ОС.
  * Для изоляции процессов, памяти, точек монтирования и сети запускается **среда выполнения контейнеров**, такая как
**Docker, CoreOs rkt** или **cri-o**.
  * Каждый контейнер может видеть только собственное пользовательское пространство.
  * Все контейнеры запущенные на одном сервере одновременно пользуются оборудованием основной ОС.
  * Контейнеры запускаются очень быстро.
  * Образы можно описывать при помощи кода, используя **Docker** и **CoreOs rkt**.

#### Неизменяемая инфраструктура
**Шаблонизация серверов** — это ключевой аспект перехода на неизменяемую инфраструктуру. Если сервер уже развернут, 
в него больше не вносятся никакие изменения. Если нужно что-то обновить (например, развернуть новую версию кода), вы 
создаете новый образ из своего шаблона и разворачиваете его на новый сервер.

#### Средства оркестрации
Нужно выбрать какой-то способ выполнения таких действий:
* Развертывать ВМ и контейнеры с целью эффективного использования оборудования.
* Выкатка обновлений.
* Автовосстановление.
* Автомасштабирование.
* Балансировка нагрузки.
* Обнаружение сервисов.

Выполнение этих задач находится в сфере ответственности средств оркестрации, таких как **Kubernetes, Marathon/Mesos, 
Amazon Elastic Container Service (Amazon ECS), Docker Swarm, Nomad** и др.

И это все описывается тоже в виде кода!

#### Средства инициализации ресурсов
Средства инициализации ресурсов, такие как **Terraform**, **CloudFormation** и **OpenStack** **Heat**, отвечают
за создание самих серверов.

Тот же самый сервер при помощи terraform:
```terraform
resource "aws_instance" "app" {
instance_type = "t2.micro"
 availability_zone = "us-east-2a"
ami = "ami-0c55b159cbfafe1f0"
user_data = <<-EOF
#!/bin/bash
sudo service apache2 start
EOF
}
```
![Terraform](img/7_iac/iac_1_2_3.PNG)

#### Преимущества инфраструктуры в виде кода
* **Самообслуживание:** тайные знания не сосредоточены только в голове админа.
* **Скорость и безопасность:** исключается человеческих фактор при развертывании очередного сервера.
* **Документация:** код IaC сам по себе хорошая документация.
* **Управление версиями:** код хранится в vcs.
* **Проверка:** тесты и код ревью.
* **Повторное использование:** переиспользование готовых модулей.
* **Радость:** больше нет рутинных действий.

### 7.1.3. Выбор инструментов
**Надо выбрать из:**
* Управление конфигурацией или инициализация ресурсов.
* Изменяемая или неизменяемая инфраструктура.
* Процедурный или декларативный язык.
* Наличие или отсутствие центрального сервера.
* Наличие или отсутствие агента.

#### Управление конфигурацией или инициализация ресурсов?
* **Chef**, **Puppet**, **Ansible** и **SaltStack** управляют конфигурацией.
* **CloudFormation**, **Terraform** и **OpenStack Heat** инициализируют ресурсы.

Это не совсем четкое разделение, так как средства управления конфигурацией обычно в какой-то степени поддерживают 
инициализацию ресурсов, а средства инициализации ресурсов занимаются какого-то рода конфигурацией. Поэтому следует
выбирать тот инструмент, который лучше всего подходит для вашего случая.

#### Изменяемая и неизменяемая архитектура?
* **Изменяемая**
  * проблема дрейфа конфигурации,
  * неочевидные расхождения между тестовыми прогонами и продакшеном,
  * например обновление библиотеки OpenSSL приведет к отдельному ее обновлению на каждом отдельном сервере.
* **Неизменяемая**
  * дает уверенность идентичности всех серверов (тоже есть нюансы),
  * обновление OpenSSL – это создание нового образа,
  * но даже минимальное изменение ведет к пересборке образов.

#### Процедурный или декларативный подход?
* **Процедурный**
  * Chef и Ansible
  * код пошагово описывает как достичь желаемого результата
```yamlex
- ec2:
  count: 10
  image: ami-0c55b159cbfafe1f0
  instance_type: t2.micro
```
* **Декларативный**
  * Terraform, CloudFormation, SaltStack, Puppet и Open Stack Heat
  * в коде описывается нужное вам конечное состояние, а средства IaC сами разбираются с тем, как его достичь.
```terraform
resource "aws_instance" "example" {
 count = 10
 ami = "ami-0c55b159cbfafe1f0"
 instance_type = "t2.micro"
}
```
**Основные проблемы процедурного подхода:**
* Процедурный код не полностью охватывает состояние инфраструктуры.
* Процедурный код ограничивает повторное использование.

**Основные особенности декларативного подхода:**
* Отсутствие доступа к полноценному языку программирования.
* Процедурный код ограничивает повторное использование.

#### Наличие или отсутствие центрального сервера
* Chef, Puppet и SaltStack по умолчанию требуют наличия центрального (master) сервера для хранения состояния вашей 
инфраструктуры и распространения обновлений.
* У Ansible, CloudFormation, Heat и Terraform по умолчанию нет центрального сервера. 

(но всегда есть нюансы)

**Преимущества центрального сервера:**
* Это единое централизованное место, где вы можете просматривать и администрировать состояние своей инфраструктуры.
* Некоторые центральные серверы умеют работать непрерывно, в фоновом режиме, обеспечивая соблюдение вашей конфигурации.

**Особенности центрального сервера:**
* **Дополнительная инфраструктура.** Вам нужно развернуть дополнительный сервер или даже кластер дополнительных серверов 
(для высокой доступности и масштабируемости).
* **Обслуживание**. Центральный сервер нуждается в обслуживании, обновлении, резервном копировании, мониторинге 
и масштабировании.
* **Безопасность**. Вам нужно сделать так, чтобы клиент мог общаться с центральным сервером, а последний — со всеми 
остальными серверами Это обычно требует открытия дополнительных портов и настройки дополнительных систем аутентификации,
что увеличивает область потенциальных атак.

#### Наличие или отсутствие агентов
* Chef, Puppet и SaltStack требуют установки своих агентов на каждый сервер, который вы хотите настраивать. Агент обычно
работает в фоне и отвечает за установку последних обновлений конфигурации.
* Ansible, CloudFormation, Heat и Terraform не требуют установки никаких дополнительных агентов.

(но всегда есть нюансы)

**На самом деле не все однозначно**

![agents](img/7_iac/iac_1_3_1.PNG)

### 7.1.4. Совместное использование инструментов
**Инициация ресурсов + управление конфигурацией**

![Инициация ресурсов + управление конфигурацией](img/7_iac/iac_1_4_1.PNG)

**Инициация ресурсов + шаблонизация серверов**

![Инициация ресурсов + шаблонизация серверов](img/7_iac/iac_1_4_2.PNG)

**Инициация ресурсов + шаблонизация + оркестрация**

![Инициация ресурсов + шаблонизация + оркестрация](img/7_iac/iac_1_4_3.PNG)

### 7.1.5. Резюме
**При использовании "стандартных" способов применения**

| Инструмент      | Открытый код | Облака | Тип        | Инф-ка   | Язык          | Агент | Вед.сервер | Сообщество |
|-----------------|--------------|--------|------------|----------|---------------|-------|------------|------------|
| Chef            | +            | Все    | Упр.конф.  | Изм-ая   | Процедурный   | +     | +          | Большое    |
| Puppet          | +            | Все    | Упр.конф.  | Изм-ая   | Декларативный | +     | +          | Большое    |
| Ansible         | +            | Все    | Упр.конф.  | Изм-ая   | Процедурный   | -     | -          | Огромное   |
| SaltStack       | +            | Все    | Упр.конф.  | Изм-ая   | Декларативный | +     | +          | Большое    |
| Cloud Formation | -            | AWS    | Иниц. рес. | Неизм-ая | Декларативный | -     | -          | Маленькое  |
| Heat            | +            | Все    | Иниц. рес. | Неизм-ая | Декларативный | -     | -          | Маленькое  |
| Terraform       | +            | Все    | Иниц. рес. | Неизм-ая | Декларативный | -     | -          | Огромное   |

### 7.1.6. Terraform
Терраформ это инструмент с открытым исходным кодом от компании HashiCorp, написанный на языке программирования Go.

Терраформ делает от вашего имени API-вызовы к одному или нескольким провайдерам, таким как AWS, Azure, Google Cloud, 
DigitalOcean, OpenStack и множеству других.

Этот позволяет развернуть инфраструктуру прямо с вашего ноутбука или либо любого другого компьютера, и для всего этого 
не требуется никакой дополнительной инфраструктуры.

#### Установка Terraform
* Скачать с [terraform.io](https://www.terraform.io/)
* Воспользоваться менеджером пакетов (apt, brew, ...)

## 7.2 Облачные провайдеры и синтаксис Терраформ

### 7.2.1. Облачные провайдеры
#### AWS (Amazon Web Service)
* Популярное решение на зарубежном рынке
* Очень большое количество сервисов
* В первый год использования есть бесплатный тариф: <https://aws.amazon.com/free/>

#### Yandex.Cloud
* Популярное решение в русскоязычном сегменте
* Документация на русском языке
* Достаточное количество сервисов

#### Регистрация в AWS
* Кредитная карта нужна только для регистрации
* Пользуемся бесплатным тарифом, который доступен год после регистрации
* Можно зарегистрировать отдельный «учебный» аккаунт на email типа «yourname+netology@gmail.com»

#### Регистрация в Yandex.Cloud
* Есть бесплатный пробный период
* Далее каждому студенту будут выданы промокоды

#### Элементы управления AWS
![Элементы управления](img/7_iac/iac_2_1_1.PNG)

#### Элементы управления Яндекс.Cloud
![Элементы управления](img/7_iac/iac_2_1_2.PNG)

#### Регионы и зоны доступности AWS
AWS охватывает 77 зон доступности в 24 географических регионах по всему миру.

![регионы](img/7_iac/iac_2_1_3.PNG)

#### Установка cli клиентов
* При помощи менеджера пакетов apt, brew, ...
* AWS: Скачать исходники <https://aws.amazon.com/cli/>
* Yandex: <https://cloud.yandex.ru/docs/cli/quickstart>

#### VPC (Virtual Private Cloud)
Это логически изолированный раздел облака, в котором можно запускать ресурсы в самостоятельно заданной виртуальной сети.
Таким образом можно полностью контролировать среду виртуальной сети, в том числе выбирать собственный диапазон 
IP‑адресов, создавать подсети, а также настраивать таблицы маршрутизации и сетевые шлюзы.

#### Identity and Access Management (IAM)
**IAM** – это место где происходит управление учетными записями пользователей и их правами.
* Создаем отдельного пользователя для дальнейшей работы.
* Нужно получить:
  * Идентификатор ключа доступа: Access Key ID,
  * Секретный ключ доступа: Secret Access Key.

#### Yandex.Cloud IAM для Terraform
Инструкция для получения токена: <https://cloud.yandex.ru/docs/iam/operations/iam-token/create>
[Аутентификация с помощью Google Workspace Yandex.Cloud](https://cloud.yandex.ru/docs/organization/operations/federations/integration-gworkspace)

#### Политика (policy) IAM
**Политика IAM** – это документ в формате JSON, который определяет, что пользователю позволено, а что — нет.

Назначим нашему пользователю:
* AmazonEC2FullAccess
* AmazonS3FullAccess
* AmazonDynamoDBFullAccess
* AmazonRDSFullAccess
* CloudWatchFullAccess
* IAMFullAccess

#### Регистрируем этого пользователя локально. 
Чтобы консольный клиент AWS и Terraform получили доступ к нашему аккаунту создаем переменные окружения:
```shell
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

### 7.2.2. Amazon Elastic Compute Cloud (Amazon EC2)
Это веб‑сервис, предоставляющий безопасные масштабируемые вычислительные ресурсы в облаке.

Позволяет выбрать:
* тип и количество ядер процессора,
* объем оперативной памяти,
* хранилища,
* акселераторы,
* и другое.

#### Создание EC2 через веб интерфейс
<https://us-west-2.console.aws.amazon.com/ec2/v2/home>

![EC2](img/7_iac/iac_2_2_1.PNG)

#### Создание EC2 через консоль
<https://awscli.amazonaws.com/v2/documentation/api/latest/reference/opsworks/create-instance.html>

```shell
aws ec2 create-instance
[--source-dest-check | --no-source-dest-check]
[--attribute <value>] [--block-device-mappings <value>]
[--disable-api-termination | --no-disable-api-termination]
[--dry-run | --no-dry-run] [--ebs-optimized | --no-ebs-optimized]
[--ena-support | --no-ena-support] [--groups <value>]
--instance-id <value> [--instance-initiated-shutdown-behavior <value>]
[--instance-type <value>] [--kernel <value>]
[--ramdisk <value>] [--sriov-net-support <value>] [--user-data <value>]
[--value <value>] [--cli-input-json | --cli-input-yaml]
[--generate-cli-skeleton <value>] [--cli-auto-prompt <value>]
```

#### Основные параметры EC2
Что нужно знать для создания инстанса:
* тип (процессор, память),
* идентификатор виртуального приватного облака,
* способ автоскейлинга,
* операционная система,
* идентификатор образа (ami),
* ключ доступа по ssh,
* зона доступности,
* идентификатор подсети,
* тип подключенных хранилищ,
* … и еще десяток параметров.

#### Изменение инстанса:
* Иногда необходимо предварительно остановить инстанс.
* Иногда пересоздать.
* Хорошо бы понять что конкретно будет изменено.
* Часто надо привести инстанс в исходное состояние после ручных правок.

#### Как это сделать?
* Зайти в веб интерфейс и проверять все параметры?
* Через консоль выполнить:
  * describe,
  * сравнить с целевыми (исходными) значениями,
  * modify.
* Хорошо бы понять что конкретно будет изменено (типа git diff).
* Часто надо привести инстанс в исходное состояние после ручных правок.

Другими словами надо воспользоваться командами
* aws ec2 create-key-pair
* aws ec2 create-instance
* aws ec2 create-tags
* aws ec2 create-volume
* aws ec2 describe-key-pair
* aws ec2 describe-instances
* aws ec2 describe-tags
* aws ec2 describe-volume
* ....

### 7.2.3. Синтаксис Terraform
**Терраформ** - это просто API-клиент. Терраформ-провайдер знает все эти команды и умеет приводить состояние ресурсов 
к указанному в своих конфигурационных файлах. Они могут работать с любым клиентом: cli, http, их комбинациями и другими.

#### Терраформ провайдеры
<https://www.terraform.io/docs/providers/index.html>

В официальном репозитории около 150 штук. Плюс много неофициальных и можно достаточно просто создавать собственные.

#### Блоки
Все конфигурации описываются в виде блоков.
```terraform
resource "aws_vpc" "main" {
  cidr_block = var.base_cidr_block
}
тип "идентификатор" "имя" {
  название_параметра = выражение_значение_параметра
}
```

#### Блок провайдеров
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs>
```terraform
provider "aws" {
  region = "us-east-1"
}
```

#### Блок требований к провайдерам
Блок "terraform" для указаний версий провайдеров и бэкэндов. 
```terraform
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

#### Блок ресурсов
<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance>

Ресурс **aws_instance** – это экземпляр ec2 
```terraform
resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

#### Блок внешних данных
Для того что бы прочитать данные из внешнего API и использовать для создания других ресурсов.

<https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity>
```terraform
data "aws_caller_identity" "current" {}

// data.aws_caller_identity.current.account_id
// data.aws_caller_identity.current.arn
// data.aws_caller_identity.current.user_id
```

#### Блок переменных
Каждый модуль может зависеть от переменных. 
```terraform
variable "image_id" {
  type = string
}
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami = var.image_id
}
```
Структура переменной может быть достаточно сложной.
```terraform
variable "availability_zone_names" {
  type = list(string)
  default = ["us-west-1a"]
}
variable "docker_ports" {
  type = list(object({
    internal = number
    external = number
    protocol = string
  }))
  default = [
    {
    internal = 8300
    external = 8300
    protocol = "tcp"
    }
  ]
}
```

#### Типы переменных
Примитивные типы:
* `string` - строка
* `number` - число
* `bool` - логическое

Комбинированные типы:
* `list(<TYPE>)` - список
* `set(<TYPE>)`
* `map(<TYPE>)`
* `object({<ATTR NAME> = <TYPE>, ... })` - объект (набор параметров "ключ - значение")
* `tuple([<TYPE>, ...])`

#### Валидация переменных
Особенно важно для повторно используемых модулей. 
```terraform
variable "image_id" {
  type = string
  description = "The id of the machine image (AMI) to use for the server."
  validation {
    condition = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-" #Длина переменной должна быть больше 4 и начинатся с "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}
```

#### Блок output
Для того чтобы разные модули могли использовать результат работы друг друга.
```terraform
output "instance_ip_addr" {
  value = aws_instance.server.private_ip
  description = "The private IP address of the main server instance."
  depends_on = [
  # Security group rule должна быть создана перед тем как можно будет использовать этот ip адрес, иначе сервис будет недоступен
  aws_security_group_rule.local_access,
  ]
}
```

#### Локальные переменные
Могут быть использованы внутри модуля сколько угодно раз. 
```terraform
locals {
  service_name = "forum"
  owner = "Community Team"
}
locals {
  instance_ids = concat(
    aws_instance.blue.*.id, aws_instance.green.*.id
  )
  common_tags = {
    Service = local.service_name
    Owner = local.owner
  }
}
```

#### Комментарии
Терраформ поддерживает несколько видов комментариев:
* `#` начинает однострочные комментарии.
* `//` также однострочные комментарии.
* `/*` и `*/` для обозначения многострочных комментариев.

### 7.2.4. Структура проекта
#### Структура каталогов
* /main.tf - главный файл проекта
* /any_file.tf - любые дополнительные файлы, в последствии выполнения объединяются в один.
* /modules/ - дополнительные модули
* /modules/awesome_module/
* /modules/awesome_module/main.tf
* /modules/awesome_module/any_other_file.tf
* /modules/next_module/
* /modules/next_module/main.tf
* /modules/next_module/any_other_file.tf

Модули которые используются в разных проектах рекомендуется хранить в отдельном репозитории, и подключать с помощью
submodule

#### Структура файлов
* main.tf
* variables.tf
* outputs.tf
* any_other_files.tf

## 7.2a Использование Yandex Cloud
### 7.2a.1. Что такое Yandex.Cloud?
**Yandex.Cloud** - облачная платформа от Яндекса, позволяющая поднять нужное количество ресурсов и настроить их 
по своему усмотрению

Иными словами, **Yandex.Cloud** позволяет:
* Создавать шаблонные ресурсы (для БД, registry, DNS и т.д.)
* Создавать простые VM для последующей гибкой настройки на ваше усмотрение
* Создавать инфраструктуру "на лету"
* Платить только за используемое время

Официальная страница [Yandex.Cloud](https://cloud.yandex.ru/)

### 7.2a.2. Способы создания VM
**VM** можно создавать при помощи:
* [web-интерфейс](https://console.cloud.yandex.ru/)
* [yandex cli](https://cloud.yandex.ru/docs/cli/quickstart)
* [terraform](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart)
* [ansible](https://github.com/arenadata/ansible-module-yandex-cloud)

Во всех случаях, кроме использования **ansible-plugin**, для управления хостами через **ansible** необходимо описать их
в **inventory**

### 7.2a.3. Статический Inventory
Вид **inventory**, который мы чаще всего видим, по сути - файл (yaml или ini) в котором перечислены hosts, groups 
и дополнительные параметры.
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

#### Cтруктура директории с Playbook
Основная для общего использования переменных:
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
Альтернативная для индивидуальных переменных для каждого хоста:
```
inventory/
inventory/prod/
inventory/prod/group_vars/
inventory/prod/group_vars/all/
inventory/prod/group_vars/all/some_variable.yml
inventory/prod/group_vars/<group_name>/
inventory/prod/hosts.yml
roles/
roles/<role_fodlers>/
site.yml
requirement.yml
```

### 7.2a.4. Динамический Inventory
Так как **ansible**, в момент исполнения содержит все данные в **json** формате, а **inventory** для него это всегда
перечисление **hosts** в **groups** с их возможными параметрами:
* Для построения динамического **inventory** должен существовать некий 
[скрипт](https://github.com/st8f/community.general/blob/yc_compute/plugins/inventory/yc_compute.py), который сможет 
передавать json на выход с описанием **hosts** в облаке
* Если существует модуль для создания **hosts** в облаке - он должен уметь собирать динамическое **inventory** 
в процессе создания **hosts**

### 7.2a.5. Использование Ansible
#### Модули для создания инстансов
**Ansible** имеет набор модулей для создания инстансов:
* **AWS**
* **OpenStack**
* **k8s**
* **docker**
* **podman**
* **Google Cloud**
* **Microsoft Azure**
* **Vultr**

Полный перечень модулей можно посмотреть на 
[официальной странице](https://docs.ansible.com/ansible/2.9/modules/list_of_cloud_modules.html)

### Модули для управления inventory
**Ansible** имеет набор модулей для создания inventory:
* **AWS**
* **OpenStack**
* **k8s**
* **docker**
* **Google Cloud**
* **Microsoft Azure**
* **Vultr**

Полный перечень модулей можно посмотреть 
на [официальной странице](https://docs.ansible.com/ansible/latest/collections/index_inventory.html)

#### Как написать Playbook?
Изначально, нужно ответить на два вопроса:
* Для чего нам нужен **playbook**?
* На какие подзадачи можно разделить цель?

Далее, нужно работать над содержанием **playbook**:
* Приготовить структуру директорий
* Приготовить стартовые файлы
* Организовать **inventory** для тестовых прогонов
* Описать структуру **plays** и **tasks** внутри
* При необходимости - параметризировать все tasks при помощи **vars**

#### Схема будущего решения
![Схема будущего решения](img/7_iac/iac_2a_5_1.PNG)

#### Схема целевого решения
![Схема целевого решения](img/7_iac/iac_2a_5_2.PNG)

#### Как запустить Playbook?
* Первый запуск стоит осуществлять или на тестовом окружении или с флагом:  
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --check`
* Если были найдены ошибки:  
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --start-at-task <task_name>`
* Для запуска исполнения в полуинтерактивном виде:  
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml --step`
* Полноценный запуск **playbook** в целевом виде должен выглядеть:  
`ansible-playbook -i inventory/<inv_file>.yml <playbook_name>.yml`

## 7.3 Основы Terraform
### 7.3.1. Состояние проекта
#### State
Основная цель состояния Terraform - хранить связь между объектами в удаленной системе и экземплярами ресурсов, 
объявленными в конфигурации.
* По-умолчанию сохраняется в файле `terraform.tfstate`.
* В том числе хранит в себе метаданные, которые невозможно получить из облачных провайдеров.

#### Работа со State
`terraform state <subcommand> [options] [args]`
Поддерживаемые команды:
* list
* mv
* pull
* push
* rm
* show
* replace-provider

#### Бэкэнды (backends)
Определяют место расположения стейтов и как следствие влияют на выполнения операций задействующие стейты. 
Бэкэнды использовать не обязательно. 

Преимущества использования:
* Работа в команде, возможность блокировки, чтобы несколько людей одновременно не пытались применить изменения.
* Хранить конфиденциальную информации не на локальном диске.
* Удаленные операции, выполняющиеся не на вашем локальном компьютере.

#### Типы бэкэндов
* Standard – поддерживают сохранение стейтов и лок операций.
* Enhanced – стандарт + удаленные операции.

[Все доступные бэкенды](https://www.terraform.io/docs/backends/types/index.html)

#### S3 (aws storage) backend
Пример:
```terraform
terraform {
  backend "s3" {
    bucket = "terraform-states"
    encrypt = true
    key = "main-infra/terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-locks"
  }
}
```

#### Workspaces (окружения)
* Зачастую одну и ту же конфигурацию с небольшими отличиями необходимо воссоздать несколько раз.
* Например несколько окружений: стейдж и продакшн.
* Каждому воркспейсу будет соответсвовать отдельный стейт.
* Воркспейс default создается по-умолчанию.

#### Работа с воркспейсами
Основные команды:  
`terraform workspace [new, list, show, select and delete]`
* **new** – создать новый
* **list** – посмотреть список (проверяются стейт файлы)
* **select** – выбрать с которым будем работать
* **show** – показать название текущего
* **delete** – удалить

### 7.3.2. Создание проекта
#### main.tf
```terraform
provider "aws" {
  region = "us-east-1"
}
```

#### versions.tf
```terraform
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
```

#### Инициализируем проект
```shell
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.0"...
- Installing hashicorp/aws v3.8.0...
- Installed hashicorp/aws v3.8.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

### 7.3.3. Пространства имен
#### Создаем воркспейсы (не обязательно)
```shell
$ terraform workspace new stage
Created and switched to workspace "stage"!

You`re now on a new, empty workspace. Workspaces isolate their
state,
so if you run "terraform plan" Terraform will not see any
existing state
for this configuration.

$ terraform workspace new prod
Created and switched to workspace "prod"!
```

#### Создаем ec2 инстанс
Добавляем рессурс в main.tf
```terraform
resource "aws_instance" "web" {
  ami = "ami-00514a528eadbc95b" // Amazon Linux
  instance_type = "t3.micro"
  
  tags = {
    Name = "HelloWorld"
  }
}
```

#### Минимальный набор параметров
* **ami** - образ Amazon Machine Image (AMI), который будет запущен на сервере EC2. 
В [AWS Marketplace](https://aws.amazon.com/marketplace/) можно найти платные и бесплатные образы. Также можно создать
собственный экземпляр AMI, применяя такие инструменты, как Packer.
* **instance_type** - [тип сервера EC2](https://aws.amazon.com/ec2/instance-types/), который нужно запустить. У каждого
типа есть свой объем ресурсов процессора, памяти, дискового пространства и сети.

#### Планируем изменения
Выполним **terraform plan**
```shell
Terraform will perform the following actions:
  # aws_instance.web will be created
  + resource "aws_instance" "web" {
    + ami = "ami-0c55b159cbfafe1f0"
    + arn = (known after apply)
    ...
    + root_block_device {
      + delete_on_termination = (known after apply)
      ...
      + volume_size = (known after apply)
      + volume_type = (known after apply)
    }
 }

Plan: 1 to add, 0 to change, 0 to destroy.
```

#### Ищем название ami автоматически
Воспользуемся блоком **data**.
```terraform
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
}
```

#### Добавляем зависимость от воркспейса
Для этого воспользуемся локальной переменной.
```terraform
locals {
  web_instance_type_map = {
    stage = "t3.micro"
    prod = "t3.large"
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = local.web_instance_type_map[terraform.workspace]
}
```

#### Создаем несколько ресурсов
Параметр **count**
```terraform
locals {
  web_instance_count_map = {
    stage = 0
    prod = 1
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  count = local.web_instance_count_map[terraform.workspace]
}
```

#### Еще один цикл
Параметр **for_each**
```terraform
locals {
  instances = {
    "t3.micro" = data.aws_ami.amazon_linux.id
    "t3.large" = data.aws_ami.amazon_linux.id
  }
}

resource "aws_instance" "web" {
  for_each = local.instances            # фактически for_each это цикл
  ami = each.value                      # для каждого значения locals
  instance_type = each.key              # для каждого ключа locals
}
```
### 7.3.4. Жизненный цикл
Меняем стандартное поведение ресурса.
* **create_before_destroy** – создать новый ресурс, перед удалением старого, если нет возможности обновить ресурс без
пересоздания.
* **prevent_destroy** – запретить удалять ресурс.
* **ignore_changes** – не обращать внимания при планировании изменений на указанные свойства ресурсов.

Меняем стандартное поведение ресурса:
```terraform
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  tags = {"project": "main"}
  lifecycle {
    create_before_destroy = true
    prevent_destroy = true
    ignore_changes = ["tags"]
  }
}
```
#### Таймауты
Иногда создание ресурса может занять очень много времени
```terraform
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  timeouts {
    create = "60m"
    delete = "2h"
  }
}
```

### 7.3.5. Provisioners
**Provisioners** - это дополнительные блоки позволяющие расширить функционал ресурсов. Но их рекомендуется 
использовать только в крайнем случае, если точно нет более подходящих средств.

#### File provision
Используется для копирования файлов или каталогов с компьютера, на котором выполняется Terraform, во вновь созданный
ресурс.

Передача файлов:
```terraform
resource "aws_instance" "web" {
  # ...
  # Копируем файла myapp.conf в /etc/myapp.conf
  provisioner "file" {
    source = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }
  
# Создаем файл содержащий строку /tmp/file.log
  provisioner "file" {
    content = "ami used: ${self.ami}"
    destination = "/tmp/file.log"
  }

  # Копируем каталог configs.d в /etc/configs.d
  provisioner "file" {
    source = "conf/configs.d"
  destination = "/etc"
  }
}
```

#### Настройки соединения
```terraform
resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  provisioner "file" {
    source = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
    connection {
      type = "ssh"
      user = "root"
      password = "${var.password}"
      host = "${self.public_ip}"
    }
  }
}
```

#### local-exec
Вызывает локальную команду после создания ресурса. 
```terraform
resource "aws_instance" "web" {
  # ...
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```
* **command** – команда
* **working_dir** – рабочая директория для исполнения
* **interpreter** – интерпретатор (perl, python, php ...)
* **environment** – переменные окружения

#### remote-exec
Вызывает скрипт на удаленном ресурсе.
```terraform
resource "aws_instance" "web" {
  # ...
  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web.private_ip}",
    ]
  }
}
```
* **inline** – скрипты;
* **script** – путь к локальному скрипту, который будет скопирован и исполнен удаленно;
* **scripts** – список скриптов;

### 7.3.6. Нулевой ресурс
Если необходимо запустить действия, которые напрямую не связаны с конкретным ресурсом, то можно воспользоваться 
**null_resource**, который, по-умолчанию, ничего не делает.

Но можно указать:
* зависимости,
* локальные или удаленные скрипты,
* триггеры,
* другие аргументы.

## 7.4 Введение в Golang
### 7.4.1. Основы golang
#### Особенности golang
* **Простой и понятный синтаксис.** Это делает написание кода приятным занятием.
* **Статическая типизация.** Позволяет избежать ошибок, допущенных по невнимательности, упрощает чтение и понимание кода,
делает код однозначным.
* **Скорость и компиляция.** Скорость у Go в десятки раз быстрее, чем у скриптовых языков, при меньшем потреблении памяти.
При этом, компиляция практически мгновенна. Весь проект компилируется в один бинарный файл, без зависимостей.
* **Отход от ООП.** В языке нет классов, но есть структуры данных с методами. Наследование заменяется механизмом 
встраивания.
* **Параллелизм.** Параллельные вычисления в языке делаются просто, изящно и без головной боли. Горутины (что-то типа
потоков) легковесны, потребляют мало памяти.
* **Богатая стандартная библиотека.** В языке есть все необходимое для веб-разработки и не только. Количество сторонних
библиотек постоянно растет. Кроме того, есть возможность использовать библиотеки C и C++.
* **Возможность писать в функциональном стиле.** В языке есть замыкания (closures) и анонимные функции. Функции являются
объектами первого порядка, их можно передавать в качестве аргументов и использовать в качестве типов данных.
* **Сильное комьюнити.** Сейчас у языка более 300 контрибьюторов. Язык имеет сильное сообщество и постоянно развивается.
* **Open Source.**

#### Установка
* Менеджер пакетов (brew, apt, ...)  
или:
* Скачиваем архив <https://golang.org/dl/>.
* Извлекаем его в папку `/usr/local`: `tar -C /usr/local -xzf go1.8.3.linux-amd64.tar.gz`

#### Переменные окружения
Добавляем папку `/usr/local/go/bin` в переменную окружения `PATH`:
* `export PATH=$PATH:/usr/local/go/bin`

#### Проверяем корректность установки
Создадим файл `test.go`:
```go
package main
import "fmt"

func main() {
 fmt.Println("Hello, World!")
}
```
Запустим его: `go run test.go`

### 7.4.2. Синтаксис
#### Пакеты
Каждая программа на языке Go состоит из пакетов (**packages**).
Пакет **main** — главный, с него начинается выполнение программы.
В приведённом выше примере импортируется пакет **fmt** и **math**.
```go
import "fmt"
import "math"
```
```go
import (
  "fmt"
  "math"
)
```

#### Функции
Общая форма определения функции выглядит следующим образом:
```go
func function_name ( [список_параметров] ) [возвращаемые_типы] {
  тело_функции
}
```

Использование более трех параметров считается мовитоном, если нужно больше трех рекомендуется использовать структуры

Рекомендации к именованию: переменная - `v_name`, функция - `f_name`

Количество аргументов может быть разным. 
```go
package main
import "fmt"

func add (a int, b int) int {
 return a + b
}

func main () {
  fmt.Println("Сумма равна ", add(10, 19))
}
```

#### Переменные
Определение переменной в Go означает передачу компилятору
информации о типе данных, а так же о месте и объёме хранилища,
которое создаётся для этой переменной. Определять переменные одного
типа можно по одному и списком. 
```go
var [перечень переменных] [тип данных]
```
```go
package main
import "fmt"

var node, golang, angular bool

func main() {
  var x int
  fmt.Println(x, node, golang, angular)
}
```

Так же переменную можно определить без `var` используя оператор `:=`, в этом случае тип переменной определиться автоматически.

#### Указатели и ссылки
`*` - оператор указателя, указывает на ссылку

`&` - оператор ссылки на которую указывает указатель

Основное отличие применения указателей и ссылок в переменных заключается в том что используется значение в ячейке памяти а не имя переменной, так например одноименные переменные записанные в разные функции будут иметь разные значения, а в случае с указателем - одинаковые. (Аналог локальных и глобальных переменных):
```go
func zero(x int) {
    x = 0
}
func main() {
    x := 5
    zero(x)
    fmt.Println(x) // x всё еще равен 5
}
```
```go
func zero(xPtr *int) {
    *xPtr = 0
}
func main() {
    x := 5
    zero(&x)
    fmt.Println(x) // x is 0
}
```
#### Оператор цикла
В Go один оператор цикла — это **for**. 
```go
for [условие] {
  [тело цикла]
}
for [(инициализация; условие; инкремент)] {
  [тело цикла]
}
for [диапазон] {
  [тело цикла]
}
```
Пример цикла:
```go
package main

import "fmt"

func main() {
  sum := 0
  for i := 0; i < 8; i++ {
  sum += i
  }
  fmt.Println("Сумма равна ", sum)
}
```

#### Условный оператор
Форма определения условного оператора в Go выглядит так:
```go
if [условие] {
...
}
```
Примеры условий:
* **true** — выполняется всегда;
* **a < 10** — выполняется, когда a меньше 10;
* **(a < b) || (a < c)** — выполняется, когда a меньше b или a меньше c;
* **(a < b) && (a < c)** — выполняется, когда a меньше b и a меньше c.

```go
package main

import (
  "fmt"
)

func main() {
  if true {
    fmt.Println("Это выражение выполнится всегда")
  }
  if false {
    fmt.Println("Это выражение не выполнится никогда")
  }
}
```

#### Массивы
Go также поддерживает массивы, которые представляют из себя структуру
данных фиксированного размера, состоящую из элементов одного типа.
```go
var наименование_переменной [размер] тип_переменной
```
```go
var balance [10] float32
var balance = []float32{1000.0, 2.0, 3.4, 7.0, 50.0}
```
```go
package main

import "fmt"

func main() {
  var a [2]string
  a[0] = "Привет"
  a[1] = "Netology"
  fmt.Println(a[0], a[1])
  fmt.Println(a)
  
  primes := [6]int{2, 3, 5, 7, 11, 13}
  fmt.Println(primes)
}
```
```shell
$ go run test.go
Привет Netology
[Привет Netology]
[2 3 5 7 11 13]
```

#### Срезы
Срезы (Slices) в Go — абстракция над массивами. Хотя встроенных
способов увеличить размер массива динамически или сделать вложенный
массив в Go нет, срезы убирают это ограничение. 
```go
var numbers []int /* срез неопределённого размера */
/* numbers = []int{0,0,0,0,0} */
numbers = make([]int,5,5) /* срез длиной и ёмкостью равной 5*/
```

* **емкость (cap)** – это выделенная память под элементы, при превышении размер автоматически увеличивается в два раза.
* **длина (len)** – это инициализированная память элементов, для превышения (добавления) нужно вручную использовать append.

```go
package main

import "fmt"

func main() {
  primes := [6]int{2, 3, 5, 7, 11, 13}
  fmt.Println(primes)

  var s []int = primes[1:4]
  fmt.Println(s)

  var numbers []int
  numbers = make([]int,5,5)
  fmt.Print(numbers)
}
```
```shell
$ go run test.go
[2 3 5 7 11 13]
[3 5 7]
[0 0 0 0 0]
```

#### Структуры
Это пользовательский тип данных который комбинирует элементы разных
типов. Чтобы объявить структуру, используем выражения **type** и **struct**:
* **Struct** определяет тип данных, которому соответствует два и более
элементов.
* **Type** связывает заданное имя с описанием структуры.
```go
type struct_name struct {
  member definition
  ...
  member definition
}

variable_name := struct_name {значение1,...значениеN}
```
```go
package main

import "fmt"
 
type person struct{
    name string
    age int
}
 
func main() {
     
    var tom = person {name: "Tom", age: 24}
    fmt.Println(tom.name)       // Tom
    fmt.Println(tom.age)        // 24
     
    tom.age = 38    // изменяем значение
    fmt.Println(tom.name, tom.age)      // Tom 38
```

### 7.4.3. Компиляция
#### go build
Использование команды:
```shell
$ go build [-o output] [-i] [build flags] [packages]
```

Пример:
```shell
$ cd ~/go/src/github.com/netology/devops
$ go build
$ ./devops
```
#### gox
<https://github.com/mitchellh/gox>

Удобный инструмент для кросс-платформенной компиляции кода на golang.
```shell
$ go get github.com/mitchellh/gox
...
$ gox -h
...
```

### 7.4.4. Тестирование
#### Создадим функцию
Файл math.go
```go
package math

import "fmt"

func Average(xs []float64) float64 {
  total := float64(0)
  for _, x := range xs {
    total += x
  }
  return total / float64(len(xs))
}
```

#### Напишем для нее тест
Файл math_test.go
```go
package math

import "testing"

func TestMain(t *testing.T) {
  var v float64
  v = Average([]float64{1,2})
  if v != 1.5 {
    t.Error("Expected 1.5, got ", v)
  }
}
```

#### Запускаем тесты
go test
```shell
$ go test
PASS
ok github.com/netology/devops 0.981s
```

### Полезные ссылки
* [IDE GoLand от JetBrains](https://www.jetbrains.com/ru-ru/go/)
* [Официальный сайт go](https://go.dev/)
* [Песочница go](https://go.dev/play/)
