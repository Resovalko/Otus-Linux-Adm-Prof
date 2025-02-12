# NFS

## Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**  
### Конфигурация виртуальной машины (сервер NFS)
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

### Конфигурация виртуальной машины (клиент NFS)
> Ubuntu 22.04.5 LTS x86_64 Desktop
> CPU: host (Intel i7-7700)  
> Sockets: 4  
> Memory: 4096  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

## Настраиваем сервер NFS

Устанавливаем необходимые модули (если отсутствуют):  
> root@Otus-debian:~/otus# apt install nfs-kernel-server rpcbind

Проверяем прослушиваются ли необходимые порты службы **NFS** (2049/udp, 2049/tcp,111/udp, 111/tcp):  
> root@Otus-debian:/# netstat -tupln | awk 'NR==2 || /:111|:2049/'
```
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      1/init
tcp        0      0 0.0.0.0:2049            0.0.0.0:*               LISTEN      -
tcp6       0      0 :::111                  :::*                    LISTEN      1/init
tcp6       0      0 :::2049                 :::*                    LISTEN      -
udp        0      0 0.0.0.0:111             0.0.0.0:*                           1/init
udp6       0      0 :::111                  :::*                                1/init
```
Усли утилита **netstat** в системе не установлена используем **ss**:  
> root@Otus-debian:/# ss -tupln | awk 'NR==1 || /:111|:2049/'
```
Netid State  Recv-Q Send-Q                     Local Address:Port  Peer Address:PortProcess                                  
udp   UNCONN 0      0                                0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=5011,fd=5),("systemd",pid=1,fd=126))
udp   UNCONN 0      0                                   [::]:111           [::]:*    users:(("rpcbind",pid=5011,fd=7),("systemd",pid=1,fd=128))
tcp   LISTEN 0      4096                             0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=5011,fd=4),("systemd",pid=1,fd=122))
tcp   LISTEN 0      64                               0.0.0.0:2049       0.0.0.0:*                                            
tcp   LISTEN 0      4096                                [::]:111           [::]:*    users:(("rpcbind",pid=5011,fd=6),("systemd",pid=1,fd=127))
tcp   LISTEN 0      64                                  [::]:2049          [::]:*     
```

Cоздаем папку для **NFS-шары**:
> root@Otus-debian:/# mkdir -p /nfs-homework/share/upload

Изменняем пользователя и группу на эту папку:  
> root@Otus-debian:/# chown -R nobody:nogroup /nfs-homework/share

Даем полные права для всех на директорию **upload**:  
> root@Otus-debian:/# chmod 777 /nfs-homework/share/upload  

> root@Otus-debian:/# ls -la /nfs-homework/  
```
total 12
drwxr-xr-x  3 root   root    4096 Feb 11 20:09 .
drwxr-xr-x 20 root   root    4096 Feb 11 20:09 ..
drwxr-xr-x  3 nobody nogroup 4096 Feb 11 20:09 share
```
> root@Otus-debian:/# ls -la /nfs-homework/share/
```
total 12
drwxr-xr-x 3 nobody nogroup 4096 Feb 11 20:09 .
drwxr-xr-x 3 root   root    4096 Feb 11 20:09 ..
drwxrwxrwx 2 nobody nogroup 4096 Feb 11 20:09 upload
```

Добавляем строку в файл **/etc/exports** для настройки **NFS-шары**:
```bash
root@Otus-debian:/# cat << EOF >> /etc/exports
/nfs-homework/share 10.126.112.0/24(rw,sync,root_squash)
EOF
```
Обновляем конфигурацию (применяем изменения):  
> root@Otus-debian:/# exportfs -ra
```
exportfs: /etc/exports [2]: Neither 'subtree_check' or 'no_subtree_check' specified for export "10.126.112.0/24:/nfs-homework/share".
  Assuming default behaviour ('no_subtree_check').
  NOTE: this default has changed since nfs-utils version 1.0.x
```

1. **subtree_check**:
  - Проверяет права доступа для подкаталогов, если экспортируется не весь файловый ресурс, а только его часть.
  - Может замедлить производительность, так как проверка требует дополнительных операций.

