# Qwen Gate - Railway Deployment

Skrip deployment otomatis untuk menjalankan [qwen-gate](https://github.com/youssefvdel/qwen-gate) di [Railway](https://railway.app). Qwen Gate adalah gateway API yang kompatibel dengan OpenAI (drop-in replacement untuk `/v1/chat/completions`), yang memungkinkan kamu menggunakan akun Qwen (chat.qwen.ai) sebagai penyedia AI API gratis di client mana pun yang mendukung format OpenAI — seperti Cursor, Continue.dev, Claude Code, VS Code Copilot, atau coding agent lainnya.

## Fitur qwen-gate

- Endpoint API yang kompatibel dengan OpenAI
- Dukungan streaming (SSE)
- Tool calling
- Dashboard web bawaan
- Self-hosted, tidak perlu API key berbayar

## Isi Repo Ini

| File | Fungsi |
|---|---|
| `start.sh` | Skrip runtime: install dependency, clone `qwen-gate`, install package, patch konfigurasi host/port, lalu menjalankan aplikasi |
| `railway.toml` | Konfigurasi build & deploy untuk Railway |

## Cara Kerja

### 1. Build Phase (`railway.toml`)
Saat proses build, Railway akan:
1. Meng-update package list dan install `curl`, `git`, `unzip`
2. Menginstal [Bun](https://bun.sh) sebagai runtime JavaScript
3. Meng-clone repository `qwen-gate` ke `/app/qwen-gate`
4. Menjalankan `bun install` untuk memasang dependency

### 2. Deploy Phase (`start.sh`)
Saat container dijalankan, `start.sh` akan:
1. Mengulangi instalasi dependency & clone repo (memastikan environment runtime konsisten dengan build)
2. Menghapus folder lama `/app/qwen-gate` (jika ada) sebelum clone ulang
3. Membaca `config.json` milik qwen-gate, membuang komentar (`//` dan `/* */`) agar valid sebagai JSON
4. Menimpa nilai `HOST` menjadi `0.0.0.0` dan `PORT` sesuai variabel environment `$PORT` dari Railway (fallback ke `8080` jika tidak diset)
5. Menjalankan aplikasi dengan `bun start`

### 3. Health Check
Railway akan memeriksa endpoint `/dashboard` untuk memastikan aplikasi sudah berjalan, dengan timeout 30 detik.

## Cara Deploy ke Railway

1. Push kedua file ini (`start.sh` dan `railway.toml`) ke repository GitHub kamu.
2. Buat project baru di [Railway](https://railway.app) dan hubungkan ke repo tersebut.
3. Railway akan otomatis mendeteksi `railway.toml` dan menjalankan proses build + deploy.
4. Setelah deploy sukses, buka URL yang diberikan Railway, lalu akses `/dashboard` untuk mengatur akun Qwen dan melihat status gateway.

Tidak perlu mengatur variabel `PORT` secara manual — Railway akan menyuntikkannya secara otomatis dan skrip `start.sh` akan membacanya.

## Environment Variable

| Variabel | Wajib | Keterangan |
|---|---|---|
| `PORT` | Tidak | Otomatis diset oleh Railway. Jika tidak ada, default ke `8080` |

Variabel environment tambahan (misalnya kredensial akun Qwen) mengikuti konfigurasi asli dari [qwen-gate](https://github.com/youssefvdel/qwen-gate) — cek dokumentasi resminya untuk detail lebih lanjut.

## Catatan

- Skrip ini melakukan **fresh clone** setiap kali dijalankan (folder lama dihapus), sehingga tidak ada perubahan lokal pada source `qwen-gate` yang akan bertahan antar-deploy.
- Pastikan repository `qwen-gate` yang di-clone memiliki file `config.json` di root project, karena skrip bergantung pada file tersebut untuk mengatur host dan port.

## Lisensi

Skrip deployment ini mengikuti lisensi dari project [qwen-gate](https://github.com/youssefvdel/qwen-gate). Silakan cek repository aslinya untuk detail lisensi.
