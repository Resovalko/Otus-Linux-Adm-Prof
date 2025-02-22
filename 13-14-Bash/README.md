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

## Скрипт для анализа лога web-сервера с отправкой отчета на почту

### Создаем файл скрипта
Создаю директорию **/scripts** в которой создаю файл с именем **web_log_analizer**
> root@Otus-debian:/# mkdir scripts

> root@Otus-debian:/# touch /scripts/web_log_analizer

> root@Otus-debian:/# chmod +x /scripts/web_log_analizer

Будем работать с логами **Nginx**, которые по умолчанию располагаются в **/var/log/nginx/access.log**.  
Отправлять отчет будем для **root**.  

[Посмотреть скрипт](https://github.com/Resovalko/Otus-Linux-Adm-Prof/blob/main/13-14-Bash/web_log_analizer)

#### Проверим работу скрипта
> root@Otus-debian:/scripts# ./web_log_analizer
```
Будет использоваться команда 'mail' для отправки писем.
Письмо успешно отправлено пользователю root.
```
У нас появилось новое письмо
> root@Otus-debian:/scripts# mail
```
Mail version 8.1.2 01/15/2001.  Type ? for help.
"/var/mail/root": 1 message 1 new
>N  1 root@Otus-debian.  Sat Feb 22 12:25  126/8343  Отчет за 2025-02-22 12:25:14 - 2025-02-22 12:25:35
&
```
Прочитаем его:
```
Message 1:
From root@Otus-debian.lan  Sat Feb 22 12:25:35 2025
X-Original-To: root
To: root@Otus-debian.lan
Subject: Отчет за 2025-02-22 12:25:14 - 2025-02-22 12:25:35
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sat, 22 Feb 2025 12:25:35 +0300 (MSK)
From: root <root@Otus-debian.lan>

==================================================
📊 Отчет о веб-трафике с 2025-02-22 12:25:14 по 2025-02-22 12:25:35
==================================================

🔥 Топ 10 IP-адресов по количеству запросов:
IP-адрес        Количество запросов
-------------------- -------------------
93.158.167.130       45
109.236.252.130      39
212.57.117.19        37
188.43.241.106       33
87.250.233.68        31
62.75.198.172        24
148.251.223.21       22
185.6.8.9            20

🌐 Топ 10 запрашиваемых URL:
URL                                                Количество запросов
-------------------------------------------------- -------------------
/                                                  157
/wp-login.php                                      120
/xmlrpc.php                                        57
/robots.txt                                        26
/favicon.ico                                       12
400                                                11
/wp-includes/js/wp-embed.min.js?ver=5.0.4          9
/wp-admin/admin-post.php?page=301bulkoptions       7

📥 Сводка кодов HTTP-ответов:
HTTP Код Количество
---------- ----------
200        498
301        95
404        51
"-"        11
400        7
500        3
499        2
405        1
403        1
304        1

⚠️ Ошибки веб-сервера (коды 4xx и 5xx):
[[14/Aug/2019:05:02:20] 93.158.167.130  /                                                  404
[[14/Aug/2019:05:04:20] 87.250.233.68   /                                                  404
[[14/Aug/2019:05:22:10] 107.179.102.58  /wp-content/plugins/uploadify/readme.txt           404
[[14/Aug/2019:06:02:50] 193.106.30.99   /wp-includes/ID3/comay.php                         500
[[14/Aug/2019:06:07:07] 87.250.244.2    /                                                  404
[[14/Aug/2019:06:13:53] 77.247.110.165  /robots.txt                                        404
[[14/Aug/2019:06:45:20] 87.250.233.76   /                                                  404
[[14/Aug/2019:07:07:19] 71.6.199.23     /robots.txt                                        404
[[14/Aug/2019:07:07:20] 71.6.199.23     /sitemap.xml                                       404
[[14/Aug/2019:07:07:20] 71.6.199.23     /.well-known/security.txt                          404
[[14/Aug/2019:07:07:21] 71.6.199.23     /favicon.ico                                       404
[[14/Aug/2019:07:09:43] 141.8.141.136   /                                                  404
[[14/Aug/2019:08:10:56] 93.158.167.130  /                                                  404
[[14/Aug/2019:08:21:48] 87.250.233.68   /                                                  404
...
```
#### Добавим запись в **cron** что бы периодически выполнять скрипт и получать отчет
> root@Otus-debian:/scripts# crontab -e

Добавим строку:
```
0 * * * * /scripts/web_log_analizer > /scripts/web_log_analizer.log 2>&1
```
Скрипт будет выполняться каждый час и записывать небольшой лог.

### Отправка отчета на внешний адрес электронной почты (на примере gmail)
Если система настроена на отправку сообщений на внешние адреса электронной почты, то мы можем получать результаты работы скрипта не в кносоль, а на свой адрес электронной почты.  

Нам потребуется **Postfix**:
> root@Otus-debian:/scripts# apt install postfix postfix-pcre libsasl2-modules mailutils
![postfix install](img/bash01.png)

#### Сконфигурируем Postfix
Приведем файл [**/etc/postfix/main.cf**](https://github.com/Resovalko/Otus-Linux-Adm-Prof/blob/main/13-14-Bash/main.cf) к следующему виду:
```
# See /usr/share/postfix/main.cf.dist for a commented, more complete version


# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = $myhostname ESMTP $mail_name (Debian/GNU)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

#readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 3.6 on
# fresh installs.
compatibility_level = 3.6

myhostname = Otus-debian.lan
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydestination = $myhostname, Otus-debian, localhost.localdomain, localhost
mynetworks = 127.0.0.0/8
recipient_delimiter = +
inet_interfaces = loopback-only

#google mail
relayhost = smtp.gmail.com:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/Entrust_Root_Certification_Authority.pem
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
smtp_tls_session_cache_timeout = 3600s
smtp_header_checks = pcre:/etc/postfix/smtp_header_checks
```
**Создадим файл с логином и паролем для SMTP:**
> root@Otus-debian:/scripts# echo "smtp.gmail.com your-email@gmail.com:YourAppPassword" > /etc/postfix/sasl_passwd

> root@Otus-debian:/scripts# postmap hash:/etc/postfix/sasl_passwd

> root@Otus-debian:/scripts# chmod 600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

> root@Otus-debian:/scripts# nano /etc/postfix/smtp_header_checks
Добавим сюда такую запись:
```
/^From:.*/ REPLACE From: Otus.bash otus.bash@something.com
```
> root@Otus-debian:/scripts# postmap hash:/etc/postfix/smtp_header_checks

> root@Otus-debian:/scripts# systemctl restart postfix

Отредактируем файл **/etc/aliases**:
> root@Otus-debian:/scripts#  nano /etc/aliases
Ищем строку, начинающуюся с root: и изменяем её (либо добавляем строку, если её нет):
```
root: yourusername@gmail.com
```
И применим изменения:
> root@Otus-debian:/scripts# newaliases

**Проверить можем отправив тестовое письмо:**
> root@Otus-debian:/scripts#  echo "Test message" | mail -s "Test Subject" yourusername@gmail.com

#### Если все сделано правильно, в результате работы скрипта мы должны получить письмо на тот электронный адрес, который указали в конфигах

![mail report](img/bash02.png)

<!-- ```bash
root@Otus-debian:/etc/default# cat >> /etc/default/watchlog << EOF
# Configuration file for my watchlog service
# Place it to /etc/default
# File and word in that file that we will be monit
WORD="ALERT"
LOG="/var/log/watchlog.log"
EOF
```
Где **WORD="ALERT"** - ключевое слово  
**LOG=/var/log/watchlog.log** - лог в котором ищем ключевое слово  

Файл **/var/log/watchlog.log** заполняем случайными данными с использованием ключевего слова **ALERT**

#### Создаем скрипт в директории /scripts
Создаем файл скрипта который должен быть с правами на выполнение:
> root@Otus-debian:/scripts# touch check_log.sh

> root@Otus-debian:/scripts# chmod +x check_log.sh

Записываем наш скрипт в файл **/scripts/check_log.sh**:
```bash
root@Otus-debian:/scripts# cat > /scripts/check_log.sh <<EOF
#!/bin/bash

# Проверка, переданы ли аргументы
if [[ \$# -ne 2 ]]; then
    echo "Usage: \$0 <word> <logfile>"
    exit 1
fi

WORD="\$1"
LOG="\$2"
DATE="\$(date +'%Y-%m-%d %H:%M:%S')"

# Проверка существования файла
if [[ ! -f "\$LOG" ]]; then
    echo "Error: File '\$LOG' not found!"
    exit 2
fi

# Поиск слова в файле лога
if grep -q "\$WORD" "\$LOG"; then
    MESSAGE="\$DATE: Found word '\$WORD' in '\$LOG'"
    echo "\$MESSAGE"
    logger "\$MESSAGE"
else
    echo "\$DATE: Word '\$WORD' not found in '\$LOG'"
    exit 0
fi
EOF
```
Небольшие изменения/описание:  
- Добавлена проверка аргументов – если не передано 2 аргумента, выводится сообщение об использовании.  
- Добавлена проверка существования файла – если файл не найден, скрипт выводит ошибку и завершает работу.  
- Используются кавычки вокруг переменных – защита от пробелов в аргументах.  
- Используется **grep -q** – ускоряет поиск, т.к. не выводит лишний текст.  
- Вывод сообщений в терминал – теперь видно, найдено ли слово или нет.  
- Логирование через **logger** – запись в системный журнал (/var/log/syslog).  

#### Создаем unit-файл для systemd
> root@Otus-debian:/scripts# touch /etc/systemd/system/check_log.service
```bash
root@Otus-debian:/scripts# cat > /etc/systemd/system/check_log.service <<EOF
[Unit]
Description=Log Monitoring Service
After=network.target

[Service]
EnvironmentFile=/etc/default/watchlog
ExecStart=/scripts/check_log.sh "\$WORD" "\$LOG"
Type=oneshot
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

**Type=oneshot** → Если скрипт выполняется разово и завершает работу.  
**Type=simple (по умолчанию)** → Если сервис должен работать постоянно.  

#### Создаём таймер (unit-файл check_log.timer) для запуска сервиса (запуск 1 раз в 30 секунд) 
> root@Otus-debian:/scripts# touch /etc/systemd/system/check_log.timer

```bash
root@Otus-debian:/scripts# cat > /etc/systemd/system/check_log.timer <<EOF
[Unit]
Description=Timer to run check_log service every 30 seconds

[Timer]
OnBootSec=1min
OnUnitActiveSec=30

[Install]
WantedBy=timers.target
EOF
```

**OnBootSec=1min** — первый запуск через 1 минуту после загрузки.  
**OnUnitActiveSec=30** — затем запуск каждые 30 секунд.  
  
В **systemd.timer** не нужно указывать **Unit=check_log.service**, потому что systemd автоматически связывает таймер с сервисом по его имени.  
У таймера **check_log.timer** по умолчанию активируется сервис с таким же именем: **check_log.service** (то есть systemctl start check_log.timer запустит check_log.service).  
Это правило работает автоматически и соответствует стандартной практике в systemd.  
  
Если таймер должен запускать другой сервис, тогда **Unit=** имеет смысл.  
В 99% случаев лучше просто назвать таймер так же, как сервис (check_log.timer → check_log.service).  

#### Перезагружаем systemd, включаем и запускаем таймер
> root@Otus-debian:/scripts# systemctl daemon-reload

> root@Otus-debian:/scripts# systemctl enable check_log.timer
```
Created symlink /etc/systemd/system/timers.target.wants/check_log.timer → /etc/systemd/system/check_log.timer.
```
> root@Otus-debian:/scripts# systemctl start check_log.timer

#### Проверим статус сервиса, таймера, посмотрим лог
Посмотрим ствтус сервиса:
> root@Otus-debian:/scripts# systemctl status check_log.timer
```
● check_log.timer - Timer to run check_log service every 30 seconds
     Loaded: loaded (/etc/systemd/system/check_log.timer; enabled; preset: enabled)
     Active: active (waiting) since Tue 2025-02-18 17:41:57 MSK; 1min 35s ago
    Trigger: Tue 2025-02-18 17:44:02 MSK; 29s left
   Triggers: ● check_log.service

Feb 18 17:41:57 Otus-debian systemd[1]: Started check_log.timer - Timer to run check_log service every 30 seconds.
```
> root@Otus-debian:/scripts# systemctl status check_log.service
```
○ check_log.service - Log Monitoring Service
     Loaded: loaded (/etc/systemd/system/check_log.service; disabled; preset: enabled)
     Active: inactive (dead) since Tue 2025-02-18 17:43:32 MSK; 18s ago
TriggeredBy: ● check_log.timer
    Process: 3526 ExecStart=/scripts/check_log.sh $WORD $LOG (code=exited, status=0/SUCCESS)
   Main PID: 3526 (code=exited, status=0/SUCCESS)
        CPU: 5ms

Feb 18 17:43:32 Otus-debian systemd[1]: Starting check_log.service - Log Monitoring Service...
Feb 18 17:43:32 Otus-debian check_log.sh[3526]: 2025-02-18 17:43:32: Found word 'ALERT' in '/var/log/watchlog.log'
Feb 18 17:43:32 Otus-debian root[3529]: 2025-02-18 17:43:32: Found word 'ALERT' in '/var/log/watchlog.log'
Feb 18 17:43:32 Otus-debian systemd[1]: check_log.service: Deactivated successfully.
Feb 18 17:43:32 Otus-debian systemd[1]: Finished check_log.service - Log Monitoring Service.
```
Посмотрим статус таймера:
> root@Otus-debian:/scripts# systemctl list-timers --all
```
NEXT                        LEFT          LAST                        PASSED     UNIT                         ACTIVATES
Tue 2025-02-18 18:04:28 MSK 2s left       Tue 2025-02-18 18:03:58 MSK 27s ago    check_log.timer              check_log.service
```
Посмотрим лог сервиса:
> root@Otus-debian:/scripts# journalctl -u check_log.service -f
```
Feb 18 17:53:56 Otus-debian systemd[1]: check_log.service: Deactivated successfully.
Feb 18 17:53:56 Otus-debian systemd[1]: Finished check_log.service - Log Monitoring Service.
Feb 18 17:54:46 Otus-debian systemd[1]: Starting check_log.service - Log Monitoring Service...
Feb 18 17:54:46 Otus-debian check_log.sh[3666]: 2025-02-18 17:54:46: Found word 'ALERT' in '/var/log/watchlog.log'
Feb 18 17:54:46 Otus-debian systemd[1]: check_log.service: Deactivated successfully.
Feb 18 17:54:46 Otus-debian systemd[1]: Finished check_log.service - Log Monitoring Service.
Feb 18 17:55:56 Otus-debian systemd[1]: Starting check_log.service - Log Monitoring Service...
Feb 18 17:55:56 Otus-debian check_log.sh[3671]: 2025-02-18 17:55:56: Found word 'ALERT' in '/var/log/watchlog.log'
Feb 18 17:55:56 Otus-debian systemd[1]: check_log.service: Deactivated successfully.
Feb 18 17:55:56 Otus-debian systemd[1]: Finished check_log.service - Log Monitoring Service.
Feb 18 17:57:06 Otus-debian systemd[1]: Starting check_log.service - Log Monitoring Service...
Feb 18 17:57:06 Otus-debian check_log.sh[3676]: 2025-02-18 17:57:06: Found word 'ALERT' in '/var/log/watchlog.log'
Feb 18 17:57:06 Otus-debian systemd[1]: check_log.service: Deactivated successfully.
Feb 18 17:57:06 Otus-debian systemd[1]: Finished check_log.service - Log Monitoring Service.
```

## Установить spawn-fcgi и создать unit-файл (spawn-fcgi.sevice)
Устанавливаем **spawn-fcgi** и необходимые для него пакеты:
> root@Otus-debian:/scripts# apt install spawn-fcgi php php-cgi php-cli apache2 libapache2-mod-fcgid -y

Создаем файл с настройками для будущего сервиса в файле **/scripts/fcgi.conf**
> root@Otus-debian:/scripts# touch fcgi.conf
```bash
root@Otus-debian:/scripts# cat > /scripts/fcgi.conf <<EOF
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET="/var/run/php-fcgi.sock"
OPTIONS="-u www-data -g www-data -s \$SOCKET -S -M 0600 -C 32 -F 1 -f /usr/bin/php-cgi"
EOF
```
#### Создаем unit-файл для systemd
```bash
root@Otus-debian:/scripts# cat > /etc/systemd/system/spawn-fcgi.service <<EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/run/spawn-fcgi.pid
EnvironmentFile=/scripts/fcgi.conf
ExecStart=/usr/bin/spawn-fcgi -n \$OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
```

Запускаем сервис, проверяем работоспособность:
> root@Otus-debian:/scripts# systemctl daemon-reload

> root@Otus-debian:/scripts# systemctl start spawn-fcgi

> root@Otus-debian:/scripts# systemctl status spawn-fcgi
```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
     Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; preset: enabled)
     Active: active (running) since Wed 2025-02-19 10:42:32 MSK; 3s ago
   Main PID: 17779 (php-cgi)
      Tasks: 33 (limit: 1073)
     Memory: 15.8M
        CPU: 25ms
     CGroup: /system.slice/spawn-fcgi.service
             ├─17779 /usr/bin/php-cgi
             ├─17780 /usr/bin/php-cgi
             ├─17781 /usr/bin/php-cgi
             ├─17782 /usr/bin/php-cgi
             ├─17783 /usr/bin/php-cgi
             ├─17784 /usr/bin/php-cgi
             ├─17785 /usr/bin/php-cgi
             ├─17786 /usr/bin/php-cgi
             ├─17787 /usr/bin/php-cgi
             ├─17788 /usr/bin/php-cgi
             ├─17789 /usr/bin/php-cgi
             ├─17790 /usr/bin/php-cgi
             ├─17791 /usr/bin/php-cgi
             ├─17792 /usr/bin/php-cgi
             ├─17793 /usr/bin/php-cgi
             ├─17794 /usr/bin/php-cgi
             ├─17795 /usr/bin/php-cgi
             ├─17796 /usr/bin/php-cgi
             ├─17797 /usr/bin/php-cgi
             ├─17798 /usr/bin/php-cgi
             ├─17799 /usr/bin/php-cgi
             ├─17800 /usr/bin/php-cgi
             ├─17801 /usr/bin/php-cgi
             ├─17802 /usr/bin/php-cgi
             ├─17803 /usr/bin/php-cgi
             ├─17804 /usr/bin/php-cgi
             ├─17805 /usr/bin/php-cgi
             ├─17806 /usr/bin/php-cgi
             ├─17807 /usr/bin/php-cgi
             ├─17808 /usr/bin/php-cgi
             ├─17809 /usr/bin/php-cgi
             ├─17810 /usr/bin/php-cgi
             └─17811 /usr/bin/php-cgi

Feb 19 10:42:32 Otus-debian systemd[1]: Started spawn-fcgi.service - Spawn-fcgi startup service by Otus.
```

## Доработать unit-файл Nginx (nginx.service) для запуска нескольких инстансов сервера с разными конфигурационными файлами одновременно

Установим **Nginx**:
> root@Otus-debian:/scripts# apt install nginx -y

#### Cоздадим новый Unit для работы с шаблонами 
```bash
root@Otus-debian:/etc/nginx# cat > /etc/systemd/system/nginx@.service <<EOF
# Stop dance for nginx
# =======================
#
# ExecStop sends SIGSTOP (graceful stop) to the nginx process.
# If, after 5s (--retry QUIT/5) nginx is still running, systemd takes control
# and sends SIGTERM (fast shutdown) to the main process.
# After another 5s (TimeoutStopSec=5), and if nginx is alive, systemd sends
# SIGKILL to all the remaining processes in the process group (KillMode=mixed).
#
# nginx signals reference doc:
# http://nginx.org/en/docs/control.html
#
[Unit]
Description=A high performance web server and a reverse proxy server
Documentation=man:nginx(8)
After=network.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx-%I.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%I.conf -q -g 'daemon on; master_process on;'
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;'
ExecReload=/usr/sbin/nginx -c /etc/nginx/nginx-%I.conf -g 'daemon on; master_process on;' -s reload
ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx-%I.pid
TimeoutStopSec=5
KillMode=mixed

[Install]
WantedBy=multi-user.target
EOF
```
#### Создадим два файла конфигурации (/etc/nginx/nginx-first.conf, /etc/nginx/nginx-second.conf)

Первый файл конфигурации Nginx - **nginx-first.conf**:
> root@Otus-debian:/etc/nginx# cat nginx-first.conf
```
user www-data;
worker_processes auto;
pid /run/nginx-first.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;

        gzip on;

        server {
                listen 9999 default_server;

                root /var/www/htmlf;

                index index.html index.htm index.nginx-debian.html;

                server_name _;

                location / {
                        try_files $uri $uri/ =404;
                }
        }
}
```
Второй файл конфигурации Nginx - **nginx-second.conf**:
> root@Otus-debian:/etc/nginx# cat nginx-second.conf
```
user www-data;
worker_processes auto;
pid /run/nginx-second.pid;
error_log /var/log/nginx/error.log;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}