2. **no_subtree_check**:
  - Отключает проверку прав доступа для подкаталогов.
  - Повышает производительность, так как проверки не выполняются.
  - По умолчанию используется в современных версиях NFS.

Проверяем статус экспорта:
> root@Otus-debian:/# exportfs -v
```
/nfs-homework/share
                10.126.112.0/24(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```

Создадим файлы в **NFS-шаре** на сервере:  
> root@Otus-debian:/nfs-homework/share/upload# touch serversfiles{1..9}  

> root@Otus-debian:/nfs-homework/share/upload# ls -la  
```
total 8
drwxrwxrwx 2 nobody nogroup 4096 Feb 12 10:13 .
drwxr-xr-x 3 nobody nogroup 4096 Feb 11 20:09 ..
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles1
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles2
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles3
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles4
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles5
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles6
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles7
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles8
-rw-r--r-- 1 root   root       0 Feb 12 10:13 serversfiles9
```

## Настраиваем NFS-клиент
### Конфигурация виртуальной машины (клиент NFS)
> Ubuntu 22.04.5 LTS x86_64 Desktop
> CPU: host (Intel i7-7700)  
> Sockets: 4  
> Memory: 4096  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

Устанавливаем необходимые модули (если отсутствуют):  
> root@otus-ubuntu:/# apt install nfs-common

Подключаем **NFS-шару**:
> root@otus-ubuntu:/# mount 10.126.112.216:/nfs-homework/share /mnt/nfs_share

Проверяем подключение:  
> root@otus-ubuntu:/# df -hT | awk 'NR==1 || /nfs/'
```
Filesystem                         Type   Size  Used Avail Use% Mounted on
10.126.112.216:/nfs-homework/share nfs4    30G  5,5G   23G  20% /mnt/server-nfs
```
> root@otus-ubuntu:/# mount | grep mnt  
```
nsfs on /run/snapd/ns/snapd-desktop-integration.mnt type nsfs (rw)
nsfs on /run/snapd/ns/snap-store.mnt type nsfs (rw)
nsfs on /run/snapd/ns/firefox.mnt type nsfs (rw)
10.126.112.216:/nfs-homework/share on /mnt/server-nfs type nfs4 (rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.126.112.137,local_lock=none,addr=10.126.112.216)
```
> root@otus-ubuntu:/# ls -la /mnt/server-nfs/  
```
total 12
drwxr-xr-x 3 nobody nogroup 4096 фев 11 20:09 .
drwxr-xr-x 3 root   root    4096 фев 11 20:17 ..
drwxrwxrwx 2 nobody nogroup 4096 фев 11 20:09 upload
```

Добавим запись о монтирование **NFS-шары** в **/etc/fstab**
> root@otus-ubuntu:/# echo "10.126.112.216:/nfs-homework/share/ /mnt/server-nfs nfs noauto,x-systemd.automount 0 0" >> /etc/fstab

1. **noauto**
  - Указывает, что файловая система не будет автоматически монтироваться при загрузке, если не используется дополнительный механизм, например, x-systemd.automount.  

2. **x-systemd.automount**  
  - Интеграция с systemd: Включает автоматическое монтирование при первом обращении к директории /mnt/server-nfs3. Это удобно, так как монтирование произойдёт только тогда, когда это действительно нужно (ленивая загрузка).

Обновляем конфигурацию служб:
> root@otus-ubuntu:/mnt# systemctl daemon-reload

Перезапускаем целевой юнит (target), который отвечает за монтирование удалённых файловых систем:
> root@otus-ubuntu:/mnt# systemctl restart remote-fs.target 

Эти команды гарантируют, что **systemd** прочитает новые конфигурации и применит их к сетевым файловым системам.

### Подключение NFS-шары с указанием версии 3

Аналогичным образом подключаем **NFS-шару** версии 3. Используем параметр **-o vers=3** : 
> root@otus-ubuntu:/# mount -o vers=3 10.126.112.216:/nfs-homework/share /mnt/server-nfs3/  

