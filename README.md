# devops-netology
Hello World! 

Another line

# Задание №1 
 Описание /terraform/.gitignore (корневой директорией в данном описании считается /terraform)
 
# Игнорировать все файлы во всех поддиреториях с именем .terraform
**/.terraform/*

# Игнорировать файлы с расширением  tfstate, а так же у которых есть второе расширение после tfstate
*.tfstate
*.tfstate.*

# Игнорировать файл crash.log
crash.log

# Игнорировать все файлы с расширением tfvars
*.tfvars

# Игнорировать файлы override.tf, override.tf.json, а так же файлы которые заканчиваются на _override.tf и _override.tf.json  
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
#
# !example_override.tf
Раздел для исключения файлов из основных масок игнорирования

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*
Раздел для исключения файлов tfplan

# Игнорировать файлы .terraformrc и terraform.rc
.terraformrc
terraform.rc

# Добавленная новая строчка (Задание №3 дз 2.2)