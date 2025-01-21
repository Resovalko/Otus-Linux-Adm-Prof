# Автоматизация администрирования. Ansible.

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


На **основной виртуальной машине** запущена ВМ **test_vm1** с использование Vagrant:  

https://github.com/Resovalko/Otus-Linux-Adm-Prof/tree/main/01-Start-CreateWorkSpace/test_vm1

### Виртуальная машина в **PROXMOX**
> Debian GNU/Linux 12 (bookworm)  
> CPU: x86-64-v2-AES  
> Sockets: 2  
> Memory: 1024  
> Hard disk: 32G  
> BIOS: SeaBIOS  
> Machine: i440fx  

## Playbook для установки и настройки NGINX
Файл playbook расположен в *playbooks/pb_1.yaml*  
Шаблоны для настройки расположены в *playbooks/templates*  

### Запуск выполнения командой
> ansible-playbook playbooks/pb_1.yaml --limit webservers --ask-become-pass  

**playbooks/pb_1.yaml** - указываем путь до playbook  
**--limit webservers** - ограничеванием выполение на группе серверов *webservers*, указанных в файле *inventory.yaml*  
**--ask-become-pass** - запрашиваем пароль для повышения привилегий  

### Результат

```
PLAY RECAP *********************************************************************************************
debian                     : ok=16   changed=4    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
vagrant_vm2                : ok=20   changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
На сервере **debian** установлен и настроен NGINX (nginx/1.22.1), доступен на порту **81**  

```
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl 10.126.112.216:81
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on Otus-debian</h1>
    <p>Server IP: 10.126.112.216</p>
</body>
</html>
```
На сервере **vagrant_vm2** установлен репозиторий NGINX из которого установлен NGINX (nginx/1.26.2) с последующей настройкой, доступен на внутреннем порту **81**, на порту хост-машины **8081**  
```
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl 127.0.0.1:8081
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on webtest</h1>
    <p>Server IP: 10.0.2.15</p>
</body>
</html>
```  

## Установка и настройка NGINX с использованием ролей  
Файл playbook с использованием ролей - *site.yaml*  
Папка с ролями - *roles*, для создания структуры использована комманда *ansible-galaxy init roles/имя_роли*

### Запуск выполнения командой
> ansible-playbook site.yaml --ask-become-pass  

**site.yaml** - указываем playbook  
**--ask-become-pass** - запрашиваем пароль для повышения привилегий  

### Результат

```
PLAY RECAP **************************************************************************************************************************
debian                     : ok=10   changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
vagrant_vm2                : ok=12   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
На сервере **debian** установлен и настроен NGINX (nginx/1.22.1), доступен по *http* на порту **82** и по *https* на порту **442**

```
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl http://10.126.112.216:82
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on Otus-debian</h1>
    <p>Server IP: 10.126.112.216</p>
    <p>Server HTTP port: 82</p>
    <p>Server HTTPS port: 442</p>
</body>
</html>
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl -k https://10.126.112.216:442
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on Otus-debian</h1>
    <p>Server IP: 10.126.112.216</p>
    <p>Server HTTP port: 82</p>
    <p>Server HTTPS port: 442</p>
</body>
</html>

```
На сервере **vagrant_vm2** установлен репозиторий NGINX из которого установлен NGINX (nginx/1.26.2) с последующей настройкой, доступен по *http* на внутреннем порту **82** и по *https* на внутреннем порту **442**, на порту хост-машины **8082** и **8042** соответственно
```
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl http://127.0.0.1:8082/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on webtest</h1>
    <p>Server IP: 10.0.2.15</p>
    <p>Server HTTP port: 82</p>
    <p>Server HTTPS port: 442</p>
</body>
</html>
resovalko@otus-ubuntu:~/otus/03-04-Ansible$ curl -k https://127.0.0.1:8042/
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx on webtest</h1>
    <p>Server IP: 10.0.2.15</p>
    <p>Server HTTP port: 82</p>
    <p>Server HTTPS port: 442</p>
</body>
</html>
```  
