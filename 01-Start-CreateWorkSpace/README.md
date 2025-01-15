# Настройка виртуальной среды на базе VirtualBox и Vagrant

## Рабочее пространство
Система виртуализации **PROXMOX 8.3.1**

Согластно методичке подготовлена виртуальная машина с актуальными версиями Vagrant, VirtualBox, ansible  
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
> ansible [core 2.17.7]  

На **виртуальной машине 1** запущены две виртуальные ВМ **test_vm** и **test_vm1** виртуальная среда которых описана в соответствующем Vagrant-файле:  

### test_vm  
Чистая виртуальная машина на основе образа Ubuntu 20.04 (focal64) 
``` 
resovalko@otus-ubuntu:~/otus/01-Start-CreateWorkSpace/test_vm$ vagrant ssh
Welcome to Ubuntu 20.04.6 LTS (GNU/Linux 5.4.0-204-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Fri Jan 10 07:39:50 UTC 2025

  System load:  0.0               Processes:               116
  Usage of /:   3.7% of 38.70GB   Users logged in:         0
  Memory usage: 20%               IPv4 address for enp0s3: 10.0.2.15
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '22.04.5 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Fri Jan 10 07:32:18 2025 from 10.0.2.2
vagrant@ubuntu-focal:~$ uname -a
Linux ubuntu-focal 5.4.0-204-generic #224-Ubuntu SMP Thu Dec 5 13:38:28 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```

### test_vm1
Чистая виртуальная машина на основе образа Ubuntu 20.04 (focal64) 
  
Добавлена конкретная версия сборки  
> config.vm.box_version = "20220427.0.0"  

Указано имя для Vagrant, VirtualBox, виртуальной машины
> config.vm.define "webserver"  
> vb.name = "vagrant-webserver-tst"  
> config.vm.hostname = "webtest"  

Выделено одно ядро и 1024МБ памяти
> vb.memory = "1024"  
> vb.cpus = "1"  

Проброшен порт 80 с гостевой ВМ на порт 8080 хостовой машины  
> config.vm.network "forwarded_port", guest: 80, host: 8080  

После развертывания установится Веб-сервер Apache  
> config.vm.provision "shell", inline: <<-SHELL  
>      sudo apt-get update  
>      sudo apt-get install -y apache2  
>   SHELL  
  
После запуска ВМ по адресу http://127.0.0.1:8080 увидим страницу приветствия Apache.  
```
resovalko@otus-ubuntu:~/otus/01-Start-CreateWorkSpace/test_vm1$ vagrant ssh
vagrant@webtest:~$ uname -a
Linux webtest 5.4.0-204-generic #224-Ubuntu SMP Thu Dec 5 13:38:28 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
vagrant@webtest:~$ logout
resovalko@otus-ubuntu:~/otus/01-Start-CreateWorkSpace/test_vm1$ curl -IL http://127.0.0.1:8080
HTTP/1.1 200 OK
Date: Fri, 10 Jan 2025 08:09:55 GMT
Server: Apache/2.4.41 (Ubuntu)
Last-Modified: Fri, 10 Jan 2025 07:36:12 GMT
ETag: "2aa6-62b55262b0694"
Accept-Ranges: bytes
Content-Length: 10918
Vary: Accept-Encoding
Content-Type: text/html
```
