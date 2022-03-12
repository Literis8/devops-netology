# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами".

## Задача 1
* Опишите своими словами основные преимущества применения на практике IaaC паттернов.
* Какой из принципов IaaC является основополагающим?

### Ответ:
Основными преимущества IaaC являются обеспечение стабильности среды, уверенность в том что любая новая система будет
идентичной предыдущей, так же использование IaaC позволяет ускорить процесс развертывания сред, и ускорить процесс их
изменения, что ускоряет процесс разработки, что в конечном счете приводит к ускорению вывода продукта на рынок.

Основополагающим принципом IaaC, в моем понимании, является то что нужно автоматизировать любое действие которое
приходится совершать повторно, что позволяет не отвлекаться на рутинные процессы, а заниматься более важными задачами.

## Задача 2
* Чем Ansible выгодно отличается от других систем управление конфигурациями?
* Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

### Ответ:
Выгодное отличие Ansible в том что в работе он использует SSH и не требует для своей работы дополнительных PKI 
окружений, или установки каких либо дополнительных инструментов.

С точки зрения надежности, метод Push имеет преимущества: он возможен в использовании без применения дополнительных
инструментов на стороне клиента, так же он проще в мониторинге результата развертывания конфигурации (с Pull, без
дополнительных средств мониторинга мы не всегда можем быть уверены в успешном развертывании конфигурации).   
Однако, с точки зрения безопасности, на мой взгляд, безопаснее Pull. При Push в случае компрометации ключа появится 
возможность получить доступ к целевым серверам кластера, в то время как при Pull сервера кластера могут не иметь 
административный доступ к самому кластеру, что при компрометации не позволить положить всю систему.   
Для примера, по похожему принципу у нас в компании обеспечена передача резервных копий в долгосрочное хранилище,
источники резервных копий отправляют через Push резервные копии на промежуточный сервер, далее методом Pull резервные 
копии с промежуточного сервера забираются в долговременное хранилище, таким образом в долговременное хранилище 
невозможно получить какой-либо доступ с использованием служебных учетных записей.

## Задача 3
Установить на личный компьютер:
* VirtualBox
* Vagrant
* Ansible

_Приложить вывод команд установленных версий каждой из программ, оформленный в markdown._

### Ответ:
```shell
vagrant@vagrant:~$ vboxmanage --version
6.1.32_Ubuntur149290
vagrant@vagrant:~$ vagrant --version
Vagrant 2.2.6
vagrant@vagrant:~$ ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/vagrant/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Jun  2 2021, 10:49:15) [GCC 9.4.0]

```