> root@otus-ubuntu:/# mount | grep mnt 
```
nsfs on /run/snapd/ns/snapd-desktop-integration.mnt type nsfs (rw)
nsfs on /run/snapd/ns/snap-store.mnt type nsfs (rw)
nsfs on /run/snapd/ns/firefox.mnt type nsfs (rw)
10.126.112.216:/nfs-homework/share on /mnt/server-nfs3 type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.126.112.216,mountvers=3,mountport=52844,mountproto=udp,local_lock=none,addr=10.126.112.216)
```
Добавим запись о монтирование **NFS-шары** в **/etc/fstab**
> root@otus-ubuntu:/# echo "10.126.112.216:/nfs-homework/share/ /mnt/server-nfs3 nfs vers=3,noauto,x-systemd.automount 0 0" >> /etc/fstab

**vers=3** - Принудительное использование NFS версии 3.

> root@otus-ubuntu:/mnt# systemctl daemon-reload

> root@otus-ubuntu:/mnt# systemctl restart remote-fs.target 

### После перезагрузки клиента проверим подключение к NFS-шаре
> resovalko@otus-ubuntu:~$ ls -la /mnt/server-nfs/upload/
```
total 8
drwxrwxrwx 2 nobody nogroup 4096 фев 12 10:13 .
drwxr-xr-x 3 nobody nogroup 4096 фев 11 20:09 ..
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles1
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles2
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles3
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles4
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles5
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles6
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles7
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles8
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles9
```
> resovalko@otus-ubuntu:~$ ls -la /mnt/server-nfs3/upload/
```
total 8
drwxrwxrwx 2 nobody nogroup 4096 фев 12 10:13 .
drwxr-xr-x 3 nobody nogroup 4096 фев 11 20:09 ..
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles1
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles2
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles3
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles4
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles5
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles6
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles7
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles8
-rw-r--r-- 1 root   root       0 фев 12 10:13 serversfiles9
```
> resovalko@otus-ubuntu:~$ df -hT | awk 'NR==1 || /nfs/'
```
Filesystem                          Type   Size  Used Avail Use% Mounted on
10.126.112.216:/nfs-homework/share  nfs4    30G  5,5G   23G  20% /mnt/server-nfs
10.126.112.216:/nfs-homework/share/ nfs     30G  5,5G   23G  20% /mnt/server-nfs3
```
> resovalko@otus-ubuntu:~$ mount | grep mnt
```
systemd-1 on /mnt/server-nfs type autofs (rw,relatime,fd=54,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=229)
systemd-1 on /mnt/server-nfs3 type autofs (rw,relatime,fd=55,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=232)
nsfs on /run/snapd/ns/snapd-desktop-integration.mnt type nsfs (rw)
nsfs on /run/snapd/ns/snap-store.mnt type nsfs (rw)
10.126.112.216:/nfs-homework/share on /mnt/server-nfs type nfs4 (rw,relatime,vers=4.2,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=10.126.112.137,local_lock=none,addr=10.126.112.216)
10.126.112.216:/nfs-homework/share/ on /mnt/server-nfs3 type nfs (rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.126.112.216,mountvers=3,mountport=52844,mountproto=udp,local_lock=none,addr=10.126.112.216)
```

Создадим несколько файлов:
> resovalko@otus-ubuntu:~$ touch /mnt/server-nfs/upload/nfs-client-{1..4}  

> resovalko@otus-ubuntu:~$ touch /mnt/server-nfs3/upload/nfs3-client-{1..4}  

> resovalko@otus-ubuntu:~$ ls -la /mnt/server-nfs/upload/  
```
total 8
drwxrwxrwx 2 nobody    nogroup   4096 фев 12 10:36 .
drwxr-xr-x 3 nobody    nogroup   4096 фев 11 20:09 ..
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs3-client-1
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs3-client-2
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs3-client-3
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs3-client-4
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs-client-1
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs-client-2
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs-client-3
-rw-rw-r-- 1 resovalko resovalko    0 фев 12 10:36 nfs-client-4
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles1
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles2
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles3
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles4
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles5
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles6
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles7
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles8
-rw-r--r-- 1 root      root         0 фев 12 10:13 serversfiles9
```

**NFS-шара** успешно создана на сервере и подключена на клиентскую машину.