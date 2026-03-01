RIL MONITOR MANAGER v1.1
Repository: https://github.com/InetByOu/RIL-monitor.git

RIL Monitor Manager adalah script Bash untuk Android (rooted) yang berfungsi memonitor koneksi internet secara berkala dan otomatis me-restart service `ril-daemon` jika terjadi kegagalan koneksi berulang. Sistem dilengkapi pembatasan restart per jam untuk mencegah infinite restart loop.

============================================================
REQUIREMENTS
============================================================
- Android dengan akses ROOT
- sudo atau akses administratif
- su berfungsi normal
- curl terinstall
- Bash shell (disarankan via Termux)
- Sistem mendukung perintah: restart ril-daemon

============================================================
INSTALLATION & CARA MENJALANKAN
============================================================
1. Clone repository:
   git clone https://github.com/InetByOu/RIL-monitor.git
   cd RIL-monitor

2. Berikan izin eksekusi:
   chmod +x rilmon.sh

3. Jalankan (WAJIB menggunakan sudo):
   sudo ./rilmon.sh

============================================================
MENU UTAMA
============================================================
[1] Start Monitoring (Foreground)
[2] Start Monitoring (Background)
[3] Stop Background Monitoring
[4] Status
[5] Edit Configuration
[6] View Log
[7] Test Connection Now
[8] Exit

============================================================
CARA KERJA
============================================================
- Script mengecek koneksi menggunakan:
  curl -I --connect-timeout TIMEOUT -m TIMEOUT TARGET_URL

- Jika gagal berturut-turut sebanyak MAX_FAIL:
  → Menjalankan: su -c "restart ril-daemon"
  → Menunggu COOLDOWN detik
  → Reset fail counter

- Restart dibatasi oleh MAX_RESTART_PER_HOUR
- Counter restart otomatis reset setiap 3600 detik (1 jam)

============================================================
MODE OPERASI
============================================================
Foreground:
- Monitoring tampil langsung di terminal
- Berhenti dengan Ctrl + C

Background:
- Monitoring berjalan di belakang layar
- PID disimpan di .ril_monitor.pid
- Log tersimpan di logs/monitor.log

============================================================
KONFIGURASI DEFAULT
============================================================
TARGET_URL="https://www.bing.com"
TIMEOUT=5
INTERVAL=10
MAX_FAIL=3
COOLDOWN=20
MAX_RESTART_PER_HOUR=5

============================================================
KONFIGURASI DISARANKAN (BALANCED)
============================================================
TARGET_URL="https://1.1.1.1"
TIMEOUT=5
INTERVAL=15
MAX_FAIL=3
COOLDOWN=30
MAX_RESTART_PER_HOUR=4

============================================================
LOGGING
============================================================
Lokasi: logs/monitor.log
Format: [YYYY-MM-DD HH:MM:SS] Pesan

Lihat realtime:
tail -f logs/monitor.log

============================================================
STOP & CLEANUP
============================================================
Hentikan monitoring background melalui menu.
Hapus semua file:
rm rilmon.sh
rm ril_config.conf
rm -rf logs
rm .ril_monitor.pid

============================================================
EKSEKUSI WAJIB
============================================================
sudo ./rilmon.sh

Version : 1.1
License : MIT
Platform: Rooted Android
============================================================
