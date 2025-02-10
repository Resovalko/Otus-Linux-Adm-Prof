# Файловые системы. ZFS.

## Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**  
### Конфигурация виртуальной машины
> Debian GNU/Linux 12 (bookworm)  
> CPU: x86-64-v2-AES  
> Sockets: 2  
> Memory: 1024  
> Hard disk 0: 32G  
> Hard disk 1: 1G  
> Hard disk 2: 1G  
> Hard disk 3: 1G  
> Hard disk 4: 1G  
> Hard disk 5: 1G  
> Hard disk 6: 1G  
> Hard disk 7: 1G  
> Hard disk 8: 1G  
> BIOS: SeaBIOS  
> Machine: i440fx  

Изначально имеющаяся структура блочных устройств:
> root@Otus-debian:~# lsblk
```
NAME                        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                           8:0    0   32G  0 disk
├─sda1                        8:1    0  487M  0 part /boot
├─sda2                        8:2    0    1K  0 part
└─sda5                        8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root   254:0    0 30.5G  0 lvm  /
  └─Otus--debian--vg-swap_1 254:1    0  976M  0 lvm  [SWAP]
sdb                           8:16   0    1G  0 disk
sdc                           8:32   0    1G  0 disk
sdd                           8:48   0    1G  0 disk
sde                           8:64   0    1G  0 disk
sdf                           8:80   0    1G  0 disk
sdg                           8:96   0    1G  0 disk
sdh                           8:112  0    1G  0 disk
sdi                           8:128  0    1G  0 disk
```

## работа с zfs 
### установка компонентов 

добавляем Backports — это репозиторий 
codename=$(lsb_release -cs);echo "deb http://deb.debian.org/debian $codename-backports main contrib non-free"|sudo tee -a /etc/apt/sources.list && sudo apt update

ставим необходимые компотненты
apt install -y linux-headers-$(uname -r) dkms zfs-dkms zfsutils-linux
Что означают эти пакеты:

linux-headers-$(uname -r) — заголовочные файлы ядра, необходимые для сборки модулей.
dkms — система для автоматической сборки и установки модулей ядра.
zfs-dkms — модуль ядра ZFS, собираемый через DKMS.
zfsutils-linux — утилиты управления ZFS.

првоеряем
root@Otus-debian:~# zfs --version
zfs-2.2.7-1~bpo12+1
zfs-kmod-2.2.7-1~bpo12+1

если надо подгружаем модуль
Загрузка модуля ZFS
ZFS может быть автоматически загружен, но для уверенности выполните:
root@Otus-debian:~# modprobe zfs
root@Otus-debian:~# lsmod | grep zfs
zfs                  5783552  0
spl                   135168  1 zfs

### создание пулов с разной степенью компрессии
сощздаем 4 пула raid1

root@Otus-debian:~# zpool create zfs_hw1 mirror /dev/sdb /dev/sdc
root@Otus-debian:~# zpool create zfs_hw2 mirror /dev/sdd /dev/sde
root@Otus-debian:~# zpool create zfs_hw3 mirror /dev/sdf /dev/sdg
root@Otus-debian:~# zpool create zfs_hw4 mirror /dev/sdh /dev/sdi

root@Otus-debian:~# zpool list
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zfs_hw1   960M   117K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw2   960M   112K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw3   960M   114K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw4   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
root@Otus-debian:~# zpool status
  pool: zfs_hw1
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        zfs_hw1     ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

errors: No known data errors

  pool: zfs_hw2
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        zfs_hw2     ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdd     ONLINE       0     0     0
            sde     ONLINE       0     0     0

errors: No known data errors

  pool: zfs_hw3
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        zfs_hw3     ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdf     ONLINE       0     0     0
            sdg     ONLINE       0     0     0

errors: No known data errors

  pool: zfs_hw4
 state: ONLINE
config:

        NAME        STATE     READ WRITE CKSUM
        zfs_hw4     ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdh     ONLINE       0     0     0
            sdi     ONLINE       0     0     0

