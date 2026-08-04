# hacker_king_sog

Ultimate Next-Gen Penetration Tool – Fully Operational.

**Author:** Abolfazl Soleimani  
**Version:** 1.0.3  
**License:** Proprietary – All Rights Reserved.

---

## 🔧 Installation

1. **Download the encrypted package:**
   ```bash
   wget https://github.com//hacker_king_sog/releases/download/v1.0.3/hacker_king_sog_secure.enc
   wget https://github.com//hacker_king_sog/releases/download/v1.0.3/hacker_king_sog_secure.enc.sha256
   ```

2. **Verify checksum:**
   ```bash
   sha256sum -c hacker_king_sog_secure.enc.sha256
   ```

3. **Decrypt the package:**
   ```bash
   openssl enc -d -aes-256-cbc -pbkdf2 -in hacker_king_sog_secure.enc -out hacker_king_sog.deb -pass pass:Abolfazl_king_sog@
   ```

4. **Install:**
   ```bash
   dpkg -i hacker_king_sog.deb
   ```

5. **Run:**
   ```bash
   hacker_king_sog example.com
   ```

---

## ⚠️ Warning

This tool is designed for **security testing in authorized environments only**. Unauthorized use is illegal and strictly prohibited.

**Use responsibly.**

---

## 📦 Package Contents

- `hacker_king_sog_secure.enc` – Encrypted .deb package  
- `hacker_king_sog_secure.enc.sha256` – Integrity checksum  
- Password: `Abolfazl_king_sog@`

---

## 🛠️ Build from Source (for developers)

1. Clone the repository:
   ```bash
   git clone https://github.com//hacker_king_sog.git
   cd hacker_king_sog
   ```

2. Run the build script:
   ```bash
   bash 3.sh
   ```

---

**© 2026 Abolfazl Soleimani. All rights reserved.**
