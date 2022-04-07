# Домашнее задание к занятию "5.4. Оркестрация группой Docker контейнеров на примере Docker Compose".
## Задача 1
Создать собственный образ операционной системы с помощью Packer.

Для получения зачета, вам необходимо предоставить:

* Скриншот страницы, как на слайде из презентации (слайд 37).

### Решение:
```shell
==> yandex: Stopping instance...
==> yandex: Deleting instance...
    yandex: Instance has been deleted!
==> yandex: Creating image: centos-7-base
==> yandex: Waiting for image to complete...
==> yandex: Success image create...
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 2 minutes 2 seconds.

==> Wait completed after 2 minutes 2 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: centos-7-base (id: fd8bcmo1gmkpq2sjq2qa) with family name centos

root@vagrant:/devops-netology/src/packer# yc compute image list
+----------------------+---------------+--------+----------------------+--------+
|          ID          |     NAME      | FAMILY |     PRODUCT IDS      | STATUS |
+----------------------+---------------+--------+----------------------+--------+
| fd8bcmo1gmkpq2sjq2qa | centos-7-base | centos | f2esd9f5o5i9p7pkkk8k | READY  |
+----------------------+---------------+--------+----------------------+--------+


```

![Образы](ex5.4/img/image_list.PNG)

## Задача 2
Создать вашу первую виртуальную машину в Яндекс.Облаке.

Для получения зачета, вам необходимо предоставить:

* Скриншот страницы свойств созданной ВМ.

### Ответ: 
![Свойства виртуальной машины](ex5.4/img/vm_propertys.PNG)

## Задача 3
Создать ваш первый готовый к боевой эксплуатации компонент мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить:

* Скриншот работающего веб-интерфейса Grafana с текущими метриками

### Ответ:
![Grafana](ex5.4/img/graphana.PNG)

