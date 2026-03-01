#!/data/data/com.termux/files/usr/bin/bash

# ===============================
# RIL MONITOR MANAGER v1.1
# Foreground + Background Mode
# Android ROOT Required
# ===============================

CONFIG_FILE="ril_config.conf"
PID_FILE=".ril_monitor.pid"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/monitor.log"

mkdir -p "$LOG_DIR"

# ---------- DEFAULT CONFIG ----------
init_config() {
cat > "$CONFIG_FILE" <<EOF
TARGET_URL="https://www.bing.com"
TIMEOUT=5
INTERVAL=10
MAX_FAIL=3
COOLDOWN=20
MAX_RESTART_PER_HOUR=5
EOF
}

# ---------- LOAD CONFIG ----------
load_config() {
    source "$CONFIG_FILE"
}

# ---------- ROOT CHECK ----------
check_root() {
    if ! su -c "id" >/dev/null 2>&1; then
        echo "Root access required!"
        exit 1
    fi
}

# ---------- CONNECTION CHECK ----------
check_connection() {
    curl -I --connect-timeout $TIMEOUT -m $TIMEOUT $TARGET_URL > /dev/null 2>&1
    return $?
}

# ---------- RESTART RIL ----------
restart_ril() {
    log "[!] Restarting RIL..."
    su -c "restart ril-daemon" >> "$LOG_FILE" 2>&1
}

# ---------- LOGGER ----------
log() {
    msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg" >> "$LOG_FILE"

    if [ "$MODE" = "FOREGROUND" ]; then
        echo "$msg"
    fi
}

# ---------- MONITOR LOOP ----------
monitor_loop() {

    load_config
    fail_count=0
    restart_count=0
    hour_start=$(date +%s)

    log "Monitoring started (Mode: $MODE)"

    while true; do

        current_time=$(date +%s)
        elapsed=$((current_time - hour_start))

        # Reset hourly restart counter
        if [ $elapsed -ge 3600 ]; then
            restart_count=0
            hour_start=$current_time
            log "Restart counter reset."
        fi

        check_connection

        if [ $? -eq 0 ]; then
            log "[OK] Internet Active"
            fail_count=0
        else
            fail_count=$((fail_count+1))
            log "[FAIL] Count: $fail_count"

            if [ $fail_count -ge $MAX_FAIL ]; then

                if [ $restart_count -ge $MAX_RESTART_PER_HOUR ]; then
                    log "Max restart per hour reached. Skipping restart."
                else
                    restart_ril
                    restart_count=$((restart_count+1))
                fi

                log "Cooldown $COOLDOWN seconds..."
                sleep $COOLDOWN
                fail_count=0
            fi
        fi

        sleep $INTERVAL
    done
}

# ---------- START FOREGROUND ----------
start_foreground() {

    if [ -f "$PID_FILE" ]; then
        echo "Monitoring already running in background!"
        return
    fi

    MODE="FOREGROUND"
    monitor_loop
}

# ---------- START BACKGROUND ----------
start_background() {

    if [ -f "$PID_FILE" ]; then
        echo "Monitoring already running!"
        return
    fi

    MODE="BACKGROUND"
    monitor_loop &
    echo $! > "$PID_FILE"

    echo "Monitoring started in background."
}

# ---------- STOP ----------
stop_monitor() {

    if [ ! -f "$PID_FILE" ]; then
        echo "No background monitoring found."
        return
    fi

    kill $(cat "$PID_FILE") 2>/dev/null
    rm -f "$PID_FILE"
    echo "Background monitoring stopped."
}

# ---------- STATUS ----------
status_monitor() {

    if [ -f "$PID_FILE" ]; then
        echo "Status: RUNNING (Background)"
        echo "PID: $(cat $PID_FILE)"
    else
        echo "Status: Not running (Background)"
    fi
}

# ---------- TEST NOW ----------
test_connection_now() {
    load_config
    check_connection

    if [ $? -eq 0 ]; then
        echo "[OK] Internet Active"
    else
        echo "[FAIL] No Connection"
    fi
}

# ---------- EDIT CONFIG ----------
edit_config() {

    load_config

    read -p "Target URL [$TARGET_URL]: " input
    [ ! -z "$input" ] && TARGET_URL="$input"

    read -p "Timeout [$TIMEOUT]: " input
    [ ! -z "$input" ] && TIMEOUT="$input"

    read -p "Interval [$INTERVAL]: " input
    [ ! -z "$input" ] && INTERVAL="$input"

    read -p "Max Fail [$MAX_FAIL]: " input
    [ ! -z "$input" ] && MAX_FAIL="$input"

    read -p "Cooldown [$COOLDOWN]: " input
    [ ! -z "$input" ] && COOLDOWN="$input"

    read -p "Max Restart/Hour [$MAX_RESTART_PER_HOUR]: " input
    [ ! -z "$input" ] && MAX_RESTART_PER_HOUR="$input"

cat > "$CONFIG_FILE" <<EOF
TARGET_URL="$TARGET_URL"
TIMEOUT=$TIMEOUT
INTERVAL=$INTERVAL
MAX_FAIL=$MAX_FAIL
COOLDOWN=$COOLDOWN
MAX_RESTART_PER_HOUR=$MAX_RESTART_PER_HOUR
EOF

    echo "Configuration updated."
}

# ---------- VIEW LOG ----------
view_log() {
    tail -f "$LOG_FILE"
}

# ---------- MENU ----------
menu() {

    [ ! -f "$CONFIG_FILE" ] && init_config
    check_root

    while true; do
        clear
        echo "=============================="
        echo "   RIL MONITOR MANAGER v1.1"
        echo "=============================="
        echo ""
        echo "[1] Start Monitoring (Foreground)"
        echo "[2] Start Monitoring (Background)"
        echo "[3] Stop Background Monitoring"
        echo "[4] Status"
        echo "[5] Edit Configuration"
        echo "[6] View Log"
        echo "[7] Test Connection Now"
        echo "[8] Exit"
        echo ""
        read -p "Select option: " opt

        case $opt in
            1) start_foreground ;;
            2) start_background ;;
            3) stop_monitor ;;
            4) status_monitor ;;
            5) edit_config ;;
            6) view_log ;;
            7) test_connection_now ;;
            8) exit 0 ;;
            *) echo "Invalid option" ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

menu