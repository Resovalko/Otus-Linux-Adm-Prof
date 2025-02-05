## Расширение структуры LVM
**Добавляем еще один диск** /dev/sde в Volume group "lvmhomework"  
Сразу используем команду vgextend  
> root@Otus-debian:/mnt# vgextend lvmhomework /dev/sde
```
  Physical volume "/dev/sde" successfully created.
  Volume group "lvmhomework" successfully extended
```
**Смотрим что получилось**
> root@Otus-debian:/mnt# pvs
```  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g 820.00m
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  44.00m
  /dev/sde   lvmhomework    lvm2 a--   <2.00g  <2.00g
```
> root@Otus-debian:/mnt# lvs
```  LV     VG             Attr       LSize    Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----   30.52g
  swap_1 Otus-debian-vg -wi-ao----  976.00m
  part1  lvmhomework    -wi-ao---- 1020.00m
  part2s lvmhomework    -wi-ao----  200.00m
```
> root@Otus-debian:/mnt# vgs
```  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g 44.00m
  lvmhomework      2   2   0 wz--n-  <3.99g <2.80g
```
**Увеличиваем Logical volume "part1" до 3Гб** сразу расширением файловой системы (ключ "-r")
> root@Otus-debian:~# lvextend -L 3G /dev/lvmhomework/part1 -r
```
  Size of logical volume lvmhomework/part1 changed from 1020.00 MiB (255 extents) to 3.00 GiB (768 extents).
  Logical volume lvmhomework/part1 successfully resized.
resize2fs 1.47.0 (5-Feb-2023)
Filesystem at /dev/mapper/lvmhomework-part1 is mounted on /mnt/part1; on-line resizing required
old_desc_blocks = 1, new_desc_blocks = 1
The filesystem on /dev/mapper/lvmhomework-part1 is now 786432 (4k) blocks long.
```
**Смотрим что получилось**  
Logical volume "part1" расширен до размера 3Гб за счет своодного места на диске /dev/sde   
> root@Otus-debian:~# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g  44.00m
  lvmhomework      2   2   0 wz--n-  <3.99g 812.00m
```
> root@Otus-debian:~# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g      0
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  44.00m
  /dev/sde   lvmhomework    lvm2 a--   <2.00g 812.00m
```
> root@Otus-debian:~# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   3.00g
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
/dev/mapper/lvmhomework-part1      3.0G  627M  2.2G  22% /mnt/part1
/dev/mapper/lvmhomework-part2s     182M   68M  101M  41% /mnt/part2s
```