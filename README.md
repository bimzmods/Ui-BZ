# BZ Menu UI v2.2

Modul menu UI untuk Roblox (Lua) buatan **Studio The Clown**, bertema ungu. Dipakai lewat `loadstring` dan dikontrol dari script kamu sendiri.

## Fitur

- Logo kecil yang bisa digeser; ketuk untuk membuka menu
- Menu bisa digeser (tarik header) dan diubah ukurannya (pegangan di pojok kanan bawah)
- Posisi dan ukuran terakhir menu diingat selama sesi
- Kategori/tab dengan animasi geser
- Elemen: Section, Toggle, Slider (angka bulat dan desimal), Select Menu, Tap Button, dan Note (teks)
- Kategori **UI** bawaan: Logo Size, Logo Transparan, Thema, Save Config
- 7 tema: Cyan, Kuning, Merah, Ungu (default), Sakura, White, Black
- Save Config per game ke folder `BZ Menu`
- Kategori **Dev Tools** khusus username `BimzDnu`

## Cara pakai

### 1. Muat modul

```lua
local BZ = loadstring(game:HttpGet("URL_FILE_LUA_KAMU"))()
```

Ganti `URL_FILE_LUA_KAMU` dengan link raw ke file `BZ_Menu_UI_v2.2.lua` yang kamu upload (misalnya GitHub raw). Setelah termuat, log console menampilkan `[BZ] Menu UI v2.2 module ready.`

### 2. Contoh lengkap

```lua
local BZ = loadstring(game:HttpGet("URL_FILE_LUA_KAMU"))()
local lp = game.Players.LocalPlayer

-- Kategori pertama
BZ:AddCategory("move", "Movement")

BZ:AddSection("Speed")
BZ:AddSlider("speed", "Speed", 16, 200, 16, function(v)
    local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = v end
end, 1)

BZ:AddSlider("gravity", "Gravity", 0, 1, 0.5, function(v)
    print("gravity", v)
end) -- step otomatis 0.01 karena ada desimal

BZ:AddToggle("infjump", "Infinite Jump", false, function(on)
    print("infinite jump", on)
end)

-- Kategori kedua
BZ:AddCategory("esp", "ESP")
BZ:AddToggle("box", "Box ESP", false, function(on) end)

BZ:AddSelectMenu("target", "Target", {"Head", "Torso", "Random"}, "Head", function(v)
    print("target", v)
end)

BZ:AddNote("Catatan: fitur ESP hanya tampilan.")

BZ:AddTapToggleOneClick("rejoin", "Rejoin Server", function()
    print("sekali tap = sekali jalan")
end)

BZ:Open()
```

## Referensi API

### Buka / tutup

| Fungsi | Keterangan |
|---|---|
| `BZ:Open()` | Buka menu (di posisi dan ukuran terakhir) |
| `BZ:Close()` | Tutup menu |
| `BZ:Toggle()` | Buka jika tertutup, tutup jika terbuka |
| `BZ:IsOpen()` | `true` jika menu sedang terbuka |
| `BZ:Destroy()` | Hapus seluruh UI |

### Kategori

| Fungsi | Keterangan |
|---|---|
| `BZ:AddCategory(name, label)` | Buat tab baru. Item yang ditambah setelahnya masuk ke tab ini |
| `BZ:UseCategory(name)` | Arahkan item berikutnya ke tab yang sudah ada |
| `BZ:SelectCategory(name)` | Buka tab lewat kode |

Item yang ditambah sebelum ada kategori masuk ke tab **Main**. Tab **UI** (dan **Dev Tools** untuk `BimzDnu`) selalu berada di urutan paling akhir.

### Elemen

| Fungsi | Keterangan |
|---|---|
| `BZ:AddSection(text)` | Judul pemisah |
| `BZ:AddToggle(name, label, default, callback)` | Saklar on/off; `callback(on)` |
| `BZ:AddSlider(name, label, min, max, default, callback, step)` | Slider angka; `callback(value)`. Kotak angka di kanan bisa diketik langsung |
| `BZ:AddSelectMenu(name, label, {opsi}, default, callback)` | Klik teks pilihan, muncul menu kecil (bisa di-scroll); `callback(pilihan)` |
| `BZ:AddTapToggleOneClick(name, label, callback)` | Tombol dengan ikon tap; tiap tap memanggil `callback()` satu kali |
| `BZ:AddNote(text, name)` | Teks catatan; mengembalikan handle dengan `handle:SetText("baru")` |
| `BZ:RemoveItem(name)` | Hapus item berdasarkan nama |

**Slider:** jika `step` tidak diisi, step otomatis `1` kalau semua angka bulat, atau `0.01` kalau ada desimal. Jumlah desimal yang tampil mengikuti step.

