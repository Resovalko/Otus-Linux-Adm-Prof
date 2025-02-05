## Создание структуры LVM

**Смотрим информацию по блочным устройствам**  
> root@Otus-debian:~# lsblk
```
NAME                        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                           8:0    0   32G  0 disk
├─sda1                        8:1    0  487M  0 part  /boot
├─sda2                        8:2    0    1K  0 part
└─sda5                        8:5    0 31.5G  0 part
  ├─Otus--debian--vg-root   253:0    0 30.5G  0 lvm   /
  └─Otus--debian--vg-swap_1 253:1    0  976M  0 lvm   [SWAP]
sdb                           8:16   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5 /mnt/raid5
sdc                           8:32   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5 /mnt/raid5
sdd                           8:48   0    1G  0 disk
└─md5                         9:5    0    2G  0 raid5 /mnt/raid5
sde                           8:64   0    2G  0 disk  /mnt/tst
sdf                           8:80   0    2G  0 disk
sdg                           8:96   0    2G  0 disk
sr0                          11:0    1 1024M  0 rom
```
**Создаем Volume group** с именем "lvmhomework"  
> root@Otus-debian:/mnt# vgcreate lvmhomework /dev/md5
```
WARNING: ext4 signature detected on /dev/md5 at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/md5.
  Physical volume "/dev/md5" successfully created.
  Volume group "lvmhomework" successfully created
root@Otus-debian:/mnt# pvs
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g  1.99g
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g 44.00m
```
**Создаем Logical volume** с именем "part1" на Volume group "lvmhomework" и выделяем ей 50% свободного места от имеющегося  
> root@Otus-debian:/mnt# lvcreate -l+50%FREE -n part1 lvmhomework
```
  Logical volume "part1" created.
root@Otus-debian:/mnt# lvs
  LV     VG             Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----   30.52g
  swap_1 Otus-debian-vg -wi-ao----  976.00m
  part1  lvmhomework    -wi-a----- 1020.00m
```
**Создаем Logical volume** с именем "part2s" на Volume group "lvmhomework" и выделяем ей 200Mb места от имеющегося свободного  
> root@Otus-debian:/mnt# lvcreate -L 200M -n part2s lvmhomework
```
  Logical volume "part2s" created.
root@Otus-debian:/mnt# lvs
  LV     VG             Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----   30.52g
  swap_1 Otus-debian-vg -wi-ao----  976.00m
  part1  lvmhomework    -wi-a----- 1020.00m
  part2s lvmhomework    -wi-a-----  200.00m
```
**Создаем файловую систему ext4** на Logical volume "part1" и "part2s"  
> root@Otus-debian:/mnt# mkfs.ext4 /dev/lvmhomework/part1  

> root@Otus-debian:/mnt# mkfs.ext4 /dev/lvmhomework/part2s  

**Монтируем готовые к работе Logical volume**  
> root@Otus-debian:/mnt# mount /dev/lvmhomework/part1 /mnt/part1/  

> root@Otus-debian:/mnt# mount /dev/lvmhomework/part2s /mnt/part2s/  

> root@Otus-debian:/mnt# df -hT
```
Filesystem                        Type      Size  Used Avail Use% Mounted on
udev                              devtmpfs  448M     0  448M   0% /dev
tmpfs                             tmpfs      97M  1.1M   95M   2% /run
/dev/mapper/Otus--debian--vg-root ext4       30G  5.0G   24G  18% /
tmpfs                             tmpfs     481M     0  481M   0% /dev/shm
tmpfs                             tmpfs     5.0M     0  5.0M   0% /run/lock
/dev/sda1                         ext2      455M  144M  287M  34% /boot
tmpfs                             tmpfs      97M   52K   96M   1% /run/user/1000
/dev/mapper/lvmhomework-part1     ext4      986M   24K  919M   1% /mnt/part1
/dev/mapper/lvmhomework-part2s    ext4      182M   14K  168M   1% /mnt/part2s
```