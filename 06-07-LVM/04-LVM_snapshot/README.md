## Создание Logical volume snapshot
**Создаем snapshot** размером 500Мб с именем "part1-snap" для Logical volume с именем "part1"  
> root@Otus-debian:~# lvcreate -L 500M -s -n part1-snap lvmhomework/part1
```
  Logical volume "part1-snap" created.
```
**Смотрим что получилось**  
> root@Otus-debian:~# lvs
```
  LV         VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root       Otus-debian-vg -wi-ao----  30.52g
  swap_1     Otus-debian-vg -wi-ao---- 976.00m
  part1      lvmhomework    owi-aos---   2.00g
  part1-snap lvmhomework    swi-a-s--- 500.00m      part1  0.01
  part2s     lvmhomework    -wi-ao---- 200.00m
```
> root@Otus-debian:~# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g     0
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g 44.00m
  /dev/sde   lvmhomework    lvm2 a--   <2.00g  1.30g
```
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g 44.00m
  lvmhomework      2   3   1 wz--n-  <3.99g  1.30g
```
Вструктуре блочных устройств появились данные, относящиеся к созданному snapshot  
> root@Otus-debian:/mnt# lsblk
```
NAME                          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                             8:0    0   32G  0 disk
├─sda1                          8:1    0  487M  0 part  /boot
├─sda2                          8:2    0    1K  0 part
└─sda5                          8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root     253:0    0 30.5G  0 lvm   /
  └─Otus--debian--vg-swap_1   253:1    0  976M  0 lvm   [SWAP]
sdb                             8:16   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  ├─lvmhomework-part2s        253:3    0  200M  0 lvm   /mnt/part2s
  └─lvmhomework-part1-real    253:4    0    2G  0 lvm
    ├─lvmhomework-part1       253:2    0    2G  0 lvm
    └─lvmhomework-part1--snap 253:6    0    2G  0 lvm
sdc                             8:32   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  ├─lvmhomework-part2s        253:3    0  200M  0 lvm   /mnt/part2s
  └─lvmhomework-part1-real    253:4    0    2G  0 lvm
    ├─lvmhomework-part1       253:2    0    2G  0 lvm
    └─lvmhomework-part1--snap 253:6    0    2G  0 lvm
sdd                             8:48   0    1G  0 disk
└─md5                           9:5    0    2G  0 raid5
  ├─lvmhomework-part2s        253:3    0  200M  0 lvm   /mnt/part2s
  └─lvmhomework-part1-real    253:4    0    2G  0 lvm
    ├─lvmhomework-part1       253:2    0    2G  0 lvm
    └─lvmhomework-part1--snap 253:6    0    2G  0 lvm
sde                             8:64   0    2G  0 disk
├─lvmhomework-part1-real      253:4    0    2G  0 lvm
│ ├─lvmhomework-part1         253:2    0    2G  0 lvm
│ └─lvmhomework-part1--snap   253:6    0    2G  0 lvm
└─lvmhomework-part1--snap-cow 253:5    0  500M  0 lvm
  └─lvmhomework-part1--snap   253:6    0    2G  0 lvm
sdf                             8:80   0    2G  0 disk
sdg                             8:96   0    2G  0 disk
sr0                            11:0    1 1024M  0 rom
```

### Пример восстановления данных из snapshot

На Logical volume с именем "part1" который смонтирован в директорию /mnt/part1 имеются данные  
> root@Otus-debian:/mnt/part1# du -sh *
```
2.7M    backups
357M    cache
201M    lib
4.0K    local
0       lock
68M     log
16K     lost+found
12K     mail
4.0K    opt
0       run
64K     spool
44K     tmp
20K     www
```
**Моделируем потерю данных**, удалив директорию и все ее содержимое
>root@Otus-debian:/mnt/part1# rm -r backups/  

