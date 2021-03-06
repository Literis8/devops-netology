# 4. Скриптовые языки и языки разметки: Python, Bash, YAML, JSON

## 4.1 Командная оболочка Bash: практические навыки

### 4.1.1 Bash - что это такое?
**Bash** - Bourne Again Shell, очередная командная оболочка Борна, представляет собой расширенную версию 
Bourne Shell (sh).
* Является основной командной оболочкой для систем Linux, работающий как в интерактивном, так и в скриптовом режиме.
* Умеет работать с автодополнением команд, имён файлов и каталогов (клавиша Tab), создавать переменные, 
работать с циклами, ветвлениями, подстановку вывода результата команд.

### 4.1.2 Для чего может быть использован bash в DevOps?
В основном, bash используется для деплоя:
* **Автоматизация деплоя** контейнеров позволяет не просто скачать контейнер с приложением, но и подготовить окружение
для деплоя
* **Динамическое изменение конфигурации приложений**. В случае, если ваше приложение проходит через несколько этапов
тестирования и имеет огромное количество интеграций с другими сервисами, гораздо удобнее подставлять конфигурационные
файлы автоматически
* **Остановка, перезапуск сервисов, минимальное тестирование etc**, в общем случае, любые действия, которые необходимо
выполнять на системе перед первым запуском приложения, проще автоматизировать один раз, чем выполнять руками

Bash можно использовать и на этапе разработки:
* **Автоматизация скачивания репозиториев с зависимостями.** Подойдёт в случае, если вы не используете системы сборки
приложений и у вас есть проекты/библиотеки/репозитории, которые вы переиспользуете в своём проекте.
* **Сборка по коммиту** позволит автоматизировать часть непрерывной интеграции, отлавливая события коммита в
репозиторий с последующим запуском сборки

### 4.1.3 Основы синтаксиса

#### Переменные, массивы
В bash все переменные - целые числа или строки, в зависимости от того, как они определены, их можно задавать в явном
и неявном виде (по умолчанию все переменные являются строками):
```shell
a=33 #Неявное определение целочисленного
b=SA34 #Неявное определение строки
```
Такая неопределённость может порождать разные вариации при работе с переменными:
```shell
a=33 #Строка с целым числом
let "a+=1" && echo $a #Получаем 34
b=SA34 #Строка с буквами и целым числом
let "b+=1" $$ echo $b #Получаем 1, т.к. переменная не была целочисленной
b=SA34 #Возвращаем значение со строкой
a=${b/SA/33} #Присваиваем переменной a значение b, заменив SA на 33
echo $a # Получим число 3334
let "a+=1" && echo $a #Получаем 3335, то есть значение целочисленное
```
`let <var>` - выполнить математическую операцию с переменой

`a+=n` - инкриминировать переменную _a_ на _n_ эквивалент `a=a+n`

`a=${b/<str1>/<str2}` - присвоить найти в переменной _b_ запись _str1_, заменить на _str2_ и присвоить результат _a_

Для большего контроля над переменными при их объявлении можно использовать команду `declare`:
```shell
declare -i a #Объявление целочисленной переменной
declare -i b;declare -i c
a=32;b=2;c=$a+$b
echo $c #Выведет 34
c="Hello" #Попытка присваивания строкового значения
echo $c #Выведет 0
d=32;e=2;f=$d+$e
echo $f #Выведет 32+2
```
`{}` - используются для выделения переменных

Массивы представляют собой одномерный набор элементов, который может включать в себя одновременно и строковые 
и целочисленные значения:
```shell
array_int=(0 1 2 3 4 5) #Массив из целых чисел
array_str=("one" "two" "three" "four" "five") #Массив строк
array_mix=(1 "two" 3 "four" 5) #Массив с обоими типами данных
echo $array_int #Выводит первый элемент массива
echo ${array_int[1]} #Выводит второй элемент массива
echo ${array_int[@]} #Выводит все элементы массива
i=3
echo ${array_int[$i]} #Выводит четвёртый элемент массива
```
`$IFS` - переменная определяющая разделители (по умолчанию пробел)

Синтаксис для работы с массивами:
```shell
echo ${!array_int[@]} #Получить индексы массива
echo ${#array_int[@]} #Получить размер массива
array_int[0]=0 #Перезаписать значение первого элемента
array_int+=(6) #Добавить в конец массива элемент со значением
array_out=() #Создать пустой массив
array_out=$(ls) #Записать вывод ls как строку
array_out=($(ls)) #Записать вывод ls как набор строковых элементов
```
`$(<command>)` - используются для присвоения переменной вывода команды

