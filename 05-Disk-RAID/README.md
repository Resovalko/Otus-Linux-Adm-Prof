# Дисковая подсистема. RAID.

## Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**

Основная виртуальная машина с Vagrant, VirtualBox, Ansible  
### Основная виртуальная машина
> Ubuntu 22.04.5 LTS x86_64 Desktop
> CPU: host (Intel i7-7700)  
> Sockets: 4  
> Memory: 4096  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

> Vagrant 2.4.3  
> Oracle VM VirtualBox VM Selector v7.0.22  
> ansible [core 2.17.7]  


На **основной виртуальной машине** запущена ВМ с использованием [Vagrantfile](mdadm-vm/Vagrantfile):  
> Ubuntu 20.04.6 LTS  
> CPU: 2  
> Memory: 2048  
> HDD: 5 дополнительных дисков по 2Gb  

## Сборка RAID
- При запуске проиходит обновление и установка необходимых пакетов  
- Сборка **RAID 10** из дисков **/dev/sdc**, **/dev/sdd**, **/dev/sde**, **/dev/sdf**, создание файловой системы, сохранение конфигурации в **/etc/mdadm/mdadm.conf** и обновление initramfs для автоматической сборки RAID при загрузке  
- Создается папка **/mnt/raid10** в которую монтируется RAID  
- В файл **/etc/fstab** добавляется информация о монтировании RAID по UUID при загрузке системы  

### Результат
```
   RAID-mdadm: RAID успешно создан!
    RAID-mdadm: NAME   MAJ:MIN RM  SIZE RO TYPE   MOUNTPOINT
    RAID-mdadm: loop0    7:0    0 91.9M  1 loop   /snap/lxd/29619
    RAID-mdadm: loop1    7:1    0 44.3M  1 loop   /snap/snapd/23258
    RAID-mdadm: loop2    7:2    0 63.7M  1 loop   /snap/core20/2434
    RAID-mdadm: sda      8:0    0   40G  0 disk
    RAID-mdadm: └─sda1   8:1    0   40G  0 part   /
    RAID-mdadm: sdb      8:16   0   10M  0 disk
    RAID-mdadm: sdc      8:32   0    2G  0 disk
    RAID-mdadm: └─md10   9:10   0    4G  0 raid10 /mnt/raid10
    RAID-mdadm: sdd      8:48   0    2G  0 disk
    RAID-mdadm: └─md10   9:10   0    4G  0 raid10 /mnt/raid10
    RAID-mdadm: sde      8:64   0    2G  0 disk
    RAID-mdadm: └─md10   9:10   0    4G  0 raid10 /mnt/raid10
    RAID-mdadm: sdf      8:80   0    2G  0 disk
    RAID-mdadm: └─md10   9:10   0    4G  0 raid10 /mnt/raid10
    RAID-mdadm: sdg      8:96   0    2G  0 disk
```
```
agrant@RAID-mdadm:~$ sudo mdadm -D /dev/md10
/dev/md10:
           Version : 1.2
     Creation Time : Mon Jan 27 08:21:19 2025
        Raid Level : raid10
        Array Size : 4188160 (3.99 GiB 4.29 GB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Mon Jan 27 08:22:05 2025
             State : clean 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : RAID-mdadm:10  (local to host RAID-mdadm)
              UUID : 15463c5c:62782c4f:8a442b08:92598488
            Events : 21

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync set-A   /dev/sdc
       1       8       48        1      active sync set-B   /dev/sdd
       2       8       64        2      active sync set-A   /dev/sde
       3       8       80        3      active sync set-B   /dev/sdf
```
```
vagrant@RAID-mdadm:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md10 : active raid10 sdf[3] sde[2] sdd[1] sdc[0]
      4188160 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
```

## Ломаем/восстанавливаем RAID
Моделируем выход из строя одного из дисков  
> vagrant@RAID-mdadm:~$ sudo mdadm /dev/md10 --fail /dev/sde  
Видим проблему с 3-им диском и статус "degraded"  
```
vagrant@RAID-mdadm:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md10 : active raid10 sdf[3] sde[2](F) sdd[1] sdc[0]
      4188160 blocks super 1.2 512K chunks 2 near-copies [4/3] [UU_U]
```
```
vagrant@RAID-mdadm:~$ sudo mdadm -D /dev/md10
/dev/md10:
           Version : 1.2
     Creation Time : Mon Jan 27 08:21:19 2025
        Raid Level : raid10
        Array Size : 4188160 (3.99 GiB 4.29 GB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Mon Jan 27 08:27:36 2025
             State : clean, degraded 
    Active Devices : 3
   Working Devices : 3
    Failed Devices : 1
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : RAID-mdadm:10  (local to host RAID-mdadm)
              UUID : 15463c5c:62782c4f:8a442b08:92598488
            Events : 23

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync set-A   /dev/sdc
       1       8       48        1      active sync set-B   /dev/sdd
       -       0        0        2      removed
       3       8       80        3      active sync set-B   /dev/sdf

       2       8       64        -      faulty   /dev/sde
```
Удаляем "неисправный" диск и заменяем его на "запасной"  
> vagrant@RAID-mdadm:~$ sudo mdadm /dev/md10 --remove /dev/sde  
> vagrant@RAID-mdadm:~$ sudo mdadm /dev/md10 --add /dev/sdg  
Видим запущен процесс восстановления:
```
vagrant@RAID-mdadm:~$ cat /proc/mdstat 
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md10 : active raid10 sdg[4] sdf[3] sdd[1] sdc[0]
      4188160 blocks super 1.2 512K chunks 2 near-copies [4/3] [UU_U]
      [======>..............]  recovery = 30.1% (632320/2094080) finish=0.0min speed=316160K/sec
```
Восстановленный RAID с "новым" диском **/dev/sdg**:
```
vagrant@RAID-mdadm:~$ sudo mdadm -D /dev/md10
/dev/md10:
           Version : 1.2
     Creation Time : Mon Jan 27 08:21:19 2025
        Raid Level : raid10
        Array Size : 4188160 (3.99 GiB 4.29 GB)
     Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
      Raid Devices : 4
     Total Devices : 4
       Persistence : Superblock is persistent

       Update Time : Mon Jan 27 08:30:55 2025
             State : clean 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : RAID-mdadm:10  (local to host RAID-mdadm)
              UUID : 15463c5c:62782c4f:8a442b08:92598488
            Events : 43

    Number   Major   Minor   RaidDevice State
       0       8       32        0      active sync set-A   /dev/sdc
       1       8       48        1      active sync set-B   /dev/sdd
       4       8       96        2      active sync set-A   /dev/sdg
       3       8       80        3      active sync set-B   /dev/sdf
```