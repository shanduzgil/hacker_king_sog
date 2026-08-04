cd ~/hacker_king_sog

# 1. ایجاد ساختار پوشه‌های بسته دبیان
mkdir -p deb_package/DEBIAN
mkdir -p deb_package/usr/local/bin
mkdir -p deb_package/usr/local/lib/python3.14/dist-packages/hacker_king_sog

# 2. کپی فایل‌های اصلی
cp hacker_king_sog/__init__.py deb_package/usr/local/lib/python3.14/dist-packages/hacker_king_sog/
cp hacker_king_sog/core_secure.cpython-314-aarch64-linux-android.so deb_package/usr/local/lib/python3.14/dist-packages/hacker_king_sog/
cp hacker_king_sog/libfake.so deb_package/usr/local/lib/python3.14/dist-packages/hacker_king_sog/
cp hacker_king_sog/wasm_payload.wat deb_package/usr/local/lib/python3.14/dist-packages/hacker_king_sog/

# 3. ایجاد فایل کنترل (کنترل بسته)
cat > deb_package/DEBIAN/control << 'EOF'
Package: hacker-king-sog
Version: 1.0.2
Section: utils
Priority: optional
Architecture: arm64
Maintainer: Abolfazl Soleimani <giabolfazl64@gmail.com>
Description: Ultimate Next-Gen Penetration Tool (Fully Operational)
 A powerful security research tool for penetration testing.
EOF

# 4. ایجاد اسکریپت نصب (اختیاری)
cat > deb_package/DEBIAN/postinst << 'EOF'
#!/bin/bash
echo "hacker-king-sog installed successfully!"
echo "Run: hacker_king_sog <target>"
EOF
chmod +x deb_package/DEBIAN/postinst

# 5. ساخت فایل .deb
dpkg-deb --build deb_package
