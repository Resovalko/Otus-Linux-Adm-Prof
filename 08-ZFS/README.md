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

## Работа с ZFS 
### Установка необходимых компонентов 
Добавляем репозиторий Backports в систему
> codename=$(lsb_release -cs);echo "deb http://deb.debian.org/debian $codename-backports main contrib non-free"|sudo tee -a /etc/apt/sources.list && sudo apt update  

Устанавливаем компотненты необходимые для работы с **ZFS**
> apt install -y linux-header/s-$(uname -r) dkms zfs-dkms zfsutils-linux  
- **linux-headers-$(uname -r)** — заголовочные файлы ядра, необходимые для сборки модулей
- **dkms** — система для автоматической сборки и установки модулей ядра
- **zfs-dkms** — модуль ядра ZFS, собираемый через DKMS
- **zfsutils-linux** — утилиты управления ZFS  

Загрузка **модуля ZFS** (может быть автоматически загружен)
> root@Otus-debian:~# modprobe zfs  

Проверяем что модуль загружен
> root@Otus-debian:~# lsmod | grep zfs
```
zfs                  5783552  0
spl                   135168  1 zfs
```
Првоеряем доступность утилит **ZFS**
> root@Otus-debian:~# zfs --version
```
zfs-2.2.7-1~bpo12+1
zfs-kmod-2.2.7-1~bpo12+1
```
### Cоздание пулов с разной степенью компрессии данных
Создаем 4 пула **RAID1** (зеркало):
> root@Otus-debian:~# zpool create zfs_hw1 mirror /dev/sdb /dev/sdc  

> root@Otus-debian:~# zpool create zfs_hw2 mirror /dev/sdd /dev/sde  

> root@Otus-debian:~# zpool create zfs_hw3 mirror /dev/sdf /dev/sdg  

> root@Otus-debian:~# zpool create zfs_hw4 mirror /dev/sdh /dev/sdi  

Посмотрим список пулов:
> root@Otus-debian:~# zpool list
```
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zfs_hw1   960M   117K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw2   960M   112K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw3   960M   114K   960M        -         -     0%     0%  1.00x    ONLINE  -
zfs_hw4   960M   108K   960M        -         -     0%     0%  1.00x    ONLINE  -
```
Посмотрим состояние пулов:
> root@Otus-debian:~# zpool status
```
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
```

Посмотрим какие настройки компресси у пулов по умолчанию:
> root@Otus-debian:~# zfs get all | grep compression
```
zfs_hw1  compression           on                     default
zfs_hw2  compression           on                     default
zfs_hw3  compression           on                     default
zfs_hw4  compression           on                     default
```

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
> root@Otus-debian:~# zfs set compression=lz4 zfs_hw1 

> root@Otus-debian:~# zfs set compression=gzip-9 zfs_hw2  

> root@Otus-debian:~# zfs set compression=zle zfs_hw3  

> root@Otus-debian:~# zfs set compression=lzjb zfs_hw4  

> root@Otus-debian:~# zfs get all | grep compression  
```
zfs_hw1  compression           lz4                    local
zfs_hw2  compression           gzip-9                 local
zfs_hw3  compression           zle                    local
zfs_hw4  compression           lzjb                   local
```

Скачаем один и тот же текстовый файл во все пулы: 
> root@Otus-debian:~# for i in {1..4}; do wget -P /zfs_hw$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done  

Посмотрим на результат скачивания:
> root@Otus-debian:~# ls -l /zfs_hw*  
```
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
```
Посмотрим информацию о пулах и файловых системах:
> root@Otus-debian:~# zfs list
```
NAME      USED  AVAIL  REFER  MOUNTPOINT
zfs_hw1  17.7M   814M  17.6M  /zfs_hw1
zfs_hw2  10.9M   821M  10.7M  /zfs_hw2
zfs_hw3  39.4M   793M  39.3M  /zfs_hw3
zfs_hw4  21.7M   810M  21.6M  /zfs_hw4
```

Выведем информацию о компрессии на каждом из пулов:
> root@Otus-debian:~# zfs get all | grep compres | grep -v ref
```
zfs_hw1  compressratio         2.23x                  -
zfs_hw1  compression           lz4                    local
zfs_hw2  compressratio         3.65x                  -
zfs_hw2  compression           gzip-9                 local
zfs_hw3  compressratio         1.00x                  -
zfs_hw3  compression           zle                    local
zfs_hw4  compressratio         1.81x                  -
zfs_hw4  compression           lzjb                   local
```
**Максимальное сжатие** достугнуто на пуле с именем **zfs_hw2** и типом сжатия **gzip-9**  
**Минимально сжатие** получилось на пуле с именем **zfs_hw3** и типом сжатия **zle** 

