# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

### Ответ:
```yaml
version: "2.4"

volumes:
  pg_data: {}
  pg_backup: {}

services:
  postgesql:
    image: postgres:12
    container_name: postgresql
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - pg_data:/var/lib/postgresql/data/
      - pg_backup:/var/backups/pg_backup
    restart: always
```
## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Решение:
```shell
vagrant@vagrant:/devops-netology/src$ docker-compose up -d
[+] Running 2/2
 ⠿ Network src_default   Created                                                                                                                                                                                                      0.1s 
 ⠿ Container postgresql  Started    

vagrant@vagrant:/devops-netology/src$ docker exec -it postgresql psql -U postgres
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=#
```
* создайте пользователя test-admin-user и БД test_db:
```shell
postgres=# CREATE USER "test-admin-user"; CREATE DATABASE test_db;
CREATE ROLE
CREATE DATABASE
```
* в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже):
```shell
postgres=# CREATE TABLE orders (                                  
id SERIAL PRIMARY KEY,                                            
наименование VARCHAR,                                                
цена INTEGER                                                      
);                                                                
CREATE TABLE
postgres=# CREATE TABLE clients (
id SERIAL PRIMARY KEY,
фамилия VARCHAR,
"страна проживания" VARCHAR,
заказ INT,
FOREIGN KEY (заказ) REFERENCES orders (id)
);
CREATE TABLE
```
* предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
```shell
postgres=# GRANT ALL ON orders, clients TO "test-admin-user";
GRANT
```
* создайте пользователя test-simple-user
```shell
postgres=# CREATE USER "test-simple-user";
CREATE ROLE
```
* предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db
```shell
postgres=# GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";
GRANT
```
* приведите итоговый список БД после выполнения пунктов выше
```shell
postgres=# \l
                                     List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |       Access privileges
-----------+----------+----------+------------+------------+--------------------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres                   +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =Tc/postgres                  +
           |          |          |            |            | postgres=CTc/postgres         +
           |          |          |            |            | "test-admin-user"=CTc/postgres
(4 rows)
```
* приведите описание таблиц (describe)
```shell
postgres=# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default
-------------------+-------------------+-----------+----------+-------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           |          |
 страна проживания | character varying |           |          |
 заказ             | integer           |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

postgres=# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           |          |
 цена         | integer           |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```
* Приведите SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
```sql
SELECT * FROM information_schema.table_privileges WHERE table_name = 'clients' OR table_name = 'orders';
```
* список пользователей с правами над таблицами test_db
```shell
 grantor  |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
----------+------------------+---------------+--------------+------------+----------------+--------------+----------------
 postgres | postgres         | postgres      | public       | orders     | INSERT         | YES          | NO
 postgres | postgres         | postgres      | public       | orders     | SELECT         | YES          | YES
 postgres | postgres         | postgres      | public       | orders     | UPDATE         | YES          | NO
 postgres | postgres         | postgres      | public       | orders     | DELETE         | YES          | NO
 postgres | postgres         | postgres      | public       | orders     | TRUNCATE       | YES          | NO
 postgres | postgres         | postgres      | public       | orders     | REFERENCES     | YES          | NO
 postgres | postgres         | postgres      | public       | orders     | TRIGGER        | YES          | NO
 postgres | test-simple-user | postgres      | public       | orders     | INSERT         | NO           | NO
 postgres | test-simple-user | postgres      | public       | orders     | SELECT         | NO           | YES
 postgres | test-simple-user | postgres      | public       | orders     | UPDATE         | NO           | NO
 postgres | test-simple-user | postgres      | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | INSERT         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | SELECT         | NO           | YES
 postgres | test-admin-user  | postgres      | public       | orders     | UPDATE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | REFERENCES     | NO           | NO
 postgres | test-admin-user  | postgres      | public       | orders     | TRIGGER        | NO           | NO
 postgres | postgres         | postgres      | public       | clients    | INSERT         | YES          | NO
 postgres | postgres         | postgres      | public       | clients    | SELECT         | YES          | YES
 postgres | postgres         | postgres      | public       | clients    | UPDATE         | YES          | NO
 postgres | postgres         | postgres      | public       | clients    | DELETE         | YES          | NO
 postgres | postgres         | postgres      | public       | clients    | TRUNCATE       | YES          | NO
 postgres | postgres         | postgres      | public       | clients    | REFERENCES     | YES          | NO
 postgres | postgres         | postgres      | public       | clients    | TRIGGER        | YES          | NO
 postgres | test-simple-user | postgres      | public       | clients    | INSERT         | NO           | NO
 postgres | test-simple-user | postgres      | public       | clients    | SELECT         | NO           | YES
 postgres | test-simple-user | postgres      | public       | clients    | UPDATE         | NO           | NO
 postgres | test-simple-user | postgres      | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | INSERT         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | SELECT         | NO           | YES
 postgres | test-admin-user  | postgres      | public       | clients    | UPDATE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | DELETE         | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | TRUNCATE       | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | REFERENCES     | NO           | NO
 postgres | test-admin-user  | postgres      | public       | clients    | TRIGGER        | NO           | NO
(36 rows)
```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

