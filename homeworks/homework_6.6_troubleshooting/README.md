# Домашнее задание к занятию "6.6. Troubleshooting"

## Задача 1

Перед выполнением задания ознакомьтесь с документацией по [администрированию MongoDB](https://docs.mongodb.com/manual/administration/).

Пользователь (разработчик) написал в канал поддержки, что у него уже 3 минуты происходит CRUD операция в MongoDB и её 
нужно прервать. 

Вы как инженер поддержки решили произвести данную операцию:
- напишите список операций, которые вы будете производить для остановки запроса пользователя
- предложите вариант решения проблемы с долгими (зависающими) запросами в MongoDB

### Решение:
Для начала я бы получил список запущенных операций командой `db.currentOp()` и далее завершил бы проблемную операцию
командой `db.killOp(<opId>)` где _opId_ это проблемная операция.

Для решения этой проблемы зависающих запросов я бы в первую очередь рассмотрел сам этот запрос через explain. Если
проблема не воспроизвелась, либо по средствам explain не удалось бы выявить проблему, я бы запустил систему мониторинга
Free monitoring и по результатам мониторинга принял бы соответствующее решение проблемы, либо увеличил кол-во шард,
либо увеличил RAM или HDD, и т.п. Вариантов может быть много, все зависит от результата мониторинга.
## Задача 2

Перед выполнением задания познакомьтесь с документацией по [Redis latency troobleshooting](https://redis.io/topics/latency).

Вы запустили инстанс Redis для использования совместно с сервисом, который использует механизм TTL. 
Причем отношение количества записанных key-value значений к количеству истёкших значений есть величина постоянная и
увеличивается пропорционально количеству реплик сервиса. 

При масштабировании сервиса до N реплик вы увидели, что:
- сначала рост отношения записанных значений к истекшим
- Redis блокирует операции записи

Как вы думаете, в чем может быть проблема?

### Решение
Предполагаю что проблема может быть связана с большим количеством удаляемых ключей. Во время удаления ключей блокируется
операция записи. Это может быть связанно с низкой скоростью записи на жестком диске.

## Задача 3

Вы подняли базу данных MySQL для использования в гис-системе. При росте количества записей, в таблицах базы,
пользователи начали жаловаться на ошибки вида:
```shell
InterfaceError: (InterfaceError) 2013: Lost connection to MySQL server during query u'SELECT..... '
```

Как вы думаете, почему это начало происходить и как локализовать проблему?

Какие пути решения данной проблемы вы можете предложить?

### Решение:
Возможно проблема связана из-за слишком большого кол-ва записей в таблице в связи с чем запрос не успевает обработаться
до таймаута. Как вариант можно увеличить параметры таймаутов:
* connect_timeout
* interactive_timeout
* wait_timeout
* net_read_timeout

## Задача 4

Вы решили перевести гис-систему из задачи 3 на PostgreSQL, так как прочитали в документации, что эта СУБД работает с 
большим объемом данных лучше, чем MySQL.

После запуска пользователи начали жаловаться, что СУБД время от времени становится недоступной. В dmesg вы видите, что:

`postmaster invoked oom-killer`

Как вы думаете, что происходит?

Как бы вы решили данную проблему?

### Решение:
Происходит завершение процесса ядром ОС из-за высокого потребления памяти процессом PostgreSQL. Для решения проблемы
нужно установить ограничение на потребление памяти процессами PostgreSQL подобрав оптимальные значения shared_buffers, 
temp_buffers, work_mem, effective_cache_size, maintenance_work_mem.