> root@Otus-debian:/mnt/part1# ls -la  
```
total 60
drwxr-xr-x 12 root root  4096 Feb  4 18:29 .
drwxr-xr-x  5 root root  4096 Feb  3 20:09 ..
drwxr-xr-x 13 root root  4096 Feb  3 21:51 cache
drwxr-xr-x 44 root root  4096 Feb  3 21:51 lib
drwxr-xr-x  2 root root  4096 Feb  3 21:51 local
lrwxrwxrwx  1 root root     9 Feb  3 21:51 lock -> /run/lock
drwxr-xr-x 12 root root  4096 Feb  3 21:51 log
drwx------  2 root root 16384 Feb  3 21:50 lost+found
drwxr-xr-x  2 root root  4096 Feb  3 21:51 mail
drwxr-xr-x  2 root root  4096 Feb  3 21:51 opt
lrwxrwxrwx  1 root root     4 Feb  3 21:51 run -> /run
drwxr-xr-x  7 root root  4096 Feb  3 21:51 spool
drwxr-xr-t  7 root root  4096 Feb  3 21:51 tmp
drwxr-xr-x  3 root root  4096 Feb  3 21:51 www
```
**Восстанавливаем** потерянные данные  
**Отмонтируем** Logical volume с именем "part1" и его snapshot (если он был примонтирован)
> root@Otus-debian:/mnt# umount /mnt/part1  

**Восстановим данные из snapshot** в оригинальный Logical volume
> root@Otus-debian:/mnt# lvconvert --merge /dev/lvmhomework/part1-snap
```
  Merging of volume lvmhomework/part1-snap started.
  lvmhomework/part1: Merged: 100.00%
```
**Монтируем** Logical volume с именем "part1"
> root@Otus-debian:/mnt# mount /dev/lvmhomework/part1 /mnt/part1  

**Смотрим что получилось**  
Директория и все ее содержимое вернулось в исходное состояние  
> root@Otus-debian:/mnt# ls -la part1/
```
total 64
drwxr-xr-x 13 root root  4096 Feb  3 21:51 .
drwxr-xr-x  5 root root  4096 Feb  3 20:09 ..
drwxr-xr-x  2 root root  4096 Feb  3 21:50 backups
drwxr-xr-x 13 root root  4096 Feb  3 21:51 cache
drwxr-xr-x 44 root root  4096 Feb  3 21:51 lib
drwxr-xr-x  2 root root  4096 Feb  3 21:51 local
lrwxrwxrwx  1 root root     9 Feb  3 21:51 lock -> /run/lock
drwxr-xr-x 12 root root  4096 Feb  3 21:51 log
drwx------  2 root root 16384 Feb  3 21:50 lost+found
drwxr-xr-x  2 root root  4096 Feb  3 21:51 mail
drwxr-xr-x  2 root root  4096 Feb  3 21:51 opt
lrwxrwxrwx  1 root root     4 Feb  3 21:51 run -> /run
drwxr-xr-x  7 root root  4096 Feb  3 21:51 spool
drwxr-xr-t  7 root root  4096 Feb  3 21:51 tmp
drwxr-xr-x  3 root root  4096 Feb  3 21:51 www
```

Структура блочных устройств вернулась в исходное состояние
> root@Otus-debian:/mnt# lsblk
```
NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                           8:0    0   32G  0 disk
├─sda1                        8:1    0  487M  0 part  /boot
├─sda2                        8:2    0    1K  0 part
└─sda5                        8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root   253:0    0 30.5G  0 lvm   /
  └─Otus--debian--vg-swap_1 253:1    0  976M  0 lvm   [SWAP]
sdb                           8:16   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  ├─lvmhomework-part1       253:2    0    2G  0 lvm   /mnt/part1
  └─lvmhomework-part2s      253:3    0  200M  0 lvm   /mnt/part2s
sdc                           8:32   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  ├─lvmhomework-part1       253:2    0    2G  0 lvm   /mnt/part1
  └─lvmhomework-part2s      253:3    0  200M  0 lvm   /mnt/part2s
sdd                           8:48   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5
  ├─lvmhomework-part1       253:2    0    2G  0 lvm   /mnt/part1
  └─lvmhomework-part2s      253:3    0  200M  0 lvm   /mnt/part2s
sde                           8:64   0    2G  0 disk
└─lvmhomework-part1         253:2    0    2G  0 lvm   /mnt/part1
sdf                           8:80   0    2G  0 disk
sdg                           8:96   0    2G  0 disk
sr0                          11:0    1 1024M  0 rom
```