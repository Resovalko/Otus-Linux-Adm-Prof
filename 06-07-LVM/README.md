# Файловые системы. LVM.

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
> Hard disk 4: 2G  
> Hard disk 5: 2G  
> Hard disk 6: 2G  
> BIOS: SeaBIOS  
> Machine: i440fx  


<!-- ### Собираем/ломаем/восстанавливаем RAID 5
Получаем информацию о дисках  
```
root@Otus-debian:~# lsblk
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
```
**Собираем RAID 5**  
```
root@Otus-debian:~# mdadm --create --verbose /dev/md5 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 1046528K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md5 started.
```
Сохраняем конфигурацию и обновляем initramfs  
> root@Otus-debian:~# mdadm --detail --scan >> /etc/mdadm/mdadm.conf  

> root@Otus-debian:~# update-initramfs -u  

Создаем файловую систему, точку монтирования и подключаем RAID
```
root@Otus-debian:~# mkfs.ext4 /dev/md5
mke2fs 1.47.0 (5-Feb-2023)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 16cdd4f8-8caa-4384-aa9a-92b546e42eb0
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done

root@Otus-debian:~# mkdir -p /mnt/raid5
root@Otus-debian:~# mount /dev/md5 /mnt/raid5/
root@Otus-debian:~# ls -la /mnt/raid5/
total 24
drwxr-xr-x 3 root root  4096 Jan 27 12:57 .
drwxr-xr-x 3 root root  4096 Jan 27 12:58 ..
drwx------ 2 root root 16384 Jan 27 12:57 lost+found
root@Otus-debian:~# df -hT
Filesystem                        Type      Size  Used Avail Use% Mounted on
udev                              devtmpfs  448M     0  448M   0% /dev
tmpfs                             tmpfs      97M  1.1M   96M   2% /run
/dev/mapper/Otus--debian--vg-root ext4       30G  5.0G   24G  18% /
tmpfs                             tmpfs     481M     0  481M   0% /dev/shm
tmpfs                             tmpfs     5.0M     0  5.0M   0% /run/lock
/dev/sda1                         ext2      455M  144M  287M  34% /boot
tmpfs                             tmpfs      97M   72K   96M   1% /run/user/1000
/dev/md5                          ext4      2.0G   24K  1.9G   1% /mnt/raid5
```
Добавляем запись в **/etc/fstab** для автоматического монтирования  
> echo "UUID=$(blkid -s UUID -o value /dev/md5) /mnt/raid5 ext4 defaults 0 0" >> /etc/fstab  

**Ломаем/восстанавливаем RAID**  
Моделируем выход из строя одного из дисков  

> root@Otus-debian:~# mdadm /dev/md5 --fail /dev/sdd  

Видим проблему с 3-им диском и статус **"degraded"**  
```
root@Otus-debian:~# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md5 : active raid5 sdd[3](F) sdb[0] sdc[1]
      2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [UU_]
```
```
root@Otus-debian:~# mdadm -D /dev/md5
/dev/md5:
           Version : 1.2
     Creation Time : Mon Jan 27 12:52:13 2025
        Raid Level : raid5
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 3
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Mon Jan 27 13:06:42 2025
             State : clean, degraded
    Active Devices : 2
   Working Devices : 2
    Failed Devices : 1
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Otus-debian:5  (local to host Otus-debian)
              UUID : 8d06319e:cf6ecf98:a06cead9:4c926b3f
            Events : 24

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       -       0        0        2      removed

       3       8       48        -      faulty   /dev/sdd
```
Удаляем "неисправный" диск и заменяем его на "запасной"  

> root@Otus-debian:~# mdadm /dev/md5 --remove /dev/sdd  

> root@Otus-debian:~# mdadm /dev/md5 --add /dev/sde

Видим запущен процесс восстановления:
```
root@Otus-debian:~# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] [linear] [multipath] [raid0] [raid1] [raid10]
md5 : active raid5 sde[3] sdb[0] sdc[1]
      2093056 blocks super 1.2 level 5, 512k chunk, algorithm 2 [3/2] [UU_]
      [=========>...........]  recovery = 45.0% (472188/1046528) finish=0.0min speed=236094K/sec
```
### Результат
Восстановленный RAID с "новым" диском **/dev/sde**:
```
root@Otus-debian:~# mdadm -D /dev/md5
/dev/md5:
           Version : 1.2
     Creation Time : Mon Jan 27 12:52:13 2025
        Raid Level : raid5
        Array Size : 2093056 (2044.00 MiB 2143.29 MB)
     Used Dev Size : 1046528 (1022.00 MiB 1071.64 MB)
      Raid Devices : 3
     Total Devices : 3
       Persistence : Superblock is persistent

       Update Time : Mon Jan 27 13:10:49 2025
             State : clean
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 0
     Spare Devices : 0

            Layout : left-symmetric
        Chunk Size : 512K

Consistency Policy : resync

              Name : Otus-debian:5  (local to host Otus-debian)
              UUID : 8d06319e:cf6ecf98:a06cead9:4c926b3f
            Events : 66

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       3       8       64        2      active sync   /dev/sde
``` -->