### Baca / ubah nilai dari script

| Fungsi | Keterangan |
|---|---|
| `BZ:GetToggle(name)` / `BZ:SetToggle(name, value, silent)` | `silent = true` tidak memanggil callback |
| `BZ:GetSlider(name)` / `BZ:SetSlider(name, value, silent)` | Sama seperti di atas |
| `BZ:GetSelect(name)` / `BZ:SetSelect(name, value, silent)` | Sama seperti di atas |

### Teks menu (diubah lewat script)

| Fungsi | Default |
|---|---|
| `BZ:SetTitle("...")` | `BZ Menu` |
| `BZ:SetLogoText("...")` | `BZ` |
| `BZ:SetStudio("...", showVersion)` | `Studio The Clown` (tampil dengan awalan versi; isi `false` untuk menyembunyikannya) |
| `BZ:SetTexts({Title=..., Logo=..., Studio=..., ShowVersion=...})` | Ubah beberapa sekaligus |
| `BZ:ResetTexts()` | Kembalikan semuanya ke default |

Memanggil dengan `nil` atau teks kosong mengembalikan ke default. Teks ini tidak disimpan di config.

### Tema dan config

| Fungsi | Keterangan |
|---|---|
| `BZ:SetTheme(name)` | `"Cyan"`, `"Kuning"`, `"Merah"`, `"Ungu"`, `"Sakura"`, `"White"`, `"Black"` |
| `BZ:SaveConfig()` | Simpan config; mengembalikan `true` atau `false, pesan` |
| `BZ:LoadConfig()` | Baca ulang file config dan terapkan ke item yang sudah ada |

## Kategori UI bawaan

- **Logo Size**: slider ukuran logo (36 sampai 96)
- **Logo Transparan (%)**: slider 0 sampai 90
- **Thema**: pilih salah satu dari 7 tema; warna seluruh menu berubah langsung
- **Save Config**: simpan semua toggle, slider, dan pilihan sekali tap

## Save Config

- File disimpan di `BZ Menu/BZ_<GameID>_Config.json`, contoh `BZ Menu/BZ_123456789_Config.json`. `<GameID>` adalah `game.GameId`, jadi tiap game punya config sendiri.
- Yang tersimpan: semua Toggle, Slider, dan Select Menu (termasuk pengaturan di kategori UI seperti tema dan ukuran logo).
- Saat script dijalankan, config dibaca otomatis. Setiap item yang dibuat dengan **nama yang sama** langsung diisi nilai tersimpannya, dan `callback`-nya ikut dipanggil.
- Karena dicocokkan lewat nama, pakai **nama item yang tetap dan unik** (argumen pertama), misalnya `"speed"`, bukan nama yang berubah-ubah.
- Butuh fungsi executor `writefile`, `readfile`, `isfile`, `isfolder`, dan `makefolder`. Kalau tidak didukung, status di bawah tombol Save Config menampilkan pesan error.

## Dev Tools (khusus `BimzDnu`)

Tab ini hanya muncul kalau username Roblox pemain adalah `BimzDnu`. Isinya:

- Posisi karakter (X, Y, Z) yang update langsung
- Tombol **Copy Coordinate** (`x, y, z`) dan **Copy sebagai Vector3**
- Catatan **Place ID** dan **Game ID**, plus tombol Copy masing-masing

Tombol copy memakai `setclipboard` atau `toclipboard` dari executor.

## Kontrol menu

- **Ketuk logo**: buka menu
- **Tarik header menu**: pindahkan menu
- **Tarik pojok kanan bawah**: ubah ukuran menu
- **Tombol ×**: tutup menu (menu muncul lagi di posisi dan ukuran terakhir)
- **Tarik logo**: pindahkan logo

## Troubleshooting

| Masalah | Penyebab / solusi |
|---|---|
| `attempt to call a table value` | Loader memanggil hasil modul secara salah. Pakai `loadstring(...)()`. Versi ini juga mentoleransi `loadstring(...)()()` |
| Perubahan tidak terlihat | Hosting masih menyajikan file lama. Cek subtitle di header menu, harus tertulis **v2.2** |
| Save Config gagal | Executor tidak mendukung `writefile`/`makefolder`. Pesan errornya tampil di bawah tombol |
| Tombol copy tidak menyalin | Executor tidak mendukung `setclipboard`/`toclipboard` |
| Tab Dev Tools tidak muncul | Memang hanya untuk username `BimzDnu` |

## Catatan

- Semua item butuh `name` yang unik. Item dengan nama sama akan menimpa catatan sebelumnya di registry.
- Menu ini hanyalah antarmuka; fungsi fitur (speed, ESP, dan lainnya) kamu isi sendiri di `callback`.
