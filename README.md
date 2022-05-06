# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

### Решение:
* Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```yaml
version: "3.1"

volumes:
  pg_data: {}
  pg_backup: {}

services:
  postgesql:
    image: postgres:13
    container_name: postgresql
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pg_data:/var/lib/postgresql/data/
      - pg_backup:/var/backups/pg_backup
    restart: always
```
* Найдите и приведите управляющие команды для вывода списка БД
```shell
postgres=# \l
                                 List of databases                                 
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |                       
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres 
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres 
(3 rows) 
```
* Найдите и приведите управляющие команды для - подключения к БД
```shell
postgres=# \c postgres
You are now connected to database "postgres" as user "postgres".
```
* Найдите и приведите управляющие команды для - вывода списка таблиц
```shell
template1=# \dt
Did not find any relations.
```
* Найдите и приведите управляющие команды для - вывода описания содержимого таблиц
```shell
postgres=# \d
Did not find any relations.
```
* Найдите и приведите управляющие команды для - выхода из psql
```shell
postgres=# \q
vagrant@vagrant:/devops-netology/src$ 
```

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

### Решение:
* Используя `psql` создайте БД `test_database`.
```shell
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
```
* Восстановите бэкап БД в `test_database`.
```shell
vagrant@vagrant:/devops-netology/src$ docker exec -ti postgresql bash
root@4b0735b2d3ec:/# psql -U postgres test_database < /var/backups/pg_backup/test_dump.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
```
* Перейдите в управляющую консоль `psql` внутри контейнера.
```shell
vagrant@vagrant:/devops-netology/src$ docker exec -ti postgresql psql -U postgres
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.

postgres=# 
```
* Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```shell
postgres=# \c test_database 
You are now connected to database "test_database" as user "postgres".
test_database=# ANALYZE;
ANALYZE
```
* Используя таблицу `pg_stats`, найдите столбец таблицы `orders` с наибольшим средним значением размера элементов 
в байтах. Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.
```shell
test_database=# SELECT attname, avg_width FROM pg_stats WHERE tablename = 'orders' ORDER BY attname DESC LIMIT 1;
 attname | avg_width 
---------+-----------
 title   |        16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

### Решение:
Как я выяснил, преобразовать таблицу в секционированную и обратно нельзя, так что будем пересоздавать таблицу через
следующую транзакцию:
```shell
BEGIN;
# установить изоляцию транзакций
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
# переименовать таблицу orders
ALTER TABLE orders RENAME TO orders_copy;
# создать таблицу orders
CREATE TABLE orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0)
	PARTITION BY RANGE (price);
# создать таблицу 1
CREATE TABLE orders_more499 PARTITION OF orders
    FOR VALUES FROM (500) TO (2147483647);
# создать таблицу 2
CREATE TABLE orders_less500 PARTITION OF orders
    FOR VALUES FROM (0) TO (500);
# перенести из переименованной в orders
INSERT INTO orders (id, title, price) SELECT * FROM orders_copy;
# Установить индексы
ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);
# Удалить таблицу copy
DROP TABLE orders_copy;
COMMIT;
```
## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
