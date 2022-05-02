# Домашнее задание к занятию "6.3. MySQL"

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и 
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

### Решение
* Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.
```yaml
version: "3.1"

volumes:
  mysql_data: {}
  mysql_backup: {}

services:
  mysql:
    image: mysql:8
    command: --default-authentication-plugin=mysql_native_password
    container_name: mysql
    environment:
      MYSQL_ROOT_PASSWORD: mysql
    volumes:
      - mysql_data:/var/lib/mysql
      - mysql_backup:/var/backups/mysql_backup
    restart: always
```
* Изучите бэкап БД и восстановитесь из него.
```shell
vagrant@vagrant:/devops-netology/src$ docker exec -ti mysql bash
root@cf8bbdc06196:/# mysql --password=mysql test < /var/backups/mysql_backup/test_dump.sql
```
* Перейдите в управляющую консоль `mysql` внутри контейнера.
```shell
vagrant@vagrant:/devops-netology/src$ docker exec -ti mysql mysql -p mysql
Enter password:
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.29 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql
```
* Используя команду \h получите список управляющих команд.
```shell
mysql> \h

For information about MySQL products and services, visit:
   http://www.mysql.com/
For developer information, including the MySQL Reference Manual, visit:
   http://dev.mysql.com/
To buy MySQL Enterprise support, training, or other products, visit:
   https://shop.mysql.com/

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
?         (\?) Synonym for `help'.
clear     (\c) Clear the current input statement.
connect   (\r) Reconnect to the server. Optional arguments are db and host.
delimiter (\d) Set statement delimiter.
edit      (\e) Edit command with $EDITOR.
ego       (\G) Send command to mysql server, display result vertically.
exit      (\q) Exit mysql. Same as quit.
go        (\g) Send command to mysql server.
help      (\h) Display this help.
nopager   (\n) Disable pager, print to stdout.
notee     (\t) Don't write into outfile.
pager     (\P) Set PAGER [to_pager]. Print the query results via PAGER.
print     (\p) Print current command.
prompt    (\R) Change your mysql prompt.
quit      (\q) Quit mysql.
rehash    (\#) Rebuild completion hash.
source    (\.) Execute an SQL script file. Takes a file name as an argument.
status    (\s) Get status information from the server.
system    (\!) Execute a system shell command.
tee       (\T) Set outfile [to_outfile]. Append everything into given outfile.
use       (\u) Use another database. Takes database name as argument.
charset   (\C) Switch to another charset. Might be needed for processing binlog with multi-byte charsets.
warnings  (\W) Show warnings after every statement.
nowarning (\w) Don't show warnings after every statement.
resetconnection(\x) Clean session context.
query_attributes Sets string parameters (name1 value1 name2 value2 ...) for the next query to pick up.
ssl_session_data_print Serializes the current SSL session data to stdout or file

For server side help, type 'help contents'

mysql> CREATE DATABASE test
    -> ;
Query OK, 1 row affected (0.00 sec)
```
* Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.
```shell
mysql> \s
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)
...
Threads: 2  Questions: 112  Slow queries: 0  Opens: 216  Flush tables: 3  Open tables: 134  Queries per second avg: 0.068
--------------
```
* Подключитесь к восстановленной БД и получите список таблиц из этой БД.
```shell
mysql> USE test
mysql> SHOW TABLES;
+----------------+
| Tables_in_test |
+----------------+
| orders         |
+----------------+
1 row in set (0.00 sec)

```
* Приведите в ответе количество записей с price > 300.
```shell
mysql> SELECT * FROM orders WHERE price > 300;
+----+----------------+-------+
| id | title          | price |
+----+----------------+-------+
|  2 | My little pony |   500 |
+----+----------------+-------+
1 row in set (0.00 sec)

```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней 
- количество попыток авторизации - 3 
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привилегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и 
**приведите в ответе к задаче**.

### Решение:
* Создайте пользователя test в БД c паролем test-pass
```shell
mysql> CREATE USER 'test'
    -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_QUERIES_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> ATTRIBUTE '{"name": "James", "lastname": "Pretty"}';
