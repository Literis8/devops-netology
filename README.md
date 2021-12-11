# Домашнее задание к занятию "3.5. Файловые системы"
## 1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.
### Ответ:
Узнал. Данное решение хорошо подходит для использования с виртуальными дисками на гостевой машины, загружаемых файлов,
которые загружаются частями (например torrent), а так же других крупных файлов. Фактически метод сжатия на уровне 
файловой системы.
## 2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?
### Ответ:
Не могут, так как жесткие ссылки ссылаются на одну inode в которой и содержится информация о правах и владельце.
## 3. Сделайте vagrant destroy на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:
```vagrant
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provider :virtualbox do |vb|
    lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
    lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
    vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
    vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
  end
end
```
### Ответ:
Выполнено:
```shell
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
sdc                    8:32   0  2.5G  0 disk
```
## 4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.
### Ответ:
```shell
vagrant@vagrant:~$ sudo fdisk /dev/sdb

Welcome to fdisk (util-linux 2.34).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x8b52d080.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p):

Using default response p.
Partition number (1-4, default 1):
First sector (2048-5242879, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2):
First sector (4196352-5242879, default 4196352):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879):

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
└─sdb2                 8:18   0  511M  0 part
sdc                    8:32   0  2.5G  0 disk
```
## 5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.
### Решение:
```shell
vagrant@vagrant:~$ sudo sfdisk -d /dev/sdb | sudo sfdisk /dev/sdc
Checking that no-one is using this disk right now ... OK

Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes

>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Script header accepted.
>>> Created a new DOS disklabel with disk identifier 0x8b52d080.
/dev/sdc1: Created a new partition 1 of type 'Linux' and of size 2 GiB.
/dev/sdc2: Created a new partition 2 of type 'Linux' and of size 511 MiB.
/dev/sdc3: Done.

New situation:
Disklabel type: dos
Disk identifier: 0x8b52d080

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdc1          2048 4196351 4194304    2G 83 Linux
/dev/sdc2       4196352 5242879 1046528  511M 83 Linux

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
└─sdb2                 8:18   0  511M  0 part
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
└─sdc2                 8:34   0  511M  0 part
```
## 6. Соберите mdadm RAID1 на паре разделов 2 Гб.
### Решение:
```shell
vagrant@vagrant:~$ sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sd[bc]1
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
```
## 7. Соберите mdadm RAID0 на второй паре маленьких разделов.
### Решение:
```shell
vagrant@vagrant:~$ sudo mdadm --create /dev/md1 --level=0 --raid-devices=2 /dev/sd[bc]2
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
```
## 8. Создайте 2 независимых PV на получившихся md-устройствах.
###Решение:
```shell
vagrant@vagrant:~$ sudo pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
vagrant@vagrant:~$ sudo pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
vagrant@vagrant:~$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda5
  VG Name               vgvagrant
  PV Size               <63.50 GiB / not usable 0
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              16255
  Free PE               0
  Allocated PE          16255
  PV UUID               Mx3LcA-uMnN-h9yB-gC2w-qm7w-skx0-OsTz9z

  "/dev/md0" is a new physical volume of "<2.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/md0
  VG Name
  PV Size               <2.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               cPSIPK-sdej-3cvC-QZpH-5VGc-8d6l-FNUiTK

  "/dev/md1" is a new physical volume of "1018.00 MiB"
  --- NEW Physical volume ---
  PV Name               /dev/md1
  VG Name
  PV Size               1018.00 MiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               IL0if2-eegW-ffwu-nemu-ot0q-bfKY-cfq3dE
```
## 9. Создайте общую volume-group на этих двух PV.
### Решение:
```shell
vagrant@vagrant:~$ sudo vgcreate VG_0 /dev/md0 /dev/md1
  Volume group "VG_0" successfully created
vagrant@vagrant:~$ sudo pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0   VG_0      lvm2 a--    <2.00g   <2.00g
  /dev/md1   VG_0      lvm2 a--  1016.00m 1016.00m
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
vagrant@vagrant:~$
```
## 10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
### Решение:
```shell
vagrant@vagrant:~$ sudo lvcreate -L 100M VG_0 /dev/md1
  Logical volume "lvol0" created.
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─VG_0-lvol0     253:2    0  100M  0 lvm
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─VG_0-lvol0     253:2    0  100M  0 lvm
```

## 11. Создайте `mkfs.ext4` ФС на получившемся LV.
### Решение:
```shell
vagrant@vagrant:~$ sudo mkfs.ext4 /dev/VG_0/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done

vagrant@vagrant:~$ lsblk -f
NAME                 FSTYPE            LABEL     UUID                                   FSAVAIL FSUSE% MOUNTPOINT
sda
├─sda1               vfat                        7D3B-6BE4                                 511M     0% /boot/efi
├─sda2
└─sda5               LVM2_member                 Mx3LcA-uMnN-h9yB-gC2w-qm7w-skx0-OsTz9z
  ├─vgvagrant-root   ext4                        b527b79c-7f45-4e2b-a90f-1a4e9cb477c2     56.7G     2% /
  └─vgvagrant-swap_1 swap                        fad91b1f-6eed-4e4b-8dbf-913ba5bcacc7                  [SWAP]
sdb
├─sdb1               linux_raid_member vagrant:0 790ec814-2041-8b88-ef6e-3a55ad29ea03
│ └─md0              LVM2_member                 cPSIPK-sdej-3cvC-QZpH-5VGc-8d6l-FNUiTK
└─sdb2               linux_raid_member vagrant:1 03a0880a-402f-91b6-ab2c-228144cf2203
  └─md1              LVM2_member                 IL0if2-eegW-ffwu-nemu-ot0q-bfKY-cfq3dE
    └─VG_0-lvol0     ext4                        9fa5bcca-5c3c-40cf-b6aa-2ab77311620c
sdc
├─sdc1               linux_raid_member vagrant:0 790ec814-2041-8b88-ef6e-3a55ad29ea03
│ └─md0              LVM2_member                 cPSIPK-sdej-3cvC-QZpH-5VGc-8d6l-FNUiTK
└─sdc2               linux_raid_member vagrant:1 03a0880a-402f-91b6-ab2c-228144cf2203
  └─md1              LVM2_member                 IL0if2-eegW-ffwu-nemu-ot0q-bfKY-cfq3dE
    └─VG_0-lvol0     ext4                        9fa5bcca-5c3c-40cf-b6aa-2ab77311620c
```

