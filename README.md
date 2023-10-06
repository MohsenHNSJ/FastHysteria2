[Click here to jump to English](https://github.com/MohsenHNSJ/FastHysteria2#fasthysteria2)

# FastHysteria2
اجرای سریع Hysteria 2
بهینه شده برای ایران

با تشکر از: [@SasukeFreestyle](https://github.com/SasukeFreestyle) برای آموزش اصلی

# نیازمندی ها:
1. یک سرور مجازی با سیستم عامل لینوکس واقع شده در خارج از ایران که از داخل ایران قابل دسترسی باشد (بر روی اوبونتو 22.04 تست شده)
2.  در صورت امکان با دستورات apt update و apt upgrade بسته های سیستم عامل را بروزرسانی کنید (اختیاری) (جهت افزایش امنیت و عملکرد)

 # نحوه استفاده:
1. دستور زیر را در سرور مجازی خود اجرا کنید:
```
sudo curl -s https://raw.githubusercontent.com/MohsenHNSJ/FastHysteria2/master/Hysteria2.sh | bash
```
2. چند دقیقه صبر کنید و سپس کد QR نشان داده شده را اسکن کنید

 # سلامت باشید!

# FastHysteria2
Fast Hysteria 2
Optimized for Iran
 
Thanks to: [@SasukeFreestyle](https://github.com/SasukeFreestyle) for the original tutorial

# Features:
- Install and run LATEST Hysteria 2 server with one command for the following architectures: `amd64` `amd64v3` `arm64` `armv7`
- Update required packages automatically
- Optimize server settings for best performance
- Sets up the Hysteria on a separate user (NOT `root`) that is randomly created
- Configures `ufw` to allow port 443
- Uses `AVX` optimized package automatically if the machine supports it (`amd64v3`)
- Generates required certificates and keys
- Generates QR-Code to connect easily

# Requires:
1. VPS with Linux OS outside of Iran and accessible by the user (Tests were done on Ubuntu 22.04)
2. Optionally upgrade all your OS packages to the latest version (for security and performance)

# Usage:
1. Run the following command in your VPS:

```
sudo curl -s https://raw.githubusercontent.com/MohsenHNSJ/FastHysteria2/master/Hysteria2.sh | bash
```

2. Wait a few minutes and scan the QR Code

### Peace