настройки сжатия по умолчанию
root@Otus-debian:~# zfs get all | grep compression
zfs_hw1  compression           on                     default
zfs_hw2  compression           on                     default
zfs_hw3  compression           on                     default
zfs_hw4  compression           on                     default

#### Сравнение алгоритмов сжатия в ZFS
| **Алгоритм** | **Скорость сжатия** | **Скорость разжатия** | **Степень сжатия** | **Нагрузка на CPU** | **Идеальное использование** |
|--------------|---------------------|-----------------------|--------------------|---------------------|------------------------------|
| `lz4`        | Очень высокая       | Очень высокая         | Средняя            | Низкая              | Общие данные, виртуализация  |
| `gzip-1`     | Средняя             | Средняя               | Высокая            | Средняя             | Архивы, где нужна умеренная компрессия |
| `gzip-9`     | Низкая              | Низкая                | Очень высокая      | Высокая             | Архивирование, редко используемые файлы |
| `zle`        | Очень высокая       | Очень высокая         | Низкая (кроме нулевых данных) | Очень низкая | Виртуальные диски, sparse-файлы |
| `lzjb`       | Высокая             | Высокая               | Низкая             | Средняя             | Старые системы, резервная совместимость |

#### Рекомендации по выбору алгоритма:
1. **Для общих задач и серверов с высокими нагрузками** → lz4
(Оптимальный баланс между скоростью и степенью сжатия).
2. **Для архивов и бэкапов, где важен размер** → gzip-9
(Максимальная степень сжатия, но медленнее).
3. **Для больших файлов с нулями (виртуальные диски)** → zle
(Эффективен для sparse-файлов).
4. **Для старых систем или если нужно сохранить обратную совместимость** → lzjb
(Не рекомендуется для новых систем).

Добавим разные алгоритмы сжатия в каждую файловую систему:
root@Otus-debian:~# zfs set compression=lz4 zfs_hw1
root@Otus-debian:~# zfs set compression=gzip-9 zfs_hw2
root@Otus-debian:~# zfs set compression=zle zfs_hw3
root@Otus-debian:~# zfs set compression=lzjb zfs_hw4
root@Otus-debian:~# zfs get all | grep compression
zfs_hw1  compression           lz4                    local
zfs_hw2  compression           gzip-9                 local
zfs_hw3  compression           zle                    local
zfs_hw4  compression           lzjb                   local


Скачаем один и тот же текстовый файл во все пулы: 
for i in {1..4}; do wget -P /zfs_hw$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done



root@Otus-debian:~# ls -l /zfs_hw*
/zfs_hw1:
total 18006
-rw-r--r-- 1 root root 41123477 Feb  2 11:31 pg2600.converter.log

/zfs_hw2:
total 10966
-rw-r--r-- 1 root root 41123477 Feb  2 11:31 pg2600.converter.log

/zfs_hw3:
total 40188
-rw-r--r-- 1 root root 41123477 Feb  2 11:31 pg2600.converter.log

/zfs_hw4:
total 22096
-rw-r--r-- 1 root root 41123477 Feb  2 11:31 pg2600.converter.log


root@Otus-debian:~# zfs list
NAME      USED  AVAIL  REFER  MOUNTPOINT
zfs_hw1  17.7M   814M  17.6M  /zfs_hw1
zfs_hw2  10.9M   821M  10.7M  /zfs_hw2
zfs_hw3  39.4M   793M  39.3M  /zfs_hw3
zfs_hw4  21.7M   810M  21.6M  /zfs_hw4

root@Otus-debian:~# zfs get all | grep compres | grep -v ref
zfs_hw1  compressratio         2.23x                  -
zfs_hw1  compression           lz4                    local
zfs_hw2  compressratio         3.65x                  -
zfs_hw2  compression           gzip-9                 local
zfs_hw3  compressratio         1.00x                  -
zfs_hw3  compression           zle                    local
zfs_hw4  compressratio         1.81x                  -
zfs_hw4  compression           lzjb                   local

