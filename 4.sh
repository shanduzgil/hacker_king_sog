#!/bin/bash

echo "=============================="
echo "  تعمیر خودکار و ساخت بسته"
echo "=============================="

# ۱. تصحیح فایل __init__.py در محل نصب
echo "[*] Fixing __init__.py in installed package..."
cat > /data/data/com.termux/files/usr/lib/python3.14/site-packages/hacker_king_sog/__init__.py << 'EOF'
import sys
import os
from .core_secure import run_exploit

def main():
    print("[+] Loading Ultimate Exploit Framework...")
    print("[+] Made by Abolfazl Soleimani")
    
    if len(sys.argv) < 2:
        print("Usage: hacker_king_sog <target_host>")
        sys.exit(1)
    
    target = sys.argv[1]
    print(f"[*] Attacking {target}...")
    
    package_dir = os.path.dirname(__file__)
    libfake_path = os.path.join(package_dir, "libfake.so")
    
    if os.path.exists(libfake_path):
        print("[*] libfake.so found in package.")
        os.environ['LD_PRELOAD'] = libfake_path
        print(f"[*] LD_PRELOAD set to: {libfake_path}")
    else:
        print("[!] libfake.so not found. Injection may fail.")
    
    result = run_exploit(target)
    if result == 0:
        print("[+] Exploit completed. System compromised.")
        print("[+] Check /tmp/.sog_pwn for proof.")
    else:
        print("[-] Exploit failed.")

if __name__ == "__main__":
    main()
EOF

echo "✅ __init__.py fixed."

# ۲. تغییر رمز عبور در اسکریپت 3.sh
echo "[*] Updating password in 3.sh..."
sed -i 's/SuperSecret2026!/Abolfazl_king_sog@/g' ~/hacker_king_sog/3.sh
echo "✅ Password updated to: Abolfazl_king_sog@"

# ۳. اجرای اسکریپت 3.sh برای ساخت بسته‌ی جدید
echo "[*] Running 3.sh to build new secure package..."
cd ~/hacker_king_sog
bash 3.sh

echo "=============================="
echo "✅ همه کارها انجام شد."
echo "🔑 رمز جدید: Abolfazl_king_sog@"
echo "📦 بسته‌ی جدید ساخته شد: hacker_king_sog_secure.enc"
echo "=============================="
