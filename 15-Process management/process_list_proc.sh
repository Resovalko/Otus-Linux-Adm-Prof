#!/bin/bash

# Функция для получения времени работы системы (аптайма) в секундах
get_uptime() {
    awk '{print $1}' /proc/uptime
}

# Функция для получения количества тактов процессора в секунду (HZ)
get_clock_ticks() {
    getconf CLK_TCK
}

# Функция для форматирования времени в формате HH:MM:SS
format_duration() {
    local total_seconds=$1
    local hours=$((total_seconds / 3600))                      # Часы
    local minutes=$(((total_seconds % 3600) / 60))            # Минуты
    local seconds=$((total_seconds % 60))                     # Секунды
    printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds"  # Форматированный вывод
}

# Функция для форматирования TIME+ в формате MM:SS.hh (как в top)
format_time_plus() {
    local total_ticks=$1
    local clk_tck=$2

    local total_seconds=$((total_ticks / clk_tck))             # Целые секунды
    local hundredths=$(((total_ticks % clk_tck) * 100 / clk_tck)) # Сотые доли секунды

    local minutes=$((total_seconds / 60))                     # Минуты
    local seconds=$((total_seconds % 60))                     # Секунды

    printf "%02d:%02d.%02d" "$minutes" "$seconds" "$hundredths"  # Формат MM:SS.hh
}

# Функция для получения использования памяти процесса (VmRSS) в килобайтах
get_memory_usage() {
    local pid=$1
    if [[ -r "/proc/$pid/status" ]]; then
        awk '/VmRSS/ {printf "%s KB", $2}' "/proc/$pid/status"  # Извлечение VmRSS
    else
        echo "-"  # Если нет доступа, вывод прочерка
    fi
}

# Функция для получения имени пользователя, которому принадлежит процесс
get_user() {
    local pid=$1
    if [[ -r "/proc/$pid/status" ]]; then
        local uid=$(awk '/Uid:/ {print $2}' "/proc/$pid/status")  # UID процесса
        getent passwd "$uid" | cut -d: -f1 || echo "-"            # Преобразование UID в имя
    else
        echo "-"
    fi
}

# Функция для получения и вывода информации о процессе
get_process_info() {
    local pid=$1

    # Проверка на доступность файла stat процесса
    [[ ! -r "/proc/$pid/stat" ]] && return

    # Чтение содержимого /proc/[pid]/stat в массив
    local stat_fields
    stat_fields=($(<"/proc/$pid/stat"))

    # Извлечение полей из stat
    local comm="${stat_fields[1]}"       # Имя процесса
    local state="${stat_fields[2]}"      # Состояние процесса
    local ppid="${stat_fields[3]}"       # PPID
    local utime="${stat_fields[13]}"     # Пользовательское время (в тиках)
    local stime="${stat_fields[14]}"     # Системное время (в тиках)
    local starttime="${stat_fields[21]}" # Время запуска (в тиках)

    # Получение командной строки или имени процесса
    local cmdline="-"
    if [[ -r "/proc/$pid/cmdline" ]]; then
        cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" | sed 's/ *$//')
        [[ -z "$cmdline" ]] && cmdline="[$comm]"
    fi

    local uptime=$(get_uptime)           # Аптайм системы
    local clk_tck=$(get_clock_ticks)     # Тики в секунду

    # Расчёт времени работы процесса (в секундах)
    local seconds_running=$(awk -v up="$uptime" -v st="$starttime" -v hz="$clk_tck" 'BEGIN {
        diff = up - (st / hz); 
        print (diff > 0) ? int(diff) : 0; 
    }')

    local runtime=$(format_duration "$seconds_running")   # RUNTIME: сколько работает процесс

    # Расчёт TIME+ (utime + stime в формате MM:SS.hh)
    local total_time_ticks=$((utime + stime))
    local time_plus=$(format_time_plus "$total_time_ticks" "$clk_tck")

    # Расчёт CPU%: (время выполнения / время работы процесса) * 100
    local cpu_usage=$(awk -v tt="$total_time_ticks" -v hz="$clk_tck" -v run="$seconds_running" 'BEGIN {
        printf "%.1f", (run > 0) ? ((tt / hz) / run * 100) : 0
    }')

    local mem_usage=$(get_memory_usage "$pid")  # Память
    local user=$(get_user "$pid")              # Пользователь

    # Вывод информации в таблицу
    printf "%6s %10s %6s %5s %6s %10s %9s %10s %s\n" \
        "$pid" "$user" "$ppid" "$state" "$cpu_usage" "$runtime" "$time_plus" "$mem_usage" "$cmdline"
}

# Главная функция: заголовки и вывод процессов
main() {
    # Заголовок таблицы с новым столбцом TIME+
    printf "%6s %10s %6s %5s %6s %10s %9s %10s %s\n" \
        "PID" "USER" "PPID" "STATE" "CPU%" "RUNTIME" "TIME+" "MEM" "COMMAND"

    # Поиск процессов и вывод информации
    for pid in $(find /proc -maxdepth 1 -type d -regex "/proc/[0-9]+" | sort -n -t/ -k3); do
        get_process_info "${pid##*/}"
    done
}

# Запуск
main
