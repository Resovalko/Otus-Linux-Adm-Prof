## Обновление ядра CentOS8 Stream на основе учебной методички (с использованием Vagrant и VirtualBox)

Смотрю версию ядра  
> [vagrant@kernel-update ~]$ uname -msr  
> Linux 4.18.0-516.el8.x86_64 x86_64  

Обновляю ссылки на репозитории  
> [vagrant@kernel-update ~]$ sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*  
> [vagrant@kernel-update ~]$ sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*  
> [vagrant@kernel-update ~]$ sudo yum update -y  

Смотрю какие ядра в системе
> [vagrant@kernel-update ~]$ rpm -qa | grep kernel-

Ставлю репозиторий ELRepo, импортирую публичный ключ:
> [vagrant@kernel-update ~]$ sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

Устанавливаю репозиторий ELRepo для RHEL-8:
> [vagrant@kernel-update ~]$ sudo yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

Смотрю список доступных ядер
> [vagrant@kernel-update ~]$ yum list available --disablerepo='*' --enablerepo=elrepo-kernel

Устанавливаю новую версию ядра
> [vagrant@kernel-update ~]$ sudo yum --enablerepo=elrepo-kernel install kernel-ml

Перезагружаю систему
> [vagrant@kernel-update ~]$ sudo reboot

Смотрю версию ядра
> [vagrant@kernel-update ~]$ uname -rms
> Linux 6.12.6-1.el8.elrepo.x86_64 x86_64

## Обновление ядра Debian 12 Bookworm
### Метод 1

Полностью обновляю систему
> root@Otus-debian:~# apt update && apt upgrade

Смотрю версию ядра
> root@Otus-debian:~# uname -rms
> Linux 6.1.0-28-amd64 x86_64

Добавляю репозиторий
> root@Otus-debian:~# echo "deb http://ftp.debian.org/debian/ bookworm-backports main non-free contrib" >> /etc/apt/sources.list

Обновляю список доступных пакетов
> root@Otus-debian:~# apt update

Смотрю что установлено
> root@Otus-debian:~# apt search linux-image | grep installed

Смотрю какие версии ядра доступны и выбираю
> root@Otus-debian:~# apt search linux-image

Устанавливаю выбранное ядро
> root@Otus-debian:~# apt install linux-image-6.11.10+bpo-amd64

Перезагружаюсь
> root@Otus-debian:~# reboot

Захожу и проверяю версию ядра
> root@Otus-debian:~# uname -rms
> Linux 6.11.10+bpo-amd64 x86_64

### Метод 2 (Linux Zabbly APT)

Полностью обновляю систему
> root@Otus-debian:~# apt update && apt upgrade

Импортирую ключ репозитория  
> root@Otus-debian:~# curl -fsSL https://pkgs.zabbly.com/key.asc | gpg --show-keys --fingerprint  
> root@Otus-debian:~# curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc  

Добавляю репозиторий
```
root@Otus-debian:~# sh -c 'cat <<EOF > /etc/apt/sources.list.d/zabbly-kernel-stable.sources
Enabled: yes
Types: deb
URIs: https://pkgs.zabbly.com/kernel/stable
Suites: $(. /etc/os-release && echo ${VERSION_CODENAME})
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/zabbly.asc

EOF'
```
Обновляю список доступных пакетов
> root@Otus-debian:~# apt update

Устанавливаю ядро (текущая версия 6.12.6)
> root@Otus-debian:~# apt install linux-zabbly

Перезагружаюсь
> root@Otus-debian:~# reboot

Захожу и проверяю версию ядра
> root@Otus-debian:~# uname -rms
> Linux 6.12.6-zabbly+ x86_64




