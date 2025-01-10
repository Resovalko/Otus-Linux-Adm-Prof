# Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**

### Виртуальная машина 1
> Ubuntu 22.04.5 LTS x86_64 Desktop
> CPU: host (Intel i7-7700)  
> Sockets: 4  
> Memory: 4096  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

> Vagrant 2.4.3  
> Oracle VM VirtualBox VM Selector v7.0.22  
> ansible 2.10.8  

### Виртуальная машина 2
> Debian GNU/Linux 12 (bookworm)  
> CPU: x86-64-v2-AES  
> Sockets: 2  
> Memory: 1024  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

### Виртуальная машина 3
> Ubuntu 24.04.1 LTS x86_64 Server  
> CPU: x86-64-v2-AES  
> Sockets: 2  
> Memory: 1024  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

## Обновление ядра CentOS8 Stream на основе учебной методички (на "виртуальной машине 1" с использованием Vagrant и VirtualBox)

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

## Обновление ядра Debian 12 Bookworm (на "виртуальной машине 2")
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

## Обновление ядра Ubuntu 24 (на "виртуальной машине 3")

Смотрю версию ядра  
> root@otusu24srv:~# uname -rms  
> Linux 6.8.0-51-generic x86_64  

Полностью обновляю систему  
> root@otusu24srv:~# apt update && apt upgrade -y  

Скачиваю необходимые файлы с сайта https://kernel.ubuntu.com  
> root@otusu24srv:~# wget https://kernel.ubuntu.com/mainline/v6.12/amd64/linux-headers-6.12.0-061200-generic_6.12.0-061200.202411220723_amd64.deb  

> root@otusu24srv:~# wget https://kernel.ubuntu.com/mainline/v6.12/amd64/linux-headers-6.12.0-061200_6.12.0-061200.202411220723_all.deb  

> root@otusu24srv:~# wget https://kernel.ubuntu.com/mainline/v6.12/amd64/linux-image-unsigned-6.12.0-061200-generic_6.12.0-061200.202411220723_amd64.deb  

> root@otusu24srv:~# wget https://kernel.ubuntu.com/mainline/v6.12/amd64/linux-modules-6.12.0-061200-generic_6.12.0-061200.202411220723_amd64.deb  

Устанавливаю скачанные пакеты  
> root@otusu24srv:~# dpkg -i linux-*  

Перезагружаюсь  
> root@otusu24srv:~# reboot  

Захожу и проверяю версию ядра  
> root@otusu24srv:~# uname -rms  
> Linux 6.12.0-061200-generic x86_64  