максимальное сжатие достугнуто на zfs_hw2 - gzip-9
минимальное - zfs_hw3 - zle








<!-- ## Изменение размера системного каталога _/_
Изначально имеющаяся структура блочных устройств:
> root@Otus-debian:~# lsblk
```
NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                           8:0    0   32G  0 disk
├─sda1                        8:1    0  487M  0 part  /boot
├─sda2                        8:2    0    1K  0 part
└─sda5                        8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root   253:2    0 30.5G  0 lvm   /
  └─Otus--debian--vg-swap_1 253:3    0  976M  0 lvm   [SWAP]
sdb                           8:16   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:0    0    1G  0 lvm
sdc                           8:32   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:0    0    1G  0 lvm
sdd                           8:48   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:0    0    1G  0 lvm
sde                           8:64   0    2G  0 disk
sdf                           8:80   0    2G  0 disk
sdg                           8:96   0    2G  0 disk
sdh                           8:112  0   10G  0 disk
sr0                          11:0    1 1024M  0 rom
```
> root@Otus-debian:~# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g 1016.00m
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g   44.00m
```
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g   44.00m
  lvmhomework      1   1   0 wz--n-   1.99g 1016.00m
```
> root@Otus-debian:~# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-a-----   1.00g
```
> root@Otus-debian:~# df -h
```
Filesystem                         Size  Used Avail Use% Mounted on
udev                               448M     0  448M   0% /dev
tmpfs                               97M 1008K   96M   2% /run
/dev/mapper/Otus--debian--vg-root   30G  5.1G   24G  18% /
tmpfs                              481M     0  481M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda1                          455M  144M  287M  34% /boot
tmpfs                               97M   40K   97M   1% /run/user/108
tmpfs                               97M   36K   97M   1% /run/user/1000
```

### Перенос системного каталога _/_ на временный том
Для временного расположения системного каталога **/** будет использован **/dev/sdh** размером 10Gb  

**Создаем Volume group и Logical volume** 
>root@Otus-debian:~# vgcreate vg_root /dev/sdh
```
  Physical volume "/dev/sdh" successfully created.
  Volume group "vg_root" successfully created
```
> root@Otus-debian:~# lvcreate -n lv_root -l +100%FREE /dev/vg_root
```
  Logical volume "lv_root" created.
```
> root@Otus-debian:~# mkfs.ext4 /dev/vg_root/lv_root
```
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 2620416 4k blocks and 655360 inodes
Filesystem UUID: 6ed4339f-7976-4a9f-9ac9-c2f354cc6dda
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