### Определение настроек пула

Скачиваем и распаковываем архив: 
> root@Otus-debian:~/otus# wget -O archive.tar.gz --no-check-certificate '\https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'\
```
--2025-02-10 12:09:45--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 142.250.150.132
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|142.250.150.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/octet-stream]
Saving to: ‘archive.tar.gz’

archive.tar.gz                    100%[===========================================================>]   6.94M  3.58MB/s    in 1.9s

2025-02-10 12:09:54 (3.58 MB/s) - ‘archive.tar.gz’ saved [7275140/7275140]
```

Разархивируем:
> root@Otus-debian:~/otus# tar -xzvf archive.tar.gz
```
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```
Перед импортом проверим, какие пулы доступны:
> root@Otus-debian:~/otus# zpool import -d zpoolexport/
```
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                              ONLINE
          mirror-0                        ONLINE
            /root/otus/zpoolexport/filea  ONLINE
            /root/otus/zpoolexport/fileb  ONLINE
```
- **zpool import** — команда для импорта существующего ZFS-пула в систему
- **-d zpoolexport/** — указывает директорию, где искать устройства (диски), содержащие пул

**Импортируем пул** и смотрим информацию об импортированном пуле:
> root@Otus-debian:~/otus# zpool import -d zpoolexport/ otus  

>root@Otus-debian:~/otus# zpool status
```
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                              STATE     READ WRITE CKSUM
        otus                              ONLINE       0     0     0
          mirror-0                        ONLINE       0     0     0
            /root/otus/zpoolexport/filea  ONLINE       0     0     0
            /root/otus/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors
```

Посмотрим все свойства (импортированного) пула с именем **otus**:
> root@Otus-debian:~/otus# zfs get all otus
```
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  7:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              on                     default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
otus  prefetch              all                    default
```

Выборочно может посмотреть (вывести) отдельные параметры:
> root@Otus-debian:~/otus# zfs get available otus
```
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -
```
> root@Otus-debian:~/otus# zfs get recordsize otus
```
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local
```
> root@Otus-debian:~/otus# zfs get checksum otus
```
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```
> root@Otus-debian:~/otus# zfs get compressratio otus
```
NAME  PROPERTY       VALUE  SOURCE
otus  compressratio  1.00x  -
```
> root@Otus-debian:~/otus# zfs get compress otus
```
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local
```

### Работа со снапшотами

Скачиваем файл снапшота из задания:
> root@Otus-debian:~/otus# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download

Восстанавливаем файловую систему из снапшота:
> root@Otus-debian:~/otus# zfs receive zfs_hw2/test@today < otus_task2.file  

- **zfs receive** — команда для получения данных и восстановления файловой системы или снимка из потока данных (обычно переданного через zfs send)  
- **zfs_hw2/test@today** — это целевая файловая система **zfs_hw2/test** и её снимок с именем **today**, в который будут восстановлены данные  
- **< otus_task2.file** — указывает, что данные для восстановления будут взяты из файла **otus_task2.file**  

1. Будет создан снимок **zfs_hw2/test@today**  
2. Все данные из **otus_task2.file** будут восстановлены в файловую систему **zfs_hw2/test**  

Посмотрим список снапшотов:
> root@Otus-debian:~/otus# zfs list -t snapshot
```
NAME                     USED  AVAIL  REFER  MOUNTPOINT
zfs_hw2/test@today         0B      -  2.22M  -
```
Посмотрим содержимое пула найдем интересующий файл и выведем его содержимое:
> root@Otus-debian:~/otus# ls /zfs_hw2/test  
```
10M.file  cinderella.tar  for_examaple.txt  homework4.txt  Limbo.txt  Moby_Dick.txt  task1  War_and_Peace.txt  world.sql
```
> root@Otus-debian:~/otus# find /zfs_hw2/test -name "secret_message"
```
/zfs_hw2/test/task1/file_mess/secret_message
```
> root@Otus-debian:~/otus# cat /zfs_hw2/test/task1/file_mess/secret_message
```
https://otus.ru/lessons/linux-hl/
```