| Наименование | цена |
|--------------|------|
| Шоколад      | 10   |
| Принтер      | 3000 |
| Книга        | 500  |
| Монитор      | 7000 |
| Гитара       | 4000 |

Таблица clients

| ФИО                  | Страна проживания |
|----------------------|-------------------|
| Иванов Иван Иванович | USA               |
| Петров Петр Петрович | Canada            |
| Иоганн Себастьян Бах | Japan             |
| Ронни Джеймс Дио     | Russia            |
| Ritchie Blackmore    | Russia            |

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

### Решение:
```shell
postgres=# INSERT INTO orders (наименование, цена) VALUES
('Шоколад', 10),
('Принтер', 3000),
('Книга', 500),
('Монитор', 7000),
('Гитара', 4000);
INSERT 0 5

postgres=# INSERT INTO clients (фамилия, "страна проживания") VALUES
('Иванов Иван Иванович', 'USA'),
('Петров Петр Петрович', 'Canada'),
('Иоганн Себастьян Бах', 'Japan'),
('Ронни Джеймс Дио', 'Russia'),
('Ritchie Blackmore', 'Russia');
INSERT 0 5

postgres=# SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

postgres=# SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
```
## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

| ФИО                  | Заказ   |
|----------------------|---------|
| Иванов Иван Иванович | Книга   |
| Петров Петр Петрович | Монитор |
| Иоганн Себастьян Бах | Гитара  |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

### Решение:
```shell
postgres=# UPDATE clients SET "заказ" = 3 WHERE фамилия = 'Иванов Иван Иванович';
UPDATE 1
postgres=# UPDATE clients SET "заказ" = 4 WHERE фамилия = 'Петров Петр Петрович';
UPDATE 1
postgres=# UPDATE clients SET "заказ" = 5 WHERE фамилия = 'Иоганн Себастьян Бах';
UPDATE 1

postgres=# SELECT * FROM clients WHERE заказ IS NOT NULL;
 id |       фамилия        | страна проживания | заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

### Решение
```shell
postgres=# EXPLAIN SELECT * FROM clients WHERE заказ IS NOT NULL;
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on clients  (cost=0.00..18.10 rows=806 width=72)
   Filter: ("заказ" IS NOT NULL)