**Монтируем Logical volume** во временную директорию **/mnt/mnt_root/**  
> root@Otus-debian:/mnt# mount /dev/vg_root/lv_root /mnt/mnt_root/  

> root@Otus-debian:/mnt# df -h  
```
Filesystem                         Size  Used Avail Use% Mounted on
udev                               448M     0  448M   0% /dev
tmpfs                               97M 1012K   96M   2% /run
/dev/mapper/Otus--debian--vg-root   30G  5.1G   24G  18% /
tmpfs                              481M     0  481M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda1                          455M  144M  287M  34% /boot
tmpfs                               97M   40K   97M   1% /run/user/108
tmpfs                               97M   36K   97M   1% /run/user/1000
/dev/mapper/vg_root-lv_root        9.8G   24K  9.3G   1% /mnt/mnt_root
```

**Копируем данные системы из корневого каталога в /mnt/mnt_root**  
> root@Otus-debian:/mnt# rsync -avxHAX --progress / /mnt/mnt_root/  

... ждем завершения операции копирования
```
sent 4,973,158,024 bytes  received 2,556,397 bytes  77,142,859.24 bytes/sec
total size is 5,387,727,359  speedup is 1.08
```

Для системных каталогов:  
**/proc/** — виртуальная файловая система с информацией о процессах и состоянии ядра.  
**/sys/** — интерфейс для взаимодействия с ядром и устройствами.  
**/dev/** — устройства и псевдо-устройства (например, диски, терминалы).  
**/run/** — временные файлы и данные, нужные для работы служб после загрузки.  
**/boot/** — файлы для загрузки системы (ядро, initrd, grub).  
Создаем зеркальное отображение каталога каждого из вышеперечисленных каталогов в соответствующей директории в **/mnt/mnt_root/**
> root@Otus-debian:/mnt# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/mnt_root/$i; done  

**Основная система полностью продублирована на временном томе**  
Переходим в перемещенную систему  
> root@Otus-debian:/# chroot /mnt/mnt_root/  

**Вносим изменения** в загрузчик GRUB и начальный загрузочный образ, **что необходимо для правильной работы ядра при старте системы**  
> root@Otus-debian:/# grub-mkconfig -o /boot/grub/grub.cfg
```
Generating grub configuration file ...
Found background image: /usr/share/images/desktop-base/desktop-grub.png
Found linux image: /boot/vmlinuz-6.1.0-30-amd64
Found initrd image: /boot/initrd.img-6.1.0-30-amd64
Found linux image: /boot/vmlinuz-6.1.0-28-amd64
Found initrd image: /boot/initrd.img-6.1.0-28-amd64
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
done
```
> root@Otus-debian:/# update-initramfs -u
```
update-initramfs: Generating /boot/initrd.img-6.1.0-30-amd64
```
**Система подготовлена для загрузки и работы с временного тома, перезагружаем систему**  

### Перенос системного каталога _/_ обратно на исходный том с уменьшением его размера
После загрузки наблюдаем изменения: система загружена и работает с временного тома
> root@Otus-debian:~# lsblk
```
NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                           8:0    0   32G  0 disk
├─sda1                        8:1    0  487M  0 part  /boot
├─sda2                        8:2    0    1K  0 part
└─sda5                        8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root   253:0    0 30.5G  0 lvm
  └─Otus--debian--vg-swap_1 253:2    0  976M  0 lvm   [SWAP]
sdb                           8:16   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:3    0    1G  0 lvm
sdc                           8:32   0   10G  0 disk
└─vg_root-lv_root           253:1    0   10G  0 lvm   /
sdd                           8:48   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:3    0    1G  0 lvm
sde                           8:64   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  └─lvmhomework-part1       253:3    0    1G  0 lvm
sdf                           8:80   0    2G  0 disk
sdg                           8:96   0    2G  0 disk
sdh                           8:112  0    2G  0 disk
sr0                          11:0    1 1024M  0 rom
```
> root@Otus-debian:~# lvs
```
  LV      VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    Otus-debian-vg -wi-a-----  30.52g
  swap_1  Otus-debian-vg -wi-ao---- 976.00m
  part1   lvmhomework    -wi-a-----   1.00g
  lv_root vg_root        -wi-ao---- <10.00g
```
**Меняем размер исходного Logical volume** на которым ранее распологался системный каталог **/**  
Удаляем старый Logical volume и создаем новый меньшим размером  
> root@Otus-debian:~# lvremove Otus-debian-vg/root
```
Do you really want to remove active logical volume Otus-debian-vg/root? [y/n]: y
  Logical volume "root" successfully removed.
```
> root@Otus-debian:~# lvcreate -n root -L 10G Otus-debian-vg
```
WARNING: ext4 signature detected on /dev/Otus-debian-vg/root at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/Otus-debian-vg/root.
  Logical volume "root" created.
```
> root@Otus-debian:~# mkfs.ext4 /dev/Otus-debian-vg/root
```
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 2621440 4k blocks and 655360 inodes
Filesystem UUID: 59a04b64-eaa3-48a8-bda3-c0edd2c7374b
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
**Результат** Logical volume "root" размером 10Гб в исходной Volume group "Otus-debian-vg" на исходном томе  
> root@Otus-debian:~# lvs
```
  LV      VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    Otus-debian-vg -wi-a-----  10.00g
  swap_1  Otus-debian-vg -wi-ao---- 976.00m
  part1   lvmhomework    -wi-a-----   1.00g
  lv_root vg_root        -wi-ao---- <10.00g
