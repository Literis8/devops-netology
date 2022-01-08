# Курсовая работа по итогам модуля "DevOps и системное администрирование"
## 1. Создайте виртуальную машину Linux.
### Решение:
Создана виртуальная машина через Vagrant на дистрибутиве bento/ubuntu-20.04, с публичным сетевым интерфейсом
## 2. Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.
### Решение:
```shell
vagrant@vagrant:~$ sudo ufw allow 443/tcp
Rules updated
Rules updated (v6)

vagrant@vagrant:~$ sudo ufw allow 22/tcp
Rules updated
Rules updated (v6)

vagrant@vagrant:~$ sudo ufw enable
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
vagrant@vagrant:~$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
443/tcp                    ALLOW IN    Anywhere
22/tcp                     ALLOW IN    Anywhere
443/tcp (v6)               ALLOW IN    Anywhere (v6)
22/tcp (v6)                ALLOW IN    Anywhere (v6)

```
## 3. Установите hashicorp vault ([инструкция по ссылке](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started#install-vault)).
### Решение:
```shell
vagrant@vagrant:~$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
OK
vagrant@vagrant:~$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease [108 kB]
Get:4 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:5 http://archive.ubuntu.com/ubuntu focal-updates/main i386 Packages [581 kB]
Get:6 http://security.ubuntu.com/ubuntu focal-security/main i386 Packages [351 kB]
Get:7 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [1,109 kB]
Get:8 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [1,445 kB]
Get:9 https://apt.releases.hashicorp.com focal InRelease [9,495 B]
Get:10 https://apt.releases.hashicorp.com focal/main amd64 Packages [41.2 kB]
Get:11 http://archive.ubuntu.com/ubuntu focal-updates/main Translation-en [289 kB]
Get:12 http://archive.ubuntu.com/ubuntu focal-updates/restricted i386 Packages [21.8 kB]
Get:13 http://security.ubuntu.com/ubuntu focal-security/main Translation-en [202 kB]
Get:14 http://security.ubuntu.com/ubuntu focal-security/restricted i386 Packages [20.5 kB]
Get:15 http://archive.ubuntu.com/ubuntu focal-updates/restricted amd64 Packages [663 kB]
Get:16 http://archive.ubuntu.com/ubuntu focal-updates/restricted Translation-en [94.6 kB]
Get:17 http://security.ubuntu.com/ubuntu focal-security/restricted amd64 Packages [609 kB]
Get:18 http://archive.ubuntu.com/ubuntu focal-updates/universe i386 Packages [662 kB]
Get:19 http://security.ubuntu.com/ubuntu focal-security/restricted Translation-en [86.8 kB]
Get:20 http://security.ubuntu.com/ubuntu focal-security/universe amd64 Packages [675 kB]
Get:21 http://archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [892 kB]
Get:22 http://archive.ubuntu.com/ubuntu focal-updates/universe Translation-en [195 kB]
Get:23 http://archive.ubuntu.com/ubuntu focal-updates/multiverse i386 Packages [8,432 B]
Get:24 http://archive.ubuntu.com/ubuntu focal-updates/multiverse amd64 Packages [24.8 kB]
Get:25 http://archive.ubuntu.com/ubuntu focal-updates/multiverse Translation-en [6,928 B]
Get:26 http://archive.ubuntu.com/ubuntu focal-backports/main i386 Packages [34.5 kB]
Get:27 http://archive.ubuntu.com/ubuntu focal-backports/main amd64 Packages [42.0 kB]
Get:28 http://archive.ubuntu.com/ubuntu focal-backports/main Translation-en [10.0 kB]
Get:29 http://archive.ubuntu.com/ubuntu focal-backports/universe i386 Packages [10.9 kB]
Get:30 http://archive.ubuntu.com/ubuntu focal-backports/universe amd64 Packages [19.2 kB]
Get:31 http://archive.ubuntu.com/ubuntu focal-backports/universe Translation-en [13.3 kB]
Get:32 http://security.ubuntu.com/ubuntu focal-security/universe i386 Packages [532 kB]
Get:33 http://security.ubuntu.com/ubuntu focal-security/universe Translation-en [114 kB]
Get:34 http://security.ubuntu.com/ubuntu focal-security/multiverse amd64 Packages [21.8 kB]
Get:35 http://security.ubuntu.com/ubuntu focal-security/multiverse i386 Packages [7,176 B]
Get:36 http://security.ubuntu.com/ubuntu focal-security/multiverse Translation-en [4,948 B]
Fetched 9,132 kB in 15s (602 kB/s)
Reading package lists... Done
vagrant@vagrant:~$ sudo apt-get update && sudo apt-get install vault
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:2 http://archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:3 http://archive.ubuntu.com/ubuntu focal-backports InRelease
Get:4 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Hit:5 https://apt.releases.hashicorp.com focal InRelease
Fetched 114 kB in 1s (120 kB/s)
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  vault
0 upgraded, 1 newly installed, 0 to remove and 109 not upgraded.
Need to get 69.4 MB of archives.
After this operation, 188 MB of additional disk space will be used.
Get:1 https://apt.releases.hashicorp.com focal/main amd64 vault amd64 1.9.2 [69.4 MB]
Fetched 69.4 MB in 7s (9,517 kB/s)
Selecting previously unselected package vault.
(Reading database ... 41969 files and directories currently installed.)
Preparing to unpack .../archives/vault_1.9.2_amd64.deb ...
Unpacking vault (1.9.2) ...
Setting up vault (1.9.2) ...
Generating Vault TLS key and self-signed certificate...
Generating a RSA private key
.............................++++
.......................................................................................................++++
writing new private key to 'tls.key'
-----
Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
vagrant@vagrant:~$ vault
Usage: vault <command> [args]

Common commands:
    read        Read data and retrieves secrets
    write       Write data, configuration, and secrets
    delete      Delete secrets and configuration
    list        List data or secrets
    login       Authenticate locally
    agent       Start a Vault agent
    server      Start a Vault server
    status      Print seal and HA status
    unwrap      Unwrap a wrapped secret

Other commands:
    audit          Interact with audit devices
    auth           Interact with auth methods
    debug          Runs the debug command
    kv             Interact with Vault's Key-Value storage
    lease          Interact with leases
    monitor        Stream log messages from a Vault server
    namespace      Interact with namespaces
    operator       Perform operator-specific tasks
    path-help      Retrieve API help for paths
    plugin         Interact with Vault plugins and catalog
    policy         Interact with policies
    print          Prints runtime configurations
    secrets        Interact with secrets engines
    ssh            Initiate an SSH session
    token          Interact with tokens

```
## 4. Cоздайте центр сертификации по инструкции ([ссылка](https://learn.hashicorp.com/tutorials/vault/pki-engine?in=vault/secrets-management)) и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).