http {
        sendfile on;
        tcp_nopush on;
        types_hash_max_size 2048;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;

        access_log /var/log/nginx/access.log;

        gzip on;

        server {
                listen 9998 default_server;

                root /var/www/htmls;

                index index.html index.htm index.nginx-debian.html;

                server_name _;

                location / {
                        try_files $uri $uri/ =404;
                }
        }
}
```
В директорию **/var/www/htmlf** помещаем файл **index.html** следующего содержания:
```html
<!DOCTYPE html>
<html>
<head>
<title>nginx-first</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx first</h1>
</body>
</html>
```

В директорию **/var/www/htmls** помещаем файл **index.html** следующего содержания:
```html
<!DOCTYPE html>
<html>
<head>
<title>nginx-second</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx second</h1>
</body>
</html>
```

#### Проверим работу сервисов Nginx
> root@Otus-debian:/etc/nginx# systemctl daemon-reload

Первый сервис **Nginx**:
> root@Otus-debian:/etc/nginx# systemctl start nginx@first

> root@Otus-debian:/etc/nginx# systemctl status nginx@first
```
● nginx@first.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; preset: enabled)
     Active: active (running) since Wed 2025-02-19 11:27:13 MSK; 4s ago
       Docs: man:nginx(8)
    Process: 18795 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-first.conf -q -g daemon on; master_process on; (code=exited, status=0>
    Process: 18796 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 18797 (nginx)
      Tasks: 3 (limit: 1073)
     Memory: 2.4M
        CPU: 10ms
     CGroup: /system.slice/system-nginx.slice/nginx@first.service
             ├─18797 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;"
             ├─18798 "nginx: worker process"
             └─18799 "nginx: worker process"

Feb 19 11:27:13 Otus-debian systemd[1]: Starting nginx@first.service - A high performance web server and a reverse proxy server...
Feb 19 11:27:13 Otus-debian systemd[1]: Started nginx@first.service - A high performance web server and a reverse proxy server.
```
Второй сервис **Nginx**:
> root@Otus-debian:/etc/nginx# systemctl start nginx@second

> root@Otus-debian:/etc/nginx# systemctl status nginx@second
```
● nginx@second.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/etc/systemd/system/nginx@.service; disabled; preset: enabled)
     Active: active (running) since Wed 2025-02-19 11:27:49 MSK; 6s ago
       Docs: man:nginx(8)
    Process: 18804 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-second.conf -q -g daemon on; master_process on; (code=exited, status=>
    Process: 18805 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 18806 (nginx)
      Tasks: 3 (limit: 1073)
     Memory: 2.3M
        CPU: 10ms
     CGroup: /system.slice/system-nginx.slice/nginx@second.service
             ├─18806 "nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-second.conf -g daemon on; master_process on;"
             ├─18807 "nginx: worker process"
             └─18808 "nginx: worker process"

Feb 19 11:27:49 Otus-debian systemd[1]: Starting nginx@second.service - A high performance web server and a reverse proxy server...
Feb 19 11:27:49 Otus-debian systemd[1]: Started nginx@second.service - A high performance web server and a reverse proxy server.
```

Посмотрим какие порты слушаются в системе:
> root@Otus-debian:/etc/nginx# ss -tnulp | grep nginx
```
tcp   LISTEN 0      511                              0.0.0.0:9998       0.0.0.0:*    users:(("nginx",pid=18808,fd=5),("nginx",pid=18807,fd=5),("nginx",pid=18806,fd=5))
tcp   LISTEN 0      511                              0.0.0.0:9999       0.0.0.0:*    users:(("nginx",pid=18799,fd=5),("nginx",pid=18798,fd=5),("nginx",pid=18797,fd=5))
```

Так же можно обратиться через браузер или **curl**:
> root@Otus-debian:/etc/nginx# curl 10.126.112.216:9999
```
<!DOCTYPE html>
<html>
<head>
<title>nginx-first</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx first</h1>
</body>
</html>
```
> root@Otus-debian:/etc/nginx# curl 10.126.112.216:9998
```
<!DOCTYPE html>
<html>
<head>
<title>nginx-second</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
    <h1>Welcome to nginx second</h1>
</body>
</html>
```
![result](img/nginx01.png) -->