```

**Повторяем процедуру переноса системного каталога**, но уже в обратную сторону - с веременного тома на исходный
> root@Otus-debian:~# mount /dev/Otus-debian-vg/root /mnt/mnt_root/  

> root@Otus-debian:~# rsync -avxHAX --progress / /mnt/mnt_root/  

> root@Otus-debian:~# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/mnt_root/$i; done  

> root@Otus-debian:~# chroot /mnt/mnt_root/  

> root@Otus-debian:/# grub-mkconfig -o /boot/grub/grub.cfg  
```
Generating grub configuration file ...
Found background image: /usr/share/images/desktop-base/desktop-grub.png
Found linux image: /boot/vmlinuz-6.1.0-30-amd64
Found initrd image: /boot/initrd.img-6.1.0-30-amd64
Found linux image: /boot/vmlinuz-6.1.0-28-amd64
Found initrd image: /boot/initrd.img-6.1.0-28-amd64
Warning: os-prober will not be executed to detect other bootable partitions.
Systems on them will not be added to the GRUB boot configuration.
Check GRUB_DISABLE_OS_PROBER documentation entry.
done
```
> root@Otus-debian:/# update-initramfs -u
```
update-initramfs: Generating /boot/initrd.img-6.1.0-30-amd64
```
**Система перенесена на исходный том**, но не переезагрузаемся а продолжаем работать и вынесем системный каталог **/var** на отдельный том с отдельной точкой монтирования

### Вынесем системный каталог /var на отдельный том с отдельной точкой монтирования
**Создаем Volume group и Logical volume с использованием LVM raid mirror**
>
root@Otus-debian:/# vgcreate Otus_var_vg /dev/sd{f,g}
```
  Physical volume "/dev/sdf" successfully created.
  Physical volume "/dev/sdg" successfully created.
  Volume group "Otus_var_vg" successfully created
```
> root@Otus-debian:/# lvcreate -l +100%FREE -m1 -n var_lv Otus_var_vg
```
  Logical volume "var_lv" created.
```
> root@Otus-debian:/# mkfs.ext4 /dev/Otus_var_vg/var_lv
```
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 522240 4k blocks and 130560 inodes
Filesystem UUID: f3688294-9b33-4bd1-9686-16aa2661741a
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```
**Результат** Logical volume "var_lv" в Volume group "Otus_var_vg" размером 2Гб в режиме "рейд"
> root@Otus-debian:/# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g 1016.00m
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  <20.57g
  /dev/sdc   vg_root        lvm2 a--  <10.00g       0
  /dev/sdf   Otus_var_vg    lvm2 a--   <2.00g       0
  /dev/sdg   Otus_var_vg    lvm2 a--   <2.00g       0
```
> root@Otus-debian:/# lvs
```
  LV      VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    Otus-debian-vg -wi-ao----  10.00g
  swap_1  Otus-debian-vg -wi-ao---- 976.00m
  var_lv  Otus_var_vg    rwi-aor---   1.99g                                    100.00
  part1   lvmhomework    -wi-a-----   1.00g
  lv_root vg_root        -wi-ao---- <10.00g
```
**Монтируем созданный Logical volume "var_lv"** во временную директорию и **перемещаем данные из оригинального каталога _/var_ в новый**
> root@Otus-debian:/# mount /dev/Otus_var_vg/var_lv /mnt/  

> root@Otus-debian:/# cp -aR /var/* /mnt/  

> root@Otus-debian:/# rm -r /var/*  

> root@Otus-debian:/# umount /mnt/  

