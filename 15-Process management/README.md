# Bash 

## Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**  

### Конфигурация виртуальной машины
> Debian GNU/Linux 12 (bookworm)  
> CPU: x86-64-v2-AES  
> Sockets: 2  
> Memory: 1024  
> Hard disk 0: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

## Скрипт выводит информацию о процессах используя анализ директории /proc

Скрипт [process_list_proc.sh](process_list_proc.sh) выводит информацию о процесах в системе, используя данные из директории **/proc**

#### Пример вывода данных при запуске скрипта
```
root@Otus-debian:/scripts# ./process_list_proc.sh
   PID       USER   PPID STATE   CPU%    RUNTIME     TIME+        MEM COMMAND
     1       root      0     S    0.0  161:41:51  00:08.16   13540 KB /sbin/init
     2       root      0     S    0.0  161:41:51  00:00.04            [(kthreadd)]
     3       root      2     I    0.0  161:41:51  00:00.00            [(rcu_gp)]
     4       root      2     I    0.0  161:41:51  00:00.00            [(rcu_par_gp)]
     5       root      2     I    0.0  161:41:51  00:00.00            [(slub_flushwq)]
     6       root      2     I    0.0  161:41:51  00:00.00            [(netns)]
     8       root      2     I    0.0  161:41:51  00:00.00            [(kworker/0:0H-events_highpri)]
    10       root      2     I    0.0  161:41:51  00:00.00            [(mm_percpu_wq)]
    11       root      2     I    0.0  161:41:51  00:00.00            [(rcu_tasks_kthread)]
    12       root      2     I    0.0  161:41:51  00:00.00            [(rcu_tasks_rude_kthread)]
    13       root      2     I    0.0  161:41:51  00:00.00            [(rcu_tasks_trace_kthread)]
    14       root      2     S    0.0  161:41:51  00:00.34            [(ksoftirqd/0)]
    15       root      2     I    0.0  161:41:52  00:09.45            [(rcu_preempt)]
    16       root      2     S    0.0  161:41:52  00:01.79            [(migration/0)]
    18       root      2     S    0.0  161:41:52  00:00.00            [(cpuhp/0)]
    19       root      2     S    0.0  161:41:52  00:00.00            [(cpuhp/1)]
    20       root      2     S    0.0  161:41:52  00:01.72            [(migration/1)]
    21       root      2     S    0.0  161:41:52  00:00.32            [(ksoftirqd/1)]
    23       root      2     I    0.0  161:41:52  00:00.00            [(kworker/1:0H-events_highpri)]
    26       root      2     S    0.0  161:41:52  00:00.00            [(kdevtmpfs)]
    27       root      2     I    0.0  161:41:52  00:00.00            [(inet_frag_wq)]
    28       root      2     S    0.0  161:41:52  00:00.00            [(kauditd)]
    29       root      2     S    0.0  161:41:52  00:00.13            [(khungtaskd)]
    30       root      2     S    0.0  161:41:52  00:00.00            [(oom_reaper)]
    32       root      2     I    0.0  161:41:52  00:00.00            [(writeback)]
    33       root      2     S    0.0  161:41:52  00:12.88            [(kcompactd0)]
    34       root      2     S    0.0  161:41:52  00:00.00            [(ksmd)]
    36       root      2     S    0.0  161:41:52  00:04.12            [(khugepaged)]
    37       root      2     I    0.0  161:41:52  00:00.00            [(kintegrityd)]
    38       root      2     I    0.0  161:41:52  00:00.00            [(kblockd)]
    39       root      2     I    0.0  161:41:52  00:00.00            [(blkcg_punt_bio)]
    40       root      2     I    0.0  161:41:52  00:00.00            [(tpm_dev_wq)]
    41       root      2     I    0.0  161:41:52  00:00.00            [(edac-poller)]
    42       root      2     I    0.0  161:41:52  00:00.00            [(devfreq_wq)]
    43       root      2     I    0.0  161:41:52  00:00.81            [(kworker/1:1H-kblockd)]
    44       root      2     S    0.0  161:41:52  00:00.48            [(kswapd0)]
    50       root      2     I    0.0  161:41:51  00:00.00            [(kthrotld)]
    52       root      2     I    0.0  161:41:51  00:00.00            [(acpi_thermal_pm)]
    54       root      2     I    0.0  161:41:51  00:00.00            [(mld)]
    55       root      2     I    0.0  161:41:51  00:00.00            [(ipv6_addrconf)]
    60       root      2     I    0.0  161:41:51  00:00.00            [(kstrp)]
    65       root      2     I    0.0  161:41:51  00:00.00            [(zswap-shrink)]
    66       root      2     I    0.0  161:41:51  00:00.00            [(kworker/u5:0)]
   121       root      2     I    0.0  161:41:51  00:00.54            [(kworker/0:1H-kblockd)]
   123       root      2     I    0.0  161:41:51  00:00.00            [(ata_sff)]
   125       root      2     S    0.0  161:41:51  00:00.00            [(scsi_eh_0)]
   127       root      2     I    0.0  161:41:51  00:00.00            [(scsi_tmf_0)]
   128       root      2     S    0.0  161:41:51  00:00.00            [(scsi_eh_1)]
   129       root      2     I    0.0  161:41:51  00:00.00            [(scsi_tmf_1)]
   132       root      2     S    0.0  161:41:51  00:00.00            [(scsi_eh_2)]
   133       root      2     I    0.0  161:41:51  00:00.00            [(scsi_tmf_2)]
   142       root      2     I    0.0  161:41:50  00:00.00            [(kdmflush/254:0)]
   143       root      2     I    0.0  161:41:50  00:00.00            [(kdmflush/254:1)]
   155       root      2     I    0.0  161:41:49  00:00.00            [(md)]
   165       root      2     I    0.0  161:41:49  00:00.00            [(raid5wq)]
   207       root      2     S    0.0  161:41:49  00:03.44            [(jbd2/dm-0-8)]
   208       root      2     I    0.0  161:41:49  00:00.00            [(ext4-rsv-conver)]
   262       root      1     S    0.0  161:41:49  00:02.69   20500 KB /lib/systemd/systemd-journald
   271       root      2     I    0.0  161:41:49  00:00.00            [(rpciod)]
   273       root      2     I    0.0  161:41:49  00:00.00            [(xprtiod)]
   294       root      1     S    0.0  161:41:48  00:00.55    6624 KB /lib/systemd/systemd-udevd
   367       root      2     I    0.0  161:41:48  00:00.00            [(cryptd)]
   494       root      2     S    0.0  161:41:48  00:00.00            [(spl_system_task)]
   495       root      2     S    0.0  161:41:48  00:00.00            [(spl_delay_taskq)]
   496       root      2     S    0.0  161:41:48  00:00.00            [(spl_dynamic_tas)]
   497       root      2     S    0.0  161:41:48  00:00.00            [(spl_kmem_cache)]
   499       root      2     I    0.0  161:41:47  00:00.00            [(ext4-rsv-conver)]
   500       root      2     S    0.0  161:41:47  00:00.00            [(zvol_tq-0)]
   501       root      2     S    0.0  161:41:47  00:00.00            [(arc_prune)]
   502       root      2     S    0.0  161:41:47  00:07.53            [(arc_evict)]
   503       root      2     S    0.0  161:41:47  00:03.46            [(arc_reap)]
   504       root      2     S    0.0  161:41:47  00:00.00            [(dbu_evict)]
   505       root      2     S    0.0  161:41:47  00:03.32            [(dbuf_evict)]
   506       root      2     S    0.0  161:41:47  00:00.00            [(z_vdev_file)]
   507       root      2     S    0.0  161:41:47  00:05.83            [(l2arc_feed)]
   534       _rpc      1     S    0.0  161:41:47  00:00.53    3344 KB /sbin/rpcbind -f -w
   536 systemd-timesync      1     S    0.0  161:41:47  00:01.30    6772 KB /lib/systemd/systemd-timesyncd
   544       root      1     S    0.0  161:41:47  00:00.00     180 KB /usr/sbin/blkmapd
   548       root      1     S    0.0  161:41:47  00:00.00    1888 KB /usr/sbin/rpc.idmapd
   549       root      1     S    0.0  161:41:47  00:00.00    2688 KB /usr/sbin/nfsdcld
   555       root      1     S    0.0  161:41:47  00:06.36    9580 KB /usr/libexec/accounts-daemon
   558      avahi      1     S    0.0  161:41:47  00:07.17    3980 KB avahi-daemon: running [Otus-debian.local]
   559       root      1     S    0.0  161:41:47  00:00.76    2676 KB /usr/sbin/cron -f
   562 messagebus      1     S    0.0  161:41:47  00:01.25    5328 KB /usr/bin/dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
   564    polkitd      1     S    0.0  161:41:47  00:00.42   11628 KB /usr/lib/polkit-1/polkitd --no-debug
   566       root      1     S    0.0  161:41:47  04:23.84    3796 KB /usr/sbin/qemu-ga
   569       root      1     S    0.0  161:41:47  00:00.75    7620 KB /lib/systemd/systemd-logind
   575       root      1     S    0.0  161:41:47  00:00.41   13952 KB /usr/libexec/udisks2/udisksd
   582       root      1     S    0.0  161:41:47  00:00.00    4840 KB /usr/sbin/zed -F
   588      avahi    558     S    0.0  161:41:47  00:00.00     336 KB avahi-daemon: chroot helper
   593       root      1     S    0.0  161:41:47  00:52.80   22088 KB /usr/sbin/NetworkManager --no-daemon
   609       root      1     S    0.0  161:41:47  00:01.76    5664 KB /sbin/wpa_supplicant -u -s -O DIR=/run/wpa_supplicant GROUP=netdev
   627       root      1     S    0.0  161:41:47  00:00.09   11784 KB /usr/sbin/ModemManager
   658       root      1     S    0.0  161:41:46  00:00.09    7084 KB /usr/sbin/lightdm
   674     colord      1     S    0.0  161:41:46  00:00.15   12000 KB /usr/libexec/colord
   676       root      1     S    0.0  161:41:46  00:00.02    8676 KB sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
   680       root    658     S    0.0  161:41:46  00:17.83  116624 KB /usr/lib/xorg/Xorg :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp vt7 -novtswitch
   681       root      1     S    0.0  161:41:46  00:00.00     876 KB /sbin/agetty -o -p -- \u --noclear - linux
   752      statd      1     S    0.0  161:41:46  00:00.00    1820 KB /sbin/rpc.statd
   754       root      1     S    0.0  161:41:46  00:00.00     380 KB /usr/sbin/rpc.mountd
   797       root      2     I    0.0  161:41:46  00:00.00            [(lockd)]
   895       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   896       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   900       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   903       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   905       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   906       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   907       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
   908       root      2     I    0.0  161:41:46  00:00.00            [(nfsd)]
  1151      rtkit      1     S    0.0  161:41:45  00:03.47    1236 KB /usr/libexec/rtkit-daemon
  8472       root      1     S    0.0  141:58:26  00:01.20    3324 KB /usr/lib/postfix/sbin/master -w
  8474    postfix   8472     S    0.0  141:58:26  00:00.30    4976 KB qmgr -l -t unix -u
  8484    postfix   8472     S    0.0  141:57:58  00:00.11    9612 KB tlsmgr -l -t unix -u -c
 46745       root      1     S    0.0   09:51:58  00:00.01    8048 KB /usr/sbin/cupsd -l
 46749       root      1     S    0.0   09:51:58  00:00.06   13668 KB /usr/sbin/cups-browsed
 46755         lp  46745     S    0.0   09:51:43  00:00.00    4508 KB /usr/lib/cups/notifier/dbus dbus://
 46816       root      2     I    0.0   09:43:10  00:01.41            [(kworker/1:1-events_freezable)]
 47995       root      2     I    0.0   01:16:58  00:00.05            [(kworker/u4:2-flush-254:0)]
 48133       root    658     S    0.0   00:26:37  00:00.08    7512 KB lightdm --session-child 13 24
 48138  resovalko      1     S    0.0   00:26:34  00:00.15   10376 KB /lib/systemd/systemd --user
 48139  resovalko  48138     S    0.0   00:26:34  00:00.00    4384 KB (sd-pam)
 48155  resovalko  48138     S    0.0   00:26:34  00:00.07    9660 KB /usr/bin/pulseaudio --daemonize=no --log-target=journal
 48157  resovalko  48138     S    0.0   00:26:34  00:00.04    8300 KB /usr/bin/gnome-keyring-daemon --foreground --components=pkcs11,secrets --control-directory=/run/user/1000/keyring
 48163  resovalko  48138     S    0.0   00:26:34  00:00.10    4520 KB /usr/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
 48169  resovalko  48133     S    0.0   00:26:34  00:00.28   13896 KB x-session-manager
 48214  resovalko  48169     S    0.0   00:26:34  00:00.00       0 KB /usr/bin/ssh-agent x-session-manager
 48215  resovalko  48138     S    0.0   00:26:34  00:00.02    6784 KB /usr/libexec/at-spi-bus-launcher
 48221  resovalko  48215     S    0.0   00:26:34  00:00.02    4404 KB /usr/bin/dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 11 --address=unix:path=/run/user/1000/at-spi/bus_0
 48238  resovalko  48138     S    0.0   00:26:33  00:00.00    5600 KB /usr/libexec/dconf-service
 48243  resovalko  48169     S    0.0   00:26:33  00:00.55   28712 KB /usr/bin/mate-settings-daemon
 48245  resovalko  48138     S    0.0   00:26:33  00:00.04    9420 KB /usr/libexec/at-spi2-registryd --use-gnome-session
 48251  resovalko  48169     S    0.0   00:26:33  00:00.63   28860 KB marco
 48252  resovalko  48138     S    0.0   00:26:33  00:00.01    6668 KB /usr/libexec/gvfsd
 48259  resovalko  48138     S    0.0   00:26:33  00:00.01    7420 KB /usr/libexec/gvfsd-fuse /run/user/1000/gvfs -f
 48270  resovalko  48169     S    0.0   00:26:32  00:00.61   30916 KB mate-panel
 48293  resovalko  48169     S    0.1   00:26:32  00:01.03   41512 KB /usr/bin/caja
 48297  resovalko  48138     S    0.0   00:26:32  00:00.04   11896 KB /usr/libexec/gvfs-udisks2-volume-monitor
 48299  resovalko  48169     S    0.0   00:26:32  00:00.17   17556 KB mate-screensaver
 48302  resovalko  48169     S    0.0   00:26:32  00:00.26   25860 KB mate-volume-control-status-icon
 48305  resovalko  48169     S    0.0   00:26:32  00:00.03   13180 KB /usr/libexec/polkit-mate-authentication-agent-1
 48311  resovalko  48169     S    0.0   00:26:32  00:00.21   25740 KB nm-applet
 48316  resovalko  48138     S    0.0   00:26:32  00:00.02    8228 KB /usr/libexec/gvfs-mtp-volume-monitor
 48318  resovalko  48169     S    0.0   00:26:32  00:00.18   19712 KB mate-power-manager
 48327  resovalko  48138     S    0.0   00:26:32  00:00.01    8088 KB /usr/libexec/gvfs-goa-volume-monitor
 48337  resovalko  48138     S    0.0   00:26:31  00:00.10   15116 KB /usr/libexec/xdg-desktop-portal
 48338  resovalko  48138     S    0.0   00:26:31  00:00.07   11904 KB /usr/libexec/gvfs-afc-volume-monitor
 48346  resovalko  48138     S    0.0   00:26:31  00:00.02    8828 KB /usr/libexec/xdg-document-portal
 48354  resovalko  48138     S    0.0   00:26:31  00:00.03    8744 KB /usr/libexec/gvfs-gphoto2-volume-monitor
 48355  resovalko  48138     S    0.0   00:26:31  00:00.02    7632 KB /usr/libexec/xdg-permission-store
 48368  resovalko  48346     S    0.0   00:26:31  00:00.00     880 KB fusermount3 -o rw,nosuid,nodev,fsname=portal,auto_unmount,subtype=portal -- /run/user/1000/doc
 48374  resovalko  48138     S    0.0   00:26:31  00:00.22   26576 KB /usr/lib/mate-panel/wnck-applet
 48377  resovalko  48138     S    0.0   00:26:31  00:00.11   14600 KB /usr/libexec/xdg-desktop-portal-gtk
 48380  resovalko  48138     S    0.0   00:26:31  00:00.15   21848 KB /usr/lib/mate-panel/notification-area-applet
 48381  resovalko  48138     S    0.0   00:26:31  00:00.29   25720 KB /usr/lib/mate-panel/clock-applet
 48393       root      1     S    0.0   00:26:31  00:00.09    8856 KB /usr/libexec/upowerd
 48498  resovalko  48252     S    0.0   00:26:30  00:00.01   11352 KB /usr/libexec/gvfsd-trash --spawner :1.16 /org/gtk/gvfs/exec_spaw/0
 48538       root      2     I    0.0   00:26:24  00:00.07            [(kworker/1:4-events)]
 48539  resovalko  48270     S    0.1   00:26:23  00:00.85   34120 KB mate-terminal
 48571  resovalko  48539     S    0.0   00:26:23  00:00.01    4920 KB bash
 48573       root      2     I    0.0   00:26:13  00:00.06            [(kworker/0:2-events)]
 51328    postfix   8472     S    0.0   00:21:03  00:00.01    7040 KB pickup -l -t unix -u -c
 51330       root      2     I    0.0   00:18:03  00:00.00            [(kworker/0:0)]
 51331       root    676     S    0.0   00:15:09  00:00.14   10856 KB sshd: resovalko [priv]
 51337  resovalko  51331     S    0.0   00:14:58  00:00.16    6840 KB sshd: resovalko@pts/1
 51338  resovalko  51337     S    0.0   00:14:58  00:00.01    4808 KB -bash
 51341  resovalko  51338     S    0.0   00:14:56  00:00.15    4648 KB sudo -i
 51342  resovalko  51341     S    0.0   00:14:53  00:00.00     548 KB sudo -i
 51343       root  51342     S    0.0   00:14:53  00:00.03    5804 KB -bash
 56749       root      2     I    0.0   00:06:16  00:00.01            [(kworker/u4:0-events_unbound)]
 56754       root  51343     R   35.0   00:00:01  00:00.35    3424 KB /bin/bash ./process_list_proc.sh
```
