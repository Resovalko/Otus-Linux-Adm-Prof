Обновление ядра CentOS8 Steam на основе учебной методички (С использованием Vagrant и VirtualBox)

Смотрю версию ядра
[vagrant@kernel-update ~]$ uname -msr
Linux 4.18.0-516.el8.x86_64 x86_64

Обновляю ссылокы на репозитории
[vagrant@kernel-update ~]$ sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
[vagrant@kernel-update ~]$ sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
[vagrant@kernel-update ~]$ sudo yum update -y

Смотрю какие ядра в системе
[vagrant@kernel-update ~]$ rpm -qa | grep kernel-

Ставлю репозиторий ELRepo, импортирую публичный ключ:
[vagrant@kernel-update ~]$ sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

Устанавливаю репозиторий ELRepo для RHEL-8:
[vagrant@kernel-update ~]$ sudo yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

Смотрю список доступных ядер
[vagrant@kernel-update ~]$ yum list available --disablerepo='*' --enablerepo=elrepo-kernel

Устанавливаю новую версию ядра
[vagrant@kernel-update ~]$ sudo yum --enablerepo=elrepo-kernel install kernel-ml

Перезагружаю систему
[vagrant@kernel-update ~]$ sudo reboot

Смотрю версию ядра
[vagrant@kernel-update ~]$ uname -rms
Linux 6.12.6-1.el8.elrepo.x86_64 x86_64