Query OK, 0 rows affected (0.01 sec)
```
* Предоставьте привилегии пользователю test на операции SELECT базы test_db.
> Поскольку в задаче не было указано как назвать базу данных, у меня она называется не test_db, а test
```shell
mysql> GRANT SELECT ON test.* TO test;
Query OK, 0 rows affected (0.01 sec)
```
* Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю test и приведите в ответе к задаче.
```shell
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+------+-----------------------------------------+
| USER | HOST | ATTRIBUTE                               |
+------+------+-----------------------------------------+
| test | %    | {"name": "James", "lastname": "Pretty"} |
+------+------+-----------------------------------------+
1 row in set (0.01 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

### Решение
* Установите профилирование `SET profiling = 1`. Изучите вывод профилирования команд `SHOW PROFILES;`.
```shell
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
mysql> SHOW PROFILES;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.00013625 | SET profiling = 1 |
+----------+------------+-------------------+
1 row in set, 1 warning (0.00 sec)
```
* Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.
```shell
mysql> SHOW TABLE STATUS
    -> ;
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+-------------
--------+---------------------+------------+--------------------+----------+----------------+---------+
| Name   | Engine | Version | Row_format | Rows | Avg_row_length | Data_length | Max_data_length | Index_length | Data_free | Auto_increment | Create_time
        | Update_time         | Check_time | Collation          | Checksum | Create_options | Comment |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+-------------
--------+---------------------+------------+--------------------+----------+----------------+---------+
| orders | InnoDB |      10 | Dynamic    |    5 |           3276 |       16384 |               0 |            0 |         0 |              6 | 2022-05-02 0
9:18:38 | 2022-05-02 09:18:38 | NULL       | utf8mb4_0900_ai_ci |     NULL |                |         |
+--------+--------+---------+------------+------+----------------+-------------+-----------------+--------------+-----------+----------------+-------------
--------+---------------------+------------+--------------------+----------+----------------+---------+
1 row in set (0.01 sec)


```
Измените `engine` на `MyISAM` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
```shell
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0
mysql> SHOW PROFILES;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|        1 | 0.00013625 | SET profiling = 1                  |
|        2 | 0.00024750 | SHOW engines                       |
|        3 | 0.00007300 | SHOW TABLE                         |
|        4 | 0.00017200 | SHOW TABLE ENGINE                  |
|        5 | 0.00007050 | SHOW TABLE STATUS                  |
|        6 | 0.00013125 | SELECT DATABASE()                  |
|        7 | 0.00015500 | SELECT DATABASE()                  |
|        8 | 0.00016200 | SELECT DATABASE()                  |
|        9 | 0.00086625 | show databases                     |
|       10 | 0.00158725 | show tables                        |
|       11 | 0.00399650 | SHOW TABLE STATUS                  |
|       12 | 0.00164600 | SHOW TABLE STATUS                  |
|       13 | 0.02287950 | ALTER TABLE orders ENGINE = MyISAM |
+----------+------------+------------------------------------+
13 row
```
Измените `engine` на `InnoDB` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
```shell
mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.03 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+------------------------------------+
| Query_ID | Duration   | Query                              |
+----------+------------+------------------------------------+
|        1 | 0.00013625 | SET profiling = 1                  |
|        2 | 0.00024750 | SHOW engines                       |
|        3 | 0.00007300 | SHOW TABLE                         |
|        4 | 0.00017200 | SHOW TABLE ENGINE                  |
|        5 | 0.00007050 | SHOW TABLE STATUS                  |
|        6 | 0.00013125 | SELECT DATABASE()                  |
|        7 | 0.00015500 | SELECT DATABASE()                  |
|        8 | 0.00016200 | SELECT DATABASE()                  |
|        9 | 0.00086625 | show databases                     |
|       10 | 0.00158725 | show tables                        |
|       11 | 0.00399650 | SHOW TABLE STATUS                  |
|       12 | 0.00164600 | SHOW TABLE STATUS                  |
|       13 | 0.02287950 | ALTER TABLE orders ENGINE = MyISAM |
|       14 | 0.02460200 | ALTER TABLE orders ENGINE = InnoDB |
+----------+------------+------------------------------------+
14 rows in set, 1 warning (0.00 sec)
```
## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буфера с незакоммиченными транзакциями 1 Мб
- Буфер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

### Решение:
```shell
vagrant@vagrant:~$ docker exec -ti mysql bash
root@cf8bbdc06196:/# cat /etc/mysql/my.cnf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/

root@cf8bbdc06196:/# echo innodb_flush_method = O_DSYNC >> /etc/mysql/my.cnf
root@cf8bbdc06196:/# echo innodb_file_per_table = 1 >> /etc/mysql/my.cnf
root@cf8bbdc06196:/# echo innodb_log_buffer_size = 1M  >> /etc/mysql/my.cnf
root@cf8bbdc06196:/# echo innodb_buffer_pool_size = 307M >> /etc/mysql/my.cnf
root@cf8bbdc06196:/# echo innodb_log_file_size = 100M >> /etc/mysql/my.cnf
root@cf8bbdc06196:/# cat /etc/mysql/my.cnf
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA

#
# The MySQL  Server configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
!includedir /etc/mysql/conf.d/
innodb_flush_method = O_DSYNC
innodb_file_per_table = 1
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 307M
innodb_log_file_size = 100M

```