**Монтируем перемещенные данные в оригинальный каталог _/var_**
> root@Otus-debian:/# mount /dev/Otus_var_vg/var_lv /var/  

> root@Otus-debian:/# df -h
```
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/Otus--debian--vg-root  9.8G  4.4G  4.9G  48% /
udev                               448M     0  448M   0% /dev
tmpfs                               97M  1.1M   96M   2% /run
/dev/sda1                          455M  144M  287M  34% /boot
/dev/mapper/Otus_var_vg-var_lv     2.0G  659M  1.2G  36% /var
```
**Добавляем монтирование при запуске системы**
> root@Otus-debian:/# echo "\`blkid | grep var_lv: | awk '{print $2}'\` /var ext4 defaults 0 0" >> /etc/fstab

**Перезагружаем систему и смотрим полученный результат**
- Системный раздел **/** имеет размер 10Гб, расположен на исходном томе
- Каталог **/var** вынесен на отдельный раздел и примонтирован
> root@Otus-debian:~# df -h
```
Filesystem                         Size  Used Avail Use% Mounted on
udev                               448M     0  448M   0% /dev
tmpfs                               97M  1.1M   96M   2% /run
/dev/mapper/Otus--debian--vg-root  9.8G  4.4G  4.9G  48% /
tmpfs                              481M     0  481M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda1                          455M  144M  287M  34% /boot
/dev/mapper/Otus_var_vg-var_lv     2.0G  659M  1.2G  36% /var
tmpfs                               97M   40K   97M   1% /run/user/108
tmpfs                               97M   36K   97M   1% /run/user/1000
```
>root@Otus-debian:~# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g 1016.00m
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  <20.57g
  /dev/sde   Otus_var_vg    lvm2 a--   <2.00g       0
  /dev/sdf   Otus_var_vg    lvm2 a--   <2.00g       0
  /dev/sdh   vg_root        lvm2 a--  <10.00g       0
```
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g  <20.57g
  Otus_var_vg      2   1   0 wz--n-   3.99g       0
  lvmhomework      1   1   0 wz--n-   1.99g 1016.00m
  vg_root          1   1   0 wz--n- <10.00g       0
```
> root@Otus-debian:~# lvs
```
  LV      VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root    Otus-debian-vg -wi-ao----  10.00g
  swap_1  Otus-debian-vg -wi-ao---- 976.00m
  var_lv  Otus_var_vg    rwi-aor---   1.99g                                    100.00
  part1   lvmhomework    -wi-a-----   1.00g
  lv_root vg_root        -wi-a----- <10.00g
```
> root@Otus-debian:~# lsblk
```
NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                             8:0    0   32G  0 disk
├─sda1                          8:1    0  487M  0 part  /boot
├─sda2                          8:2    0    1K  0 part
└─sda5                          8:5    0 31.5G  0 part
  ├─Otus--debian--vg-swap_1   253:0    0  976M  0 lvm   [SWAP]
  └─Otus--debian--vg-root     253:1    0   10G  0 lvm   /
sdb                             8:16   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  └─lvmhomework-part1         253:8    0    1G  0 lvm
sdc                             8:32   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  └─lvmhomework-part1         253:8    0    1G  0 lvm
sdd                             8:48   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  └─lvmhomework-part1         253:8    0    1G  0 lvm
sde                             8:64   0    2G  0 disk
├─Otus_var_vg-var_lv_rmeta_0  253:3    0    4M  0 lvm
│ └─Otus_var_vg-var_lv        253:7    0    2G  0 lvm   /var
└─Otus_var_vg-var_lv_rimage_0 253:4    0    2G  0 lvm
  └─Otus_var_vg-var_lv        253:7    0    2G  0 lvm   /var
sdf                             8:80   0    2G  0 disk
├─Otus_var_vg-var_lv_rmeta_1  253:5    0    4M  0 lvm
│ └─Otus_var_vg-var_lv        253:7    0    2G  0 lvm   /var
└─Otus_var_vg-var_lv_rimage_1 253:6    0    2G  0 lvm
  └─Otus_var_vg-var_lv        253:7    0    2G  0 lvm   /var
sdg                             8:96   0    2G  0 disk
sdh                             8:112  0   10G  0 disk
└─vg_root-lv_root             253:2    0   10G  0 lvm
sr0                            11:0    1 1024M  0 rom
```