## 12. Смонтируйте этот раздел в любую директорию, например, /tmp/new
### Решение:
```shell
vagrant@vagrant:~$ sudo mkdir /mnt/VG_0-lvol0
vagrant@vagrant:~$ sudo mount /dev/VG_0/lvol0 /mnt/VG_0-lvol0/
vagrant@vagrant:~$ df -h
Filesystem                  Size  Used Avail Use% Mounted on
udev                        447M     0  447M   0% /dev
tmpfs                        99M  708K   98M   1% /run
/dev/mapper/vgvagrant-root   62G  1.6G   57G   3% /
tmpfs                       491M     0  491M   0% /dev/shm
tmpfs                       5.0M     0  5.0M   0% /run/lock
tmpfs                       491M     0  491M   0% /sys/fs/cgroup
/dev/sda1                   511M  4.0K  511M   1% /boot/efi
vagrant                     932G  931G  982M 100% /vagrant
tmpfs                        99M     0   99M   0% /run/user/1000
/dev/mapper/VG_0-lvol0       93M   72K   86M   1% /mnt/VG_0-lvol0
```

## 13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
### Решение:
```shell
vagrant@vagrant:~$ sudo wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /mnt/VG_0-lvol0/test.gz
--2021-12-11 15:08:46--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22719572 (22M) [application/octet-stream]
Saving to: ‘/mnt/VG_0-lvol0/test.gz’

/mnt/VG_0-lvol0/test.gz                100%[===========================================================================>]  21.67M   674KB/s    in 19s

2021-12-11 15:09:05 (1.16 MB/s) - ‘/mnt/VG_0-lvol0/test.gz’ saved [22719572/22719572]

```
## 14. Прикрепите вывод `lsblk`.
### Ответ:
```shell
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─VG_0-lvol0     253:2    0  100M  0 lvm   /mnt/VG_0-lvol0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─VG_0-lvol0     253:2    0  100M  0 lvm   /mnt/VG_0-lvol0
```
## 15. Протестируйте целостность файла:
```shell
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```
### Ответ:
```shell
vagrant@vagrant:~$ gzip -t /mnt/VG_0-lvol0/test.gz
vagrant@vagrant:~$ echo $?
0
```
## 16. Используя `pvmove`, переместите содержимое PV с RAID0 на RAID1
### Решение:
```shell
vagrant@vagrant:~$ sudo pvmove /dev/md1 /dev/md0
  /dev/md1: Moved: 12.00%
  /dev/md1: Moved: 100.00%
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─VG_0-lvol0     253:2    0  100M  0 lvm   /mnt/VG_0-lvol0
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
│   └─VG_0-lvol0     253:2    0  100M  0 lvm   /mnt/VG_0-lvol0
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
```
## 17. Сделайте --fail на устройство в вашем RAID1 md.
### Решение:
```shell
vagrant@vagrant:~$ sudo mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
vagrant@vagrant:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10]
md1 : active raid0 sdc2[1] sdb2[0]
      1042432 blocks super 1.2 512k chunks

md0 : active raid1 sdc1[1] sdb1[0](F)
      2094080 blocks super 1.2 [2/1] [_U]

unused devices: <none>
```
## 18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
### Решение:
```shell
vagrant@vagrant:~$ dmesg | grep raid
[    2.615075] raid6: avx2x4   gen() 31723 MB/s
[    2.663104] raid6: avx2x4   xor() 19388 MB/s
[    2.711168] raid6: avx2x2   gen() 28425 MB/s
[    2.759086] raid6: avx2x2   xor() 17257 MB/s
[    2.807120] raid6: avx2x1   gen() 22849 MB/s
[    2.855095] raid6: avx2x1   xor() 15922 MB/s
[    2.903200] raid6: sse2x4   gen() 13190 MB/s
[    2.951089] raid6: sse2x4   xor()  8122 MB/s
[    2.999090] raid6: sse2x2   gen() 11311 MB/s
[    3.047077] raid6: sse2x2   xor()  7030 MB/s
[    3.095282] raid6: sse2x1   gen()  9943 MB/s
[    3.143121] raid6: sse2x1   xor()  5577 MB/s
[    3.143122] raid6: using algorithm avx2x4 gen() 31723 MB/s
[    3.143123] raid6: .... xor() 19388 MB/s, rmw enabled
[    3.143124] raid6: using avx2x2 recovery algorithm
[  540.768266] md/raid1:md0: not clean -- starting background reconstruction
[  540.768268] md/raid1:md0: active with 2 out of 2 mirrors
[ 7050.004211] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```

## 19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:
```shell
root@vagrant:~# gzip -t /tmp/new/test.gz
root@vagrant:~# echo $?
0
```
### Решение:
```shell
vagrant@vagrant:~$ gzip -t /mnt/VG_0-lvol0/test.gz
vagrant@vagrant:~$ echo $?
0
```

## 20. Погасите тестовый хост, `vagrant destroy`.
### Решение:
```
PS E:\devops\devops-netology\vagrant> vagrant.exe destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
```