(2 rows)
```
Числа, перечисленные в скобках (слева направо), имеют следующий смысл:
* Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных, например для сортирующего узла это время сортировки.
* Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки. На практике родительский узел может досрочно прекратить чтение строк дочернего (см. приведённый ниже пример с LIMIT).
* Ожидаемое число строк, которое должен вывести этот узел плана. При этом так же предполагается, что узел выполняется до конца.
* Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).
## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

### Решение:
Есть 2 основных способа осуществления резервного копирования, pg_dump для копирования базы данных, и pg_basebacup
для резервного копирования всего кластера. Когда-то кто-то мне рассказывал что при использовании pg_dump могут быть 
утеряны реляционные отношения в базе данных, вроде-как в случае восстановления может быть нарушена последовательность
создания таблиц, что приведет к нарушению целостности базы данных, поэтому мы приняли решения использовать на наших
серверах pg_basebackup, команда выглядит следующим образом:  
`docker exec postgresql pg_basebackup -h localhost -U postgres -p 5432 -w -D /var/backups/pg_backup/datebase.backup -Ft`

Последовательность восстановления будет выглядеть следующим образом:
1. Остановить проект (docker-compose down)
2. Очистить содержимое volume контейнера субд (/var/lib/docker/volumes/src_pg_data/_data/)
3. Распаковать содержимое архива base.tar в volume контейнера субд.
4. Распаковать содержимое архива pg_wal.tar в volume контейнера субд (/var/lib/docker/volumes/src_pg_data/_data/)
5. Дописать в файл postgresql.conf строку `restore_command = 'cp /var/lib/postgresql/data/%f %p\'`
6. Создать файл recovery.signal в директории СУБД
7. Запустить проект (docker-compose up)


```shell
root@vagrant:~# cd /devops-netology/src/
root@vagrant:/devops-netology/src# docker-compose down
[+] Running 2/2
 ⠿ Container postgresql  Removed                                                                                                                      0.2s
 ⠿ Network src_default   Removed                                                                                                                      0.1s

root@vagrant:/devops-netology/src# rm -R /var/lib/docker/volumes/src_pg_data/_data/*
root@vagrant:/devops-netology/src# cd /var/lib/docker/volumes/src_pg_backup/_data/datebase.backup
root@vagrant:/var/lib/docker/volumes/src_pg_backup/_data/datebase.backup# cp base.tar ../../../src_pg_data/_data/
root@vagrant:/var/lib/docker/volumes/src_pg_backup/_data/datebase.backup# cp pg_wal.tar ../../../src_pg_data/_data/
root@vagrant:/var/lib/docker/volumes/src_pg_backup/_data/datebase.backup# cd ../../../src_pg_data/_data/
root@vagrant:/var/lib/docker/volumes/src_pg_data/_data# touch recovery.signal
root@vagrant:/var/lib/docker/volumes/src_pg_data/_data# tar -xf base.tar
root@vagrant:/var/lib/docker/volumes/src_pg_data/_data# tar -xf pg_wal.tar
root@vagrant:/var/lib/docker/volumes/src_pg_data/_data#  echo restore_command = \'cp /var/lib/postgresql/data/%f %p\' >> postgresql.conf
root@vagrant:/var/lib/docker/volumes/src_pg_data/_data# cd /devops-netology/src/
root@vagrant:/devops-netology/src# docker-compose up -d
[+] Running 1/1
 ⠿ Container postgresql  Started    
vagrant@vagrant:/devops-netology/src$ docker exec -it postgresql psql -U postgres
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=# \dl
      Large objects
 ID | Owner | Description
----+-------+-------------
(0 rows)

postgres=# \d
               List of relations
 Schema |      Name      |   Type   |  Owner
--------+----------------+----------+----------
 public | clients        | table    | postgres
 public | clients_id_seq | sequence | postgres
 public | orders         | table    | postgres
 public | orders_id_seq  | sequence | postgres
(4 rows)

postgres=# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | clients | table | postgres
 public | orders  | table | postgres
(2 rows)

postgres=# \d clients
                                       Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default
-------------------+-------------------+-----------+----------+-------------------------------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
 фамилия           | character varying |           |          |
 страна проживания | character varying |           |          |
 заказ             | integer           |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

postgres=# \d orders
                                    Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default
--------------+-------------------+-----------+----------+------------------------------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
 наименование | character varying |           |          |
 цена         | integer           |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)

postgres=#
```

Как видно, базы успешно восстановлены.