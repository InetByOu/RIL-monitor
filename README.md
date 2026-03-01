# RIL MONITOR MANAGER v1.1

**Repository:** https://github.com/InetByOu/RIL-monitor.git  
**Platform:** Rooted Android  
**License:** MIT  

---

## 📌 Overview

**RIL Monitor Manager** adalah script Bash untuk Android (root) yang berfungsi untuk:

- Memonitor koneksi internet secara berkala
- Mendeteksi kegagalan koneksi berulang
- Otomatis me-restart service `ril-daemon`
- Mencegah infinite restart loop dengan sistem pembatasan restart per jam

Script ini dirancang ringan, stabil, dan cocok digunakan pada perangkat Android yang sering mengalami drop koneksi seluler.

---

## ⚙️ Requirements

- Android dengan akses **ROOT**
- `su` berfungsi normal
- `sudo` atau akses administratif
- `curl` terinstall
- Bash shell (disarankan via Termux)
- Sistem mendukung perintah:

```
restart ril-daemon
```

---

## 🚀 Installation & Usage

### 1️⃣ Clone Repository

```bash
git clone https://github.com/InetByOu/RIL-monitor.git
cd RIL-monitor
```

### 2️⃣ Berikan Izin Eksekusi

```bash
chmod +x rilmon.sh
```

### 3️⃣ Jalankan (WAJIB menggunakan sudo)

```bash
sudo ./rilmon.sh
```

---

## 🖥 Main Menu

```
[1] Start Monitoring (Foreground)
[2] Start Monitoring (Background)
[3] Stop Background Monitoring
[4] Status
[5] Edit Configuration
[6] View Log
[7] Test Connection Now
[8] Exit
```

---

## 🔎 Cara Kerja

Script mengecek koneksi menggunakan:

```bash
curl -I --connect-timeout TIMEOUT -m TIMEOUT TARGET_URL
```

Jika gagal berturut-turut sebanyak `MAX_FAIL`:

1. Menjalankan:
   ```bash
   su -c "restart ril-daemon"
   ```
2. Menunggu `COOLDOWN` detik
3. Reset fail counter

### 🔒 Proteksi Restart

- Restart dibatasi oleh `MAX_RESTART_PER_HOUR`
- Counter restart otomatis reset setiap 3600 detik (1 jam)

---

## 🧩 Mode Operasi

### 🔹 Foreground Mode
- Monitoring tampil langsung di terminal
- Berhenti dengan `Ctrl + C`

### 🔹 Background Mode
- Monitoring berjalan di belakang layar
- PID disimpan di:
  ```
  .ril_monitor.pid
  ```
- Log tersimpan di:
  ```
  logs/monitor.log
  ```

---

## 🛠 Default Configuration

```bash
TARGET_URL="https://www.bing.com"
TIMEOUT=5
INTERVAL=10
MAX_FAIL=3
COOLDOWN=20
MAX_RESTART_PER_HOUR=5
```

---

## ⚖ Recommended Configuration (Balanced)

```bash
TARGET_URL="https://1.1.1.1"
TIMEOUT=5
INTERVAL=15
MAX_FAIL=3
COOLDOWN=30
MAX_RESTART_PER_HOUR=0
```

---

## 📜 Logging

**Lokasi:**

```
logs/monitor.log
```

**Format:**

```
[YYYY-MM-DD HH:MM:SS] Pesan
```

Lihat realtime:

```bash
tail -f logs/monitor.log
```

---

## 🧹 Stop & Cleanup

Hentikan monitoring background melalui menu.

Hapus semua file:

```bash
rm rilmon.sh
rm ril_config.conf
rm -rf logs
rm .ril_monitor.pid
```

---

## ⚠️ Eksekusi Wajib

```bash
sudo ./rilmon.sh
```

---

## 🧠 Notes

- Pastikan perangkat benar-benar rooted.
- Gunakan dengan bijak untuk menghindari restart jaringan berlebihan.
- Direkomendasikan untuk perangkat yang sering mengalami drop sinyal atau stuck data.

---

**Version:** 1.1  
**Maintainer:** InetByOu
