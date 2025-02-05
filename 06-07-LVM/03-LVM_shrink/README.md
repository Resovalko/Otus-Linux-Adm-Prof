## Уменьшение размера Logical volume
### ВОЗМОЖНА ПОТЕРЯ ДАННЫХ! Выполнять только после создания бэкапа всех данных на Logical volume!
**Отмонтируем Logical volume**  
> root@Otus-debian:~# umount /mnt/part1/
**Выполняем проверку файловой системы**  
>root@Otus-debian:~# e2fsck -fy /dev/lvmhomework/part1
```
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/lvmhomework/part1: 6690/195840 files (0.2% non-contiguous), 177581/786432 blocks
```
**Уменьшаем файловую систему** Logical volume с именем "part1" до 2Гб
> root@Otus-debian:~# resize2fs /dev/lvmhomework/part1 2G
```
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/lvmhomework/part1 to 524288 (4k) blocks.
The filesystem on /dev/lvmhomework/part1 is now 524288 (4k) blocks long.
```
**Уменьшаем Logical volume** с именем "part1" до 2Гб
> root@Otus-debian:~# lvreduce /dev/lvmhomework/part1 -L 2G
```
  WARNING: Reducing active logical volume to 2.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce lvmhomework/part1? [y/n]: y
  Size of logical volume lvmhomework/part1 changed from 3.00 GiB (768 extents) to 2.00 GiB (512 extents).
  Logical volume lvmhomework/part1 successfully resized.
```
**Монтируем Logical volume**
> root@Otus-debian:~# mount /dev/lvmhomework/part1 /mnt/part1/  
**Смотрим что получилось**
Logical volume "part1" уменьшен до размера 2Гб  
> root@Otus-debian:~# pvs  
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g     0
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g 44.00m
  /dev/sde   lvmhomework    lvm2 a--   <2.00g  1.79g
```
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g 44.00m
  lvmhomework      2   2   0 wz--n-  <3.99g  1.79g
```
> root@Otus-debian:~# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   2.00g
  part2s lvmhomework    -wi-ao---- 200.00m
```
> root@Otus-debian:~# df -h
```
Filesystem                         Size  Used Avail Use% Mounted on
udev                               448M     0  448M   0% /dev
tmpfs                               97M  1.1M   95M   2% /run
/dev/mapper/Otus--debian--vg-root   30G  5.1G   24G  18% /
tmpfs                              481M     0  481M   0% /dev/shm
tmpfs                              5.0M     0  5.0M   0% /run/lock
/dev/sda1                          455M  144M  287M  34% /boot
tmpfs                               97M   52K   96M   1% /run/user/1000
/dev/mapper/lvmhomework-part2s     182M   68M  101M  41% /mnt/part2s
/dev/mapper/lvmhomework-part1      2.0G  627M  1.3G  34% /mnt/part1
```