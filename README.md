# [WIP]FastHysteria2
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
