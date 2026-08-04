#!/bin/bash

cd ~/hacker_king_sog

echo "=============================="
echo "  امن‌سازی بسته hacker_king_sog"
echo "=============================="

# ۱. نصب ابزارهای مورد نیاز
echo "[*] Installing required tools..."
pkg install -y gnupg upx cython

# ۲. پیدا کردن فایل‌های اصلی
echo "[*] Locating files..."
CORE_SO=$(find . -name "core_secure*.so" -type f | head -1)
LIBFAKE_SO=$(find . -name "libfake.so" -type f | head -1)
INIT_PY=$(find . -name "__init__.py" -type f | head -1)

if [ -z "$CORE_SO" ] || [ -z "$LIBFAKE_SO" ] || [ -z "$INIT_PY" ]; then
    echo "❌ یکی از فایل‌های اصلی پیدا نشد!"
    exit 1
fi

echo "✅ core_secure.so: $CORE_SO"
echo "✅ libfake.so: $LIBFAKE_SO"
echo "✅ __init__.py: $INIT_PY"

# ۳. تبدیل __init__.py به باینری با Cython
echo "[*] Compiling __init__.py to binary..."
cd $(dirname "$INIT_PY")
cythonize -i __init__.py
mv __init__.cpython-*.so __init__.so
rm -f __init__.py
cd - > /dev/null

# ۴. فشرده‌سازی و obfuscate کردن فایل‌های .so
echo "[*] Compressing and stripping binaries..."
upx --brute "$CORE_SO" 2>/dev/null
strip --strip-all "$CORE_SO" 2>/dev/null
upx --brute "$LIBFAKE_SO" 2>/dev/null
strip --strip-all "$LIBFAKE_SO" 2>/dev/null

# ۵. محاسبه چکسام و ذخیره در فایل کنترل
echo "[*] Adding checksums to control file..."
CONTROL_FILE="deb_package/DEBIAN/control"
if [ -f "$CONTROL_FILE" ]; then
    echo "Checksum-core: $(sha256sum "$CORE_SO" | cut -d' ' -f1)" >> "$CONTROL_FILE"
    echo "Checksum-libfake: $(sha256sum "$LIBFAKE_SO" | cut -d' ' -f1)" >> "$CONTROL_FILE"
else
    echo "⚠️ فایل کنترل پیدا نشد! از کنترل پیش‌فرض استفاده می‌شود."
fi

# ۶. ساخت بسته .deb جدید
echo "[*] Building new .deb package..."
dpkg-deb --build deb_package_termux
mv deb_package_termux.deb hacker_king_sog_secure.deb

# ۷. امضای دیجیتال با GPG (اگر کلید موجود باشد)
echo "[*] Signing package with GPG..."
if gpg --list-keys >/dev/null 2>&1; then
    dpkg-sig --sign builder hacker_king_sog_secure.deb 2>/dev/null || echo "⚠️ dpkg-sig نصب نیست، امضا با gpg مستقیم:"
    gpg --detach-sign --armor hacker_king_sog_secure.deb
else
    echo "⚠️ کلید GPG یافت نشد. برای امضا ابتدا کلید بسازید: gpg --full-generate-key"
fi

# ۸. رمزنگاری بسته
echo "[*] Encrypting package with AES-256..."
openssl enc -aes-256-cbc -salt -pbkdf2 -in hacker_king_sog_secure.deb -out hacker_king_sog_secure.enc -pass pass:Abolfazl_king_sog@

# ۹. تولید فایل چکسام نهایی
echo "[*] Generating final checksum..."
sha256sum hacker_king_sog_secure.enc > hacker_king_sog_secure.enc.sha256

echo "=============================="
echo "✅ بستهٔ امن نهایی ساخته شد:"
echo "   - hacker_king_sog_secure.enc (رمزنگاری‌شده)"
echo "   - hacker_king_sog_secure.enc.sha256 (چکسام)"
echo "   - hacker_king_sog_secure.deb (امضا‌شده)"
echo ""
echo "🔑 رمز عبور: Abolfazl_king_sog@"
echo "📌 برای نصب، کاربر باید رمزگشایی کند:"
echo "   openssl enc -d -aes-256-cbc -pbkdf2 -in hacker_king_sog_secure.enc -out hacker_king_sog.deb -pass pass:Abolfazl_king_sog@"
echo "   dpkg -i hacker_king_sog.deb"
echo "=============================="
