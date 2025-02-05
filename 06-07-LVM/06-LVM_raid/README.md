## Создание RAID средствами LVM
**Создадим Physical volume** из устроств /dev/sdf и /dev/sdg  
> root@Otus-debian:/mnt# pvcreate /dev/sd{f,g}
```
  Physical volume "/dev/sdf" successfully created.
  Physical volume "/dev/sdg" successfully created.
```
**Создадим Volume group** с именем "lvmraid" из устроств /dev/sdf и /dev/sdg
> root@Otus-debian:/mnt# vgcreate lvmraid /dev/sd{f,g}
```
  Volume group "lvmraid" successfully created
```
**Создадим Logical volume** с именем "mirror" в Volume group с именем "lvmraid"  
>root@Otus-debian:/mnt# lvcreate -l+80%FREE -m1 -n mirror lvmraid
```
  Logical volume "mirror" created.
```
**Смотрим что получилось**  
Logical volume с именем "mirror" размером 1.6Гб - raid1 (зеркало)  
> root@Otus-debian:/mnt# pvs
```
  PV         VG             Fmt  Attr PSize   PFree
  /dev/md5   lvmhomework    lvm2 a--    1.99g      0
  /dev/sda5  Otus-debian-vg lvm2 a--  <31.52g  44.00m
  /dev/sde   lvmhomework    lvm2 a--   <2.00g   1.79g
  /dev/sdf   lvmraid        lvm2 a--   <2.00g 408.00m
  /dev/sdg   lvmraid        lvm2 a--   <2.00g 408.00m
```
> root@Otus-debian:/mnt# vgs
```
  VG             #PV #LV #SN Attr   VSize   VFree
  Otus-debian-vg   1   2   0 wz--n- <31.52g  44.00m
  lvmhomework      2   2   0 wz--n-  <3.99g   1.79g
  lvmraid          2   1   0 wz--n-   3.99g 816.00m
```
> root@Otus-debian:/mnt# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   2.00g
  part2s lvmhomework    -wi-ao---- 200.00m
  mirror lvmraid        rwi-a-r---   1.59g                                    78.71
```
> root@Otus-debian:/mnt# lvs -a
```
  LV                VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root              Otus-debian-vg -wi-ao----  30.52g
  swap_1            Otus-debian-vg -wi-ao---- 976.00m
  part1             lvmhomework    -wi-ao----   2.00g
  part2s            lvmhomework    -wi-ao---- 200.00m
  mirror            lvmraid        rwi-a-r---   1.59g                                    100.00
  [mirror_rimage_0] lvmraid        iwi-aor---   1.59g
  [mirror_rimage_1] lvmraid        iwi-aor---   1.59g
  [mirror_rmeta_0]  lvmraid        ewi-aor---   4.00m
  [mirror_rmeta_1]  lvmraid        ewi-aor---   4.00m
```