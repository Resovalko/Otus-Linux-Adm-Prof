## Создание кэширующего Logical volume
**Подключаем "быстрый" диск** /dev/sdf к Volume group с именем "lvmhomework"
> root@Otus-debian:/mnt# vgextend lvmhomework /dev/sdf
```
  Physical volume "/dev/sdf" successfully created.
  Volume group "lvmhomework" successfully extended
```
**Создаем кэширующий Logical volume типа cache-pool** с именем "cache_part2s" и размером 50Мб на "быстром" диске /dev/sdf
> root@Otus-debian:/mnt# lvcreate --type cache-pool lvmhomework -n cache_part2s -L 50M /dev/sdf
```
  Rounding up size to full physical extent 52.00 MiB
  Logical volume "cache_part2s" created.
```
**Смотрим что получилось**
> root@Otus-debian:/mnt# lvs
```
  LV           VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root         Otus-debian-vg -wi-ao----  30.52g
  swap_1       Otus-debian-vg -wi-ao---- 976.00m
  cache_part2s lvmhomework    Cwi---C---  52.00m
  part1        lvmhomework    -wi-ao----   2.00g
  part2s       lvmhomework    -wi-ao---- 200.00m
```
**Подключаем кэширование**  
Logical volume с именем "part2s" будет использовать Logical volume с именем "cache_part2s" в качестве кэша  
> root@Otus-debian:/mnt# lvconvert --cache --cache-pool lvmhomework/cache_part2s lvmhomework/part2s
```
  Logical volume lvmhomework/part2s is now cached.
```
**Смотрим что получилось**  
> root@Otus-debian:/mnt# lvs
```
  LV     VG             Attr       LSize   Pool                 Origin         Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   2.00g
  part2s lvmhomework    Cwi-aoC--- 200.00m [cache_part2s_cpool] [part2s_corig] 0.00   0.49            0.00
```
> root@Otus-debian:/mnt# lvs -a
```
  LV                         VG             Attr       LSize   Pool                 Origin         Data%  Meta%  Move Log Cpy%Sync Convert
  root                       Otus-debian-vg -wi-ao----  30.52g
  swap_1                     Otus-debian-vg -wi-ao---- 976.00m
  [cache_part2s_cpool]       lvmhomework    Cwi---C---  52.00m                                     0.00   0.49            0.00
  [cache_part2s_cpool_cdata] lvmhomework    Cwi-ao----  52.00m
  [cache_part2s_cpool_cmeta] lvmhomework    ewi-ao----   8.00m
  [lvol0_pmspare]            lvmhomework    ewi-------   8.00m
  part1                      lvmhomework    -wi-ao----   2.00g
  part2s                     lvmhomework    Cwi-aoC--- 200.00m [cache_part2s_cpool] [part2s_corig] 0.00   0.49            0.00
  [part2s_corig]             lvmhomework    owi-aoC--- 200.00m
```
**Отключаем кэширование**  
>root@Otus-debian:/mnt#  lvconvert --uncache lvmhomework/part2s
```
  Logical volume "cache_part2s_cpool" successfully removed.
  Logical volume lvmhomework/part2s is not cached.
```
Logical volume с именем "part2s" теперь работает без кэширования, Logical volume с именем "cache_part2s" удален  
> root@Otus-debian:/mnt# lvs -a
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   2.00g
  part2s lvmhomework    -wi-ao---- 200.00m
```
> root@Otus-debian:/mnt# lvs
```
  LV     VG             Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  root   Otus-debian-vg -wi-ao----  30.52g
  swap_1 Otus-debian-vg -wi-ao---- 976.00m
  part1  lvmhomework    -wi-ao----   2.00g
  part2s lvmhomework    -wi-ao---- 200.00m
```