Bash поддерживает все стандартные операции с целыми числами:
```shell
a=2;b=4;c=0
c=$(($a+$b))
c=$(($b-$a))
c=$(($b*$a))
c=$(($b/$a))
```
Двойные скобки используются в связи с тем что в одинарных выполняется команда, и система будет пытаться присвоить 
переменной значение выполнения команды, так как команды 2+4 не существует, будет выдана ошибка. Так же в некоторых 
случаях вместо двойных скобок можно использовать одинарные квадратные.

Bash позволяет проводить сравнение как чисел, так и строк. Для чисел доступны следующие операции:
```shell
a=2;b=4
["$a" -eq "$b"] #числа равны
["$a" -ne "$b"] #числа не равны
["$a" -gt "$b"] #число а больше b
["$a" -ge "$b"] #число a больше или равно b
["$a" -lt "$b"] #число a меньше b
["$a" -le "$b"] #число a меньше или равно b
```
Для строк набор операций чуть меньше:
```shell
a=Hello;b=hello
[ "$a" = "$b" ] #строки равны
[ "$a" == "$b" ] #строки равны
[ "$a" != "$b" ] #строки не равны
[ "$a" \> "$b" ] #строка а больше b
[[ "$a" > "$b" ]] #строка а больше b
[ "$a" \< "$b" ] #строка a меньше b
[[ "$a" < "$b" ]] #строка а больше b
[ -n "$a"] #строка a не пустая
[ -z "$a"] #строка a пустая
```
Конструкция if-then-elif-else в bash имеет следующий синтаксис:
```shell
a=Hello;b=hello
if [ "$a" = "$b" ]
then
 echo "строка $a равна строке $b"
elif [ "$a" \> "$b" ]
then
 echo "строка $a больше строки $b"
else
 echo "строка $a меньше строки $b"
fi
```
`#!/bin/bash` - (**shebang**) в начале скрипта указывает на путь к интерпретатору скрипта, так же можно указать путь на переменную
в которой указан путь к интерпретатору (`#!/usr/bin/env bash`).

#### Циклы
Цикл **for**:
```shell
array_int=(0 1 2 3 4)
for i in ${array_int[@]}
do
echo $i
done
```
Цикл **while**:
```shell
a=5
while (($a > 0))
do
echo $a
let "a -= 1"
done
```
Цикл **for** удобен для обработки:
* **Значений массивов**, как указано выше;
* **Вывода команд**, набором данных может выступать вывод команды ls, где через пробел указаны значения, которые будут
интерпретироваться как элементы массива;
* **Значений файлов**, в этом случае набором данных может выступать вывод команды cat. По умолчанию, разделителями 
считаются: пробел, знак табуляции, знак перевода строки. Разделитель можно переопределить через переменную **IFS**.

Цикл **while** удобен для использования в тех случаях, когда условие выхода из него сложно ограничить конечным
количеством итераций. Например, мы должны прекратить отслеживание содержимого файла только в том случае, если файл 
перестал быть доступен нам для чтения.

`brake` - прерывает выполнение цикла.

`exit` - прерывает выполнение скрипта.

`$?` - содержит return code последней выполненной команды.

#### Расширение скобок
Эта возможность позволяет формировать строки из наборов символов:
```shell
echo s{t,tr}ing #Выведет sting string
echo {a..g} #Выведет a b c d e f g
echo {1..9} #Выведет 1 2 3 4 5 6 7 8 9
echo {7..A} #Выведет 7 8 9 : ; < = > ? @ A НЕ РАБОТАЕТ В BASH
```
Данную особенность удобно использовать совместно с командами:
```shell
ls *.{png,jpg} #Выведет все png и jpg файлы из текущего каталога
```

### 4.1.4 Как написать первый скрипт?
Существует ряд основных правил для формирования правильного bash-скрипта:
* Скрипт должен начинаться с `#!/usr/bin/env bash`
* Необходимо следить за скобками и правильно ими экранировать операции с переменными

## 4.2. Использование Python для решения типовых DevOps задач

### 4.2.1 Для чего нужен Python?
Возможности Python шире чем у Bash, так как:
* Он является языком программирования
* Содержит большое количество встроенных функций и модулей для работы с системой, без ущерба работы с логикой
* Имеет множество загружаемых модулей для более удобной работы с любым уровнем автоматизаций

В DevOps у Python следующие назначения:
* Автоматизация конфигурирования инфраструктуры при помощи Ansible
* Использование в инструментах автоматизации. Например, в Jenkins можно описывать шаги сборки полностью на Python
* Удобство работы с API инструментов. Существует множество готовых решений для работы с API Bitbucket, GitLab, GitHub,
Nexus, Crowd, Jira, Confluence, etc.

### 4.2.2 Основы синтаксиса Python

#### Переменные
В Python используется неявное определение переменных:
* Определение типа переменной происходит динамически
* Любой тип переменной можно преобразовать в любой другой тип: int(s), str(i), float(i)
* Следить за типом переменных и контролировать их переопределение - наша задача
* Определить тип переменной можно при помощи type(имя_переменной)

`type(var)` - вывести класс переменной

#### Массивы
**Массивы в Python** - не такие, как в привычном понимании программиста.

**Существует несколько видов:**
* Упорядоченный, редактируемый (list) `[‘a’, 23, ‘hello’]`
* Упорядоченный, нередактируемый (tuple) `(14, ‘yes’, ‘no’)`
* Неупорядоченный, редактируемый, уникальный (set) `{H,e,l,o}` - убирает дублирующиеся элементы, порядок не соблюдается
* Неупорядоченный, key-value (dict) `{1:’Январь’, 2:’Февраль’}`

`list.append('something')` - увеличить массив и добавить в последний элемент значение _something_

`print(list[n:m])` - вывести элементы с _n_ по _m_ (если _n_ или _m_ не указать будет считаться первый либо последний 
элемент соответственно)

`print(list[-n])` - вывести _n_-ный элемент с конца.

`fdict.keys()` - вывести индексы массива _fdict_

`fdict.values()` - вывести значение элементов массива _fdict_

