# Kelasku – Panduan Pasang (±15 menit, gratis)

Kelasku adalah aplikasi web yang bisa dipasang ke layar utama HP (PWA) di Android dan iPhone, tanpa Play Store / App Store.

## 1. Buat backend (Supabase)
1. Daftar di https://supabase.com lalu klik **New project**.
2. Buka **SQL Editor** > tempel seluruh isi `schema.sql` > **Run**.
3. Buka **Authentication > Providers > Email**, matikan **Confirm email** (agar anggota bisa langsung masuk).
4. Buka **Project Settings > API**, salin **Project URL** dan **anon public key**.
5. Buka `config.js`, isi `url` dan `key` dengan nilai tadi.

## 2. Taruh di internet (HTTPS wajib untuk kamera & notifikasi)
Pilih salah satu, semuanya gratis:
- **Netlify Drop**: buka https://app.netlify.com/drop lalu seret seluruh folder ini.
- **Cloudflare Pages / GitHub Pages / Vercel**: unggah folder ini sebagai situs statis.

Kamu akan mendapat tautan, misalnya `https://kelasku.netlify.app`.

## 3. Pakai
1. Ketua kelas: buka tautan > **Daftar** > **Buat kelas**. Kode undangan ada di tab Profil.
2. Anggota: buka tautan > **Daftar** > masukkan kode > **Gabung kelas**.
3. Pasang ke layar utama:
   - Android (Chrome): menu ⋮ > **Instal aplikasi**.
   - iPhone (Safari): tombol Bagikan > **Tambah ke Layar Utama**.
4. Absensi: anggota buka tab QR dan tunjukkan kodenya. Ketua buka tab QR > **Scan kamera**.

## Batasan
- Pengingat notifikasi berjalan saat aplikasi masih terbuka/di latar belakang. Push saat aplikasi benar-benar tertutup butuh Supabase Edge Function + Web Push (VAPID); bisa ditambahkan nanti.
- Foto/video disimpan di bucket publik dengan nama acak. Jangan unggah konten sensitif.
- Paket gratis Supabase: 1 GB penyimpanan, 500 MB database. Cukup untuk banyak kelas.
- Satu akun hanya bisa tergabung di satu kelas pada versi ini.
