# BZ Menu UI v2.6

Modul menu UI untuk Roblox (Lua) buatan **Studio The Clown**, bertema ungu. Dipakai lewat `loadstring` dan dikontrol dari script kamu sendiri.

## Fitur

- Logo kecil yang bisa digeser; ketuk untuk membuka menu
- Menu bisa digeser (tarik header) dan diubah ukurannya (pegangan di pojok kanan bawah)
- Menu pertama kali terbuka dengan ukuran maksimum (otomatis dibatasi ke ukuran layar)
- Posisi dan ukuran terakhir menu diingat selama sesi
- Kategori/tab dengan animasi geser
- Elemen: Section, Toggle (5 gaya: switch, checkbox, radio, pill, button), Slider (angka bulat dan desimal), Select Menu, Multi Select Menu, Tap Button, dan Note (teks)
- Kategori **UI** bawaan: Logo Size, Logo Transparan, Thema, Save Config
- 7 tema: Cyan, Kuning, Merah, Ungu (default), Sakura, White, Black
- Save Config per game ke folder `BZ Menu`
- Kategori **Dev Tools** khusus username `BimzDnu`

## Cara pakai

### 1. Muat modul

```lua
local BZ = loadstring(game:HttpGet("URL_FILE_LUA_KAMU"))()
```

Ganti `URL_FILE_LUA_KAMU` dengan link raw ke file `BZ_Menu_UI_v2.6.lua` yang kamu upload (misalnya GitHub raw). Setelah termuat, log console menampilkan `[BZ] Menu UI v2.6 module ready.`

### 2. Contoh lengkap