`fdict.items()` - вывести индексы со значением (полезно при использовании цикла (`for key, item in fdict.items()`)

**Элементом массива так же может быть и другой массив:**

```python
flist = ['one', 'two', 'three']
slist = [flist, 'four', 'five']
print(slist)
[['one', 'two', 'three'], 'four', 'five']
```

Вызов элементов внутреннего массива можно производить через двойной индекс `slist [0][0]`

#### Операции
**Python поддерживает:**
* весь набор арифметических операций
* весь набор логических операций
* конкатенацию строк, сравнение с эталоном, поиск подстроки

`string.find(word)` - поиск слова _word_ в строке _string_ (выведет номер элемента с которого начинается, в случае если не
будет найден выдаст -1)

`len(string)` - вывести длину строки или массива _string_

`str(var)` - преобразовать переменную в строку (если возможно)

`int(string)` - преобразовать строку в целое число (если возможно, у дробного числа будет обрезано значение после запятой)


##### Оператор условия
**Конструкция if-elif-else в Python имеет следующий синтаксис:**
```
if (условие):
  список действий
elif (условие):
  список действий
else:
  список действий
```

**⚠️В PYTHON ОТСТУПЫ ИМЕЮТ ЗНАЧЕНИЕ! ВСЕ ОТСТУПЫ (1 ИЛИ 2 ПРОБЕЛА, ТАБУЛЯЦИЯ) ДОЛЖНЫ БЫТЬ ВО ВСЕМ ПРОЕКТЕ ОДИНАКОВЫЕ!**

##### Циклы
**Существует два вида конструкций циклов:**
```python
sample=[0, 1, 2, 3, 4, 5, 6]
for i in sample:
  print(str(i)) #Выводим построчно значения элементовмассива
```
```python
a = 0
while a < 5:
  print(a) # Выводим значение переменной
  a += 1
```

### 4.2.3 Модули для работы с системой

#### Модуль sys
**Модуль обеспечивает доступ к некоторым функциям и переменным, которые взаимодействуют с интерпретатором:**

`import <module>` - подключить модуль

`sys.argv` - Возвращает список параметров, переданных скрипту (в 0 индексе путь к файлу, в 1 индексе вводимый аргумент)

`sys.exit()` - Возбуждает исключение SystemExit и завершает работу

`sys.platform` - Возвращает наименование ОС

`sys.getsizeof()` - Возвращает размер объекта в байтах

#### Модуль os
**Модуль позволяет взаимодействовать с ОС при помощи разнообразных функций:**

`os.getlogin()` - Возвращает логин текущего пользователя 

`os.getuid()` - Возвращает id текущего пользователя

`os.uname()` - Возвращает информацию о системе

`os.access(path, flag)` - Проверяет доступность файла (flag позволяет получить атрибуты)

`os.getcwd()` - Возвращает текущий каталог

`os.popen()` - Выполняет системную команду и позволяет записать вывод в переменную (вывод будет в виде wrapper чтобы 
получить вывод команды использовать `os.popen(<command>).read()`)

`os.makedirs(path)` - Создаёт директорию по всему пути

`os.truncate(path, length)` - Обрезает файл до указанной длины

`os.walk()` - Рекурсивно собирает информацию о файлах

#### Модуль socket
`socket.gethostbyname('google.com')` - получить IP адрес хоста

`socket.gethostbyname_ex('google.com')` - расширенный вывод (не одного, а всех адресов привязанных к dns)

### 4.2.4. Как написать первый скрипт?
**Примеры работы с файлами:**
```python
# Вариант через переменную (при некорректном завершении скрипта файл может остаться открытым)
file = open('file1.txt', 'w') # Открыть файл в переменную на запись (r на чтение, a на дописывание)
file.write('string') # Записать string в файл
file.close() # Закрыть файл

# другой вариант с использованием with:
with open('file1.txt', 'w') as file2:
    file2.write('new string')
```

`import this` - показать философию Python

Существует ряд основных **правил для формирования** правильного python-скрипта:
* Скрипт может начинаться с `#!/usr/bin/env python3`
* Стараться писать в соответствии с PEP8

## 4.3. Языки разметки JSON и YAML

### 4.3.1 Что такое языки разметки?
**Язык разметки** - способ получения отформатированного текста на основе просто текста:
* Яркий пример - HTML
* XML, как стандарт
* Появление NoSQL key-value хранилищ данных и использование JSON для выгрузки

### 4.3.2 Для чего они нужны в DevOps?
* Описание конфигураций серверов и шагов автоматизации, например Ansible, Puppet
* Работа с API Bitbucket, GitLab, GitHub, Nexus, Crowd, Jira, Confluence, etc.

### 4.3.3 Какие инструменты используются?
* Ansible - для описания всех структур данных
* Puppet (Hiera) - для описания конфигураций
* Azure - для построения Pipeline
* Docker (Compose) - для описания настройки сервисов, состоящих из нескольких контейнеров

### 4.3.4 Синтаксис JSON

#### Основа JSON
**JSON** - формат обмена данными, который легко читается “вживую”. 

Он **состоит из двух видов объектов**:
* Коллекции пар ключ-значение (key-value)
* Упорядоченный список значений (array)

#### Структура коллекции JSON
**Общая структура коллекции (объекта)** выглядит следующим образом:  
`{ ключ : значение }` где:
* Структура обязательно должна начинаться с `{` и заканчиваться на `}`
* Ключ - строковый тип, заключенный в двойные кавычки
* Значение может быть строкой, числом, массивом, объектом или иметь значение null, true или false
* Каждый элемент внутри структуры должен быть обособлен пробелом (горизонтальным табом, символом возврата каретки)

#### Структура массива JSON
**Общая структура упорядоченного списка значений (массива)** выглядит следующим образом:
`[ значение, значение ]`, где:
* Структура обязательно должна начинаться с `[` и заканчиваться на `]`
* Значение может быть строкой, числом, массивом, объектом или иметь значение null, true или false
* Каждый элемент внутри структуры должен быть обособлен пробелом (горизонтальным табом, символом возврата каретки)
* Массив может быть пустым, тогда его структура выглядит так: `[ ]`

#### Строки JSON
В оформлении строк необходимо пользоваться правилами:
* Строка должна быть заключена в кавычки
* Спецсимволы должны экранироваться символом \
* Список спецсимволов:
  * `\“`
  * `\\`
  * `\/`
  * `\b` - backspace
  * `\n` - переход на новую строку
  * `\f` - переход на новую страницу
  * `\r` - возврат каретки
  * `\t` - горизонтальный таб
  * `\u<четыре шестнадцатеричных цифры>` - юникод

#### Числа JSON
Числа представлены только в десятичном виде и в общем виде полная запись числа выглядит, как:

`[знак] [целая часть числа].[дробная часть числа][экспонента]`

Но нам, конечно же, никто не мешает упрощать форму до вида целых и дробных чисел

**Пример:**
```json
{ "company_name": "Toyota", "cars": [ "Yaris", "Corolla", "Camry", { "neme":  300, "wheel": 23 } ] }
```

### 4.3.5 Синтаксис YAML

#### Основа YAML
Формат обмена данных YAML понравится любителям Python, но сложно даётся его противникам. Постараемся определить 
основные правила формирования yml-файла:
* Файл должен начинаться с `---` и заканчиваться на `...`
* Каждый отдельный элемент коллекций стоит начинать с новой строчки
* Каждый элемент коллекции list (массив) стоит начинать с символов `- `(тире и пробел)
* Комментарии начинаются с символа `#`

#### Скаляры YAML
Скаляр, в случае с YAML, представляет собой единичный блок с информацией, которую можно записывать многострочно. 

Существует два вида скаляров:
```yaml
first: |
  Этот вид
  сохраняет все переходы на новую строку
second: >
  А этот
  преобразует каждый переход на новую строку
  в пробел
```
**Пример:**
```yaml
---
company_name: Toyota
cars:
  - Yaris
  - Corolla
  - Camry
  - name: 300
    wheel: 23
...
```
В рамках одного YAML файла можно описывать несколько структур:
```yaml
---
first_structure: |
  first line
  second line
...
---
secound_structure: >
  this
  is
  one
  line
...
```

#### Типы сущностей YAML
YAML поддерживает разнообразные типы данных. Например, целые числа могут быть:
```yaml
12345 #Каноничные
+1234 #Десятичные
0o14 #Восьмеричные
0xC #Шестнадцатеричные
```
Числа с плавающей запятой:
```yaml
1.2305e+3 #Каноничные
21.2355e+02 #Экспоненциальные
1.4 #С фиксированной запятой
+.inf #Бесконечность
.NaN #Не число
```
Тут же присутствуют и другие типы:
```yaml
null: #ноль
booleans: [ true, false ] #булево
string: ‘1234’ #строка
canon time: 2020-12-15T00:30:44.1Z #каноничное время
date: 2020-07-31 #дата
```

#### Коллекции YAML
По сути, это наборы данных в списке или словаре. Объявление списка имеет следующий синтаксис:
```yaml
- Java
- Python
- Groovy
```

Чтобы объявить словарь нужно использовать другую конструкцию:
```yaml
max: 100
min: 10
```
Конечно же, оба эти типа можно комбинировать и использовать в разных вариациях, так например очень часто встречаются
такие конструкции:
```yaml
- name: Python
type: language
default: true
using: [ localhost, 7.7.7.7 ]
```
**В YAML есть поддержка синтаксиса JSON**

### 4.3.6. Возможности преобразования

#### Библиотеки yaml и json
Самый простой способ конвертации форматов - использовать методы библиотек yaml и json для Python:
* Библиотека json входит в стандартную поставку Python 3.x
* Библиотеку yaml необходимо установить: python3 -m pip --user install pyyaml

#### Библиотека yaml
Библиотека позволяет загружать yaml-структуры, преобразуя их в стандартные объекты Python. В ней нас в первую очередь
интересуют следующие методы:
* `yaml.safe_load()` - получает строку с yaml на вход и преобразует в объекты, с которыми может работать Python
* `yaml.load_all()` - считывает данные из файла и разделяет их на несколько (используется в случае если в файле больше 
одного YAML документа)
* `yaml.dump()` - получает объекты python на вход и преобразует в строку с yaml

`yaml.dump(<var>,indent=2)` - в качестве индента (отступов) будет 2 пробела

#### Библиотека json
Библиотека позволяет загружать json-структуры, преобразуя их в стандартные объекты Python. В этой библиотеке нас
интересуют методы:
* `json.load()` - получает строку с json на вход и преобразует в объекты, с которыми может работать Python
* `json.dumps()` - получает объект python на вход и преобразует в строку с json
* `json.dump()` - получает объект python на вход и преобразует в json b записывает в файл

`json.dumps(<var>, indent=2)` - сформирует json с отступами, а не в одну строку

## Дополнительные материалы по блоку «Скриптовые языки и языки разметки: Python, Bash, YAML, JSON».
### Использование Python для решения типовых DevOps задач
* [Самоучитель по Python](https://pythonworld.ru/samouchitel-python)
### Языки разметки JSON и YAML
* [Документация по JSON](https://www.json.org/json-ru.html)
* [Документация по YAML](https://yaml.org/spec/1.2/spec.html)
* [Здесь больше про yaml в ansible, но тем не менее](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)
* [Как работать с YAML в Ruby](https://yaml.org/YAML_for_ruby.html)
* [Обучение обработки JSON через JavaScript](https://developer.mozilla.org/ru/docs/Learn/JavaScript/%D0%9E%D0%B1%D1%8A%D0%B5%D0%BA%D1%82%D1%8B/JSON)
* [Документация про библиотеку JSON](https://docs.python.org/3/library/json.html)
* [Документация про библиотеку YAML](https://pyyaml.org/wiki/PyYAMLDocumentation)