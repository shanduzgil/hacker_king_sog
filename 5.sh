#!/bin/bash

echo "=============================="
echo "  انتشار خودکار در GitHub"
echo "=============================="

# ۱. بررسی نصب GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "[*] GitHub CLI not found. Installing..."
    pkg install gh
fi

# ۲. ورود به GitHub (اگر لاگین نکرده باشید)
if ! gh auth status &> /dev/null; then
    echo "[*] Please login to GitHub:"
    gh auth login
fi

# ۳. تنظیم متغیرها
REPO_NAME="hacker_king_sog"
REPO_DESC="Ultimate Next-Gen Penetration Tool – Fully Operational"
USERNAME=$(gh api user | grep -o '"login":"[^"]*' | cut -d'"' -f4)
VERSION="v1.0.3"
PASSWORD="Abolfazl_king_sog@"

# ۴. ایجاد مخزن (اگر وجود نداشته باشد)
echo "[*] Creating repository $REPO_NAME..."
if ! gh repo view "$USERNAME/$REPO_NAME" &> /dev/null; then
    gh repo create "$REPO_NAME" --public --description "$REPO_DESC" --clone
else
    echo "[!] Repository already exists. Pulling latest changes..."
    cd "$REPO_NAME" && git pull origin main && cd ..
fi

# ۵. کپی فایل‌های بسته به پوشه‌ی مخزن
echo "[*] Copying files to repository..."
mkdir -p "$REPO_NAME"
cp ~/hacker_king_sog/hacker_king_sog_secure.enc "$REPO_NAME/"
cp ~/hacker_king_sog/hacker_king_sog_secure.enc.sha256 "$REPO_NAME/"
cp ~/hacker_king_sog/README.md "$REPO_NAME/" 2>/dev/null || echo "# hacker_king_sog" > "$REPO_NAME/README.md"

# ۶. ساخت README کامل
cat > "$REPO_NAME/README.md" << EOF
# hacker_king_sog

Ultimate Next-Gen Penetration Tool – Fully Operational.

**Author:** Abolfazl Soleimani  
**Version:** 1.0.3  
**License:** Proprietary – All Rights Reserved.

---

## 🔧 Installation

1. **Download the encrypted package:**
   \`\`\`bash
   wget https://github.com/$USERNAME/$REPO_NAME/releases/download/$VERSION/hacker_king_sog_secure.enc
   wget https://github.com/$USERNAME/$REPO_NAME/releases/download/$VERSION/hacker_king_sog_secure.enc.sha256
   \`\`\`

2. **Verify checksum:**
   \`\`\`bash
   sha256sum -c hacker_king_sog_secure.enc.sha256
   \`\`\`

3. **Decrypt the package:**
   \`\`\`bash
   openssl enc -d -aes-256-cbc -pbkdf2 -in hacker_king_sog_secure.enc -out hacker_king_sog.deb -pass pass:$PASSWORD
   \`\`\`

4. **Install:**
   \`\`\`bash
   dpkg -i hacker_king_sog.deb
   \`\`\`

5. **Run:**
   \`\`\`bash
   hacker_king_sog example.com
   \`\`\`

---

## ⚠️ Warning

This tool is designed for **security testing in authorized environments only**. Unauthorized use is illegal and strictly prohibited.

**Use responsibly.**

---

## 📦 Package Contents

- \`hacker_king_sog_secure.enc\` – Encrypted .deb package  
- \`hacker_king_sog_secure.enc.sha256\` – Integrity checksum  
- Password: \`$PASSWORD\`

---

## 🛠️ Build from Source (for developers)

1. Clone the repository:
   \`\`\`bash
   git clone https://github.com/$USERNAME/$REPO_NAME.git
   cd $REPO_NAME
   \`\`\`

2. Run the build script:
   \`\`\`bash
   bash 3.sh
   \`\`\`

---

**© 2026 Abolfazl Soleimani. All rights reserved.**
EOF

# ۷. commit و push کردن
echo "[*] Committing and pushing to GitHub..."
cd "$REPO_NAME"
git add .
git commit -m "Release $VERSION"
git push origin main

# ۸. ساخت ریلیز
echo "[*] Creating GitHub Release..."
gh release create "$VERSION" \
    --title "hacker_king_sog $VERSION" \
    --notes "🔑 Password: \`$PASSWORD\`\n\n📦 Includes encrypted .deb package with checksum.\n\n⚠️ For authorized security testing only." \
    hacker_king_sog_secure.enc \
    hacker_king_sog_secure.enc.sha256

# ۹. نمایش لینک نهایی
echo "=============================="
echo "✅ انتشار با موفقیت انجام شد!"
echo "🔗 لینک مخزن: https://github.com/$USERNAME/$REPO_NAME"
echo "🔗 لینک ریلیز: https://github.com/$USERNAME/$REPO_NAME/releases/tag/$VERSION"
echo ""
echo "📌 کاربران با دستورات زیر نصب می‌کنند:"
echo "   wget https://github.com/$USERNAME/$REPO_NAME/releases/download/$VERSION/hacker_king_sog_secure.enc"
echo "   wget https://github.com/$USERNAME/$REPO_NAME/releases/download/$VERSION/hacker_king_sog_secure.enc.sha256"
echo "   sha256sum -c hacker_king_sog_secure.enc.sha256"
echo "   openssl enc -d -aes-256-cbc -pbkdf2 -in hacker_king_sog_secure.enc -out hacker_king_sog.deb -pass pass:$PASSWORD"
echo "   dpkg -i hacker_king_sog.deb"
echo "=============================="