```lua
local BZ = loadstring(game:HttpGet("URL_FILE_LUA_KAMU"))()
local lp = game.Players.LocalPlayer

-- Kategori pertama
BZ:AddCategory("move", "Movement", "fa-bolt")

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
BZ:AddCategory("esp", "ESP", "fa-eye")
BZ:AddToggle("box", "Box ESP", false, function(on) end, "checkbox")

BZ:AddSelectMenu("target", "Target", {"Head", "Torso", "Random"}, "Head", function(v)
    print("target", v)
end)

BZ:AddMultiSelectMenu("parts", "Bagian", {"Head", "Torso", "Arms", "Legs", "Feet"}, {"Head"}, function(list)
    print("terpilih:", table.concat(list, ", "))
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
| `BZ:AddCategory(name, label, icon)` | Buat tab baru dengan ikon opsional (lihat "Ikon kategori"). Item yang ditambah setelahnya masuk ke tab ini |
| `BZ:SetCategoryIcon(name, icon)` | Ganti ikon tab yang sudah ada |
| `BZ:UseCategory(name)` | Arahkan item berikutnya ke tab yang sudah ada |
| `BZ:SelectCategory(name)` | Buka tab lewat kode |

Item yang ditambah sebelum ada kategori masuk ke tab **Main**. Tab **UI** (dan **Dev Tools** untuk `BimzDnu`) selalu berada di urutan paling akhir.

### Ikon kategori

Argumen ketiga `AddCategory` berisi ikon, dan bisa berupa:

- **Nama gaya Font Awesome**: `"eye"`, `"fa-eye"`, atau `"fa-solid fa-eye"` semuanya valid
- **Gambar Roblox**: angka atau `"rbxassetid://ID"` (warnanya otomatis ikut tema)
- **Glyph/emoji langsung**: misalnya `"★"` atau `"🔥"`

```lua
BZ:AddCategory("esp", "ESP", "fa-eye")
BZ:AddCategory("move", "Movement", "bolt")
BZ:AddCategory("img", "Custom", 1234567890)   -- ID gambar
BZ:AddCategory("only", "", "fa-cog")          -- label kosong = hanya ikon
```

Roblox tidak punya font Font Awesome, jadi nama FA dipetakan ke glyph/emoji bawaan (misalnya `eye` menjadi 👁). Bentuknya tidak persis ikon Font Awesome dan warnanya tidak ikut tema. Kalau butuh ikon yang persis dan berwarna sesuai tema, pakai ID gambar.

Nama yang tersedia: `eye`, `eye-slash`, `user`, `users`, `cog`, `home`, `bolt`, `fire`, `star`, `heart`, `shield`, `crosshairs`, `map`, `location`, `car`, `plane`, `gamepad`, `palette`, `wrench`, `lock`, `unlock`, `key`, `bell`, `bug`, `code`, `skull`, `ghost`, `sword`, `bomb`, `coins`, `gift`, `search`, `info`, `warning`, `check`, `times`, `list`, `folder`, `save`, `camera`, `music`, `flag`, `globe`, `rocket`, `magic`, `running`, `crown`, `dice`, `clock`, `sun`, `moon`. Beberapa alias juga diterima, misalnya `gear`, `settings`, `target`, `map-marker`, `tools`, `terminal`.

Tab bawaan memakai ikon sendiri: Main (`home`), UI (`palette`), dan Dev Tools (`wrench`).

### Elemen

| Fungsi | Keterangan |
|---|---|
| `BZ:AddSection(text)` | Judul pemisah |
| `BZ:AddToggle(name, label, default, callback, style)` | On/off; `callback(on)`. `style` opsional (lihat "Gaya toggle"), default `"switch"` |
| `BZ:AddSlider(name, label, min, max, default, callback, step)` | Slider angka; `callback(value)`. Kotak angka di kanan bisa diketik langsung |
| `BZ:AddSelectMenu(name, label, {opsi}, default, callback)` | Klik teks pilihan, muncul menu kecil (bisa di-scroll); `callback(pilihan)` |
| `BZ:AddMultiSelectMenu(name, label, {opsi}, {default}, callback)` | Versi multi pilih: klik item untuk centang/lepas, menu kecil tetap terbuka; `callback(list)` menerima array item terpilih |
| `BZ:AddTapToggleOneClick(name, label, callback)` | Tombol dengan ikon tap; tiap tap memanggil `callback()` satu kali |
| `BZ:AddNote(text, name)` | Teks catatan; mengembalikan handle dengan `handle:SetText("baru")` |
| `BZ:RemoveItem(name)` | Hapus item berdasarkan nama |

**Slider:** jika `step` tidak diisi, step otomatis `1` kalau semua angka bulat, atau `0.01` kalau ada desimal. Jumlah desimal yang tampil mengikuti step.

### Gaya toggle

`BZ:AddToggle(name, label, default, callback, style)` mendukung 5 gaya:

| Gaya | Tampilan |
|---|---|
| `"switch"` (default) | Saklar geser |
| `"checkbox"` | Kotak dengan tanda centang |
| `"radio"` | Lingkaran dengan titik di tengah |
| `"pill"` | Kapsul bertuliskan ON / OFF |
| `"button"` | Tanpa indikator; seluruh baris menyala saat aktif |

Alias yang juga diterima: `"toggle"` (= switch), `"check"` / `"box"` (= checkbox), `"dot"` (= radio), `"onoff"` (= pill), `"fill"` (= button). Nama gaya tidak membedakan huruf besar/kecil.

```lua
BZ:AddToggle("a", "Aimbot", false, cb)               -- switch
BZ:AddToggle("b", "Box ESP", true, cb, "checkbox")
BZ:AddToggle("c", "Tracer", false, cb, "radio")
BZ:AddToggle("d", "Names", false, cb, "pill")
BZ:AddToggle("e", "Fullbright", false, cb, "button")