**Удаляем временные Logical volume, Volume group, Physical volume**  
> root@Otus-debian:~# vgremove vg_root
```
Do you really want to remove volume group "vg_root" containing 1 logical volumes? [y/n]: y
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed.
  Volume group "vg_root" successfully removed
```
> root@Otus-debian:~# pvremove /dev/sdh
```
  Labels on physical volume "/dev/sdh" successfully wiped.
```
### Вынесем системный каталог /home с отдельной точкой монтирования 
**Создаем Logical volume** для директории **/home** и монтируем его во временную директорию
> root@Otus-debian:~# lvcreate -n home -L 2G Otus-debian-vg
```
  Logical volume "home" created.
```
> root@Otus-debian:~# mkfs.ext4 /dev/Otus-debian-vg/home
```
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 524288 4k blocks and 131072 inodes
Filesystem UUID: fc913ece-79a2-4fdc-91f0-65ee54a0c125
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```
> root@Otus-debian:~# mount /dev/Otus-debian-vg/home /mnt/mnt_home/

**Перемещаем данные из оригинального каталога _/home_ в новый** и перемонтируем Logical volume из временной директории в оригинальную директорию _/home_ 
> root@Otus-debian:~# cp -aR /home/* /mnt/mnt_home/  

> root@Otus-debian:~# rm -rf /home/*  

> root@Otus-debian:~# umount /mnt/mnt_home  

> root@Otus-debian:~# mount /dev/Otus-debian-vg/home /home/  

**Добавляем монтирование при запуске системы**
> root@Otus-debian:~# echo "\`blkid | grep home: | awk '{print $2}'\` /home ext4 defaults 0 0" >> /etc/fstab

## Итоговый результат и состояние системы после всех проделанных действий
- Размер системного раздела **/** уменьшен с 32Гб до 10Гб, расположен на исходном томе
- Каталог **/var** вынесен на отдельный раздел и примонтирован
- Каталог **/home** вынесен на отдельный Logical volume и примонтирован
> root@Otus-debian:~# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g 1016.00m
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  <18.57g
  /dev/sde   Otus_var_vg    lvm2 a--   <2.00g       0
  /dev/sdf   Otus_var_vg    lvm2 a--   <2.00g       0
```
> root@Otus-debian:~# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home   Otus-debian-vg -wi-ao----   2.00g
  root   Otus-debian-vg -wi-ao----  10.00g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  var_lv Otus_var_vg    rwi-aor---   1.99g                                    100.00
  part1  lvmhomework    -wi-a-----   1.00g
```
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   3   0 wz--n- <31.52g  <18.57g
  Otus_var_vg      2   1   0 wz--n-   3.99g       0
  lvmhomework      1   1   0 wz--n-   1.99g 1016.00m
```
> root@Otus-debian:~# df -h
```
Filesystem                         Size  Used Avail Use% Mounted on
udev                               448M     0  448M   0% /dev
tmpfs                               97M  1.1M   96M   2% /run
/dev/mapper/Otus--debian--vg-root  9.8G  4.4G  5.0G  47% /
tmpfs                              481M     0  481M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda1                          455M  144M  287M  34% /boot
/dev/mapper/Otus_var_vg-var_lv     2.0G  659M  1.2G  36% /var
tmpfs                               97M   40K   97M   1% /run/user/108
tmpfs                               97M   36K   97M   1% /run/user/1000
/dev/mapper/Otus--debian--vg-home  2.0G   46M  1.8G   3% /home
``` -->