BZ:SetDefaultToggleStyle("checkbox")   -- toggle berikutnya memakai checkbox kalau tidak menyebut gaya
BZ:SetToggleStyle("a", "pill")         -- ganti gaya toggle yang sudah ada
```

### Baca / ubah nilai dari script

| Fungsi | Keterangan |
|---|---|
| `BZ:GetToggle(name)` / `BZ:SetToggle(name, value, silent)` | `silent = true` tidak memanggil callback |
| `BZ:SetToggleStyle(name, style)` / `BZ:SetDefaultToggleStyle(style)` | Ganti gaya satu toggle / gaya bawaan untuk toggle berikutnya |
| `BZ:GetSlider(name)` / `BZ:SetSlider(name, value, silent)` | Sama seperti di atas |
| `BZ:GetSelect(name)` / `BZ:SetSelect(name, value, silent)` | Sama seperti di atas |
| `BZ:GetMultiSelect(name)` / `BZ:SetMultiSelect(name, {list}, silent)` | Baca/ubah daftar item terpilih (array) |

### Teks menu (diubah lewat script)

| Fungsi | Default |
|---|---|
| `BZ:SetTitle("...")` | `BZ Menu` |
| `BZ:SetLogoText("...")` | `BZ` |
| `BZ:SetStudio("...", showVersion)` | `Studio The Clown` (tampil dengan awalan versi; isi `false` untuk menyembunyikannya) |
| `BZ:SetTexts({Title=..., Logo=..., Studio=..., ShowVersion=...})` | Ubah beberapa sekaligus |
| `BZ:ResetTexts()` | Kembalikan semuanya ke default |

Memanggil dengan `nil` atau teks kosong mengembalikan ke default. Teks ini tidak disimpan di config.

### Logo gambar dari link

| Fungsi | Keterangan |
|---|---|
| `BZ:SetLogoImage(url, callback)` | Pakai gambar dari link sebagai logo. `callback(ok, info)` opsional |
| `BZ:ClearLogoImage()` | Kembali ke teks logo |

```lua
BZ:SetLogoImage("https://example.com/logo.png", function(ok, info)
    print(ok, info) -- true, "BZ Menu/cache/logo_xxxxxxxx.png" atau false, pesan error
end)
```

- Gambar didownload sekali, disimpan di `BZ Menu/cache/logo_<hash>.png` (atau `.jpg`), lalu dipakai ulang dari cache pada pemanggilan berikutnya tanpa download lagi. Kalau gambar di link berubah, hapus file cache-nya agar diunduh ulang.
- Link harus langsung ke file gambar (`http://` atau `https://`) berformat **PNG atau JPG**. WebP dan GIF tidak didukung Roblox.
- Slider **Logo Size** dan **Logo Transparan** tetap berlaku untuk gambar. Teks logo disembunyikan selama gambar tampil.
- Butuh fungsi executor `writefile`, `isfile`, dan `getcustomasset` (serta `makefolder` / `isfolder`). Kalau tidak ada, `callback` menerima `false` beserta alasannya.
- Gambar tidak ikut tersimpan di config; panggil `SetLogoImage` di script tiap dijalankan (cepat karena sudah ada di cache).
- ID atau `rbxassetid://` Roblox juga diterima dan dipakai langsung tanpa download.

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
- Yang tersimpan: semua Toggle, Slider, Select Menu, dan Multi Select Menu (termasuk pengaturan di kategori UI seperti tema dan ukuran logo).
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
| Perubahan tidak terlihat | Hosting masih menyajikan file lama. Cek subtitle di header menu, harus tertulis **v2.6** |
| Save Config gagal | Executor tidak mendukung `writefile`/`makefolder`. Pesan errornya tampil di bawah tombol |
| Tombol copy tidak menyalin | Executor tidak mendukung `setclipboard`/`toclipboard` |
| Tab Dev Tools tidak muncul | Memang hanya untuk username `BimzDnu` |
| Logo gambar tidak muncul | Cek pesan di `callback`: link harus ke file PNG/JPG langsung dan executor harus mendukung `writefile` dan `getcustomasset` |

## Catatan

- Semua item butuh `name` yang unik. Item dengan nama sama akan menimpa catatan sebelumnya di registry.
- Menu ini hanyalah antarmuka; fungsi fitur (speed, ESP, dan lainnya) kamu isi sendiri di `callback`.
