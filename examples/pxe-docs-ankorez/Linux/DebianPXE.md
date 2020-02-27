# PXE Linux sous Debian

Notes : il faut utiliser syslinux 6.04 pour pouvoir booter en UEFI avec le bootloader syslinux. Il est dispo nativement sur Debian 10.

## Installation

- Installation des paquets

```bash
apt install -y tftpd-hpa syslinux syslinux-efi pxelinux memtest86+ dnsmasq
```

## Configuration

### dnsmasq

- Configuration dnsmasq

```shell
nano /etc/dnsmasq.conf
```

Ajouter

```typescript
# Disable DNS

port=0

# Log lots of extra information about DHCP transactions.

log-dhcp

# Set the root directory for files available via FTP.

tftp-root=/srv/tftp

# Disable re-use of the DHCP servername and filename fields as extra

# option space. That's to avoid confusing some old or broken DHCP clients.

dhcp-no-override

# Test for the architecture of a netboot client. PXE clients are

# supposed to send their architecture as option 93. (See RFC 4578)

dhcp-match=x86PC, option:client-arch, 0 #BIOS x86
dhcp-match=BC_EFI, option:client-arch, 7 #EFI x86-64

# Load different PXE boot image depending on client architecture

pxe-service=tag:x86PC,X86PC, "Install Linux on x86 legacy BIOS", bios/pxelinux.0
pxe-service=tag:BC_EFI,BC_EFI, "Install Linux on x86-64 UEFI", efi64/syslinux.efi

# Set boot file name only when tag is "bios" or "uefi"

dhcp-boot=tag:x86PC,bios/pxelinux.0 # for Legacy BIOS detected by dhcp-match above
dhcp-boot=tag:BC_EFI,efi64/syslinux.efi # for UEFI arch detected by dhcp-match above

# The boot filename, Server name, Server Ip Address

#dhcp-boot=pxelinux.0,,192.168.2.60

# Proxy DHCP

dhcp-range=192.168.2.254,proxy
```

### tftp

- Préparation des répertoires

```shell
mkdir -p /srv/tftp/boot/
mkdir -p /srv/tftp/bios/pxelinux.cfg/
mkdir -p /srv/tftp/efi64/pxelinux.cfg/
```

**BIOS**

```shell
cp /usr/lib/syslinux/modules/bios/* /srv/tftp/bios/
cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp/bios/
cp /boot/memtest86+.bin /srv/tftp/bios/
```

**Menu BIOS**

```shell
nano /srv/tftp/bios/pxelinux.cfg/default
```

```
DEFAULT vesamenu.c32
PROMPT 0
TIMEOUT 300
ONTIMEOUT 0
NOESCAPE 1
menu title **** Menu BIOS PXE ****
label 0  
menu label ^Demarrage sur disque dur local
menu default
localboot 0
label 1
menu label ^Redemarrage
kernel reboot.c32
label 2
menu label ^Arret
kernel poweroff.c32
LABEL 3
MENU LABEL ^HDT - Outil de detection materiel
KERNEL hdt.c32
LABEL 4
MENU LABEL Netboot Debian 9
KERNEL boot/debian/installer/stretch/amd64/linux
APPEND vga=788 initrd=boot/debian/installer/stretch/amd64/initrd.gz --- quiet
```

**UEFI**

```shell
cp /usr/lib/syslinux/modules/efi64/* /srv/tftp/efi64/
cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp/efi64/
cp /boot/memtest86+.bin /srv/tftp/efi64/
```

**Menu UEFI**

```shell
nano /srv/tftp/efi64/pxelinux.cfg/default
```

```
DEFAULT vesamenu.c32
PROMPT 0
TIMEOUT 300
ONTIMEOUT 0
NOESCAPE 1
KBDMAP french.kbd
menu title **** Menu EFI64 PXE ****
label 0
menu label ^Demarrage sur disque dur local
menu default
localboot 0
label 1
menu label ^Redemarrage
kernel reboot.c32
label 2
menu label ^Arret
kernel poweroff.c32
LABEL 3
MENU LABEL ^HDT - Outil de detection materiel
KERNEL hdt.c32
LABEL 4
MENU LABEL Netboot Debian 9
KERNEL boot/debian/installer/stretch/amd64/linux
APPEND vga=788 initrd=boot/debian/installer/stretch/amd64/initrd.gz --- quiet
```

- Liens relatifs

```shell
cd /srv/tftp/bios && ln -s ../boot boot
cd /srv/tftp/efi64 && ln -s ../boot boot
```

### syslinux

- Fix boot UEFI avec syslinux 6.04

```shell
wget https://www.zytor.com/pub/syslinux/Testing/6.04/syslinux-6.04-pre1.tar.gz
tar -zxf syslinux-6.04-pre1.tar.gz
scp /home/benjamin/syslinux-6.04-pre1/efi64/efi/syslinux.efi /srv/tftp/efi64/
scp /home/benjamin/syslinux-6.04-pre1/efi64/com32/elflink/ldlinux/ldlinux.e64 /srv/tftp/efi64/
```

## Utilisation

- Télécharger et ajouter une Debian netboot au pxe

```shell
mkdir -p /srv/tftp/boot/debian/installer/stretch/
cd /tmp
wget -c http://ftp.nl.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar -zxf netboot.tar.gz 
mv debian-installer/amd64/ /srv/tftp/boot/debian/installer/stretch/
```

- Relancer les services

```shell
systemctl restart dnsmasq.service && systemctl restart tftpd-hpa.service
```

**Boot WinPE**

- Telecharger wimboot

[https://git.ipxe.org/release/wimboot/](https://git.ipxe.org/release/wimboot/ "https://git.ipxe.org/release/wimboot/")

- Le décompresser dans le répertoire /boot

- Copier le fichier linux.c32 depuis /bios vers /boot

```shell
nano /srv/tftp/bios/pxelinux.cfg/default
```

```
LABEL 5
MENU LABEL WinPE TEST
COM32 boot/linux.c32
APPEND boot/wimboot initrdfile=boot/WinPE/bootmgr,boot/WinPE/BCD,boot/WinPE/boot.sdi,boot/WinPE/boot.wim

[https://www.howtogeek.com/162070/it-geek-how-to-network-boot-pxe-the-winpe-recovery-disk-with-pxelinux-v5-wimboot/](https://www.howtogeek.com/162070/it-geek-how-to-network-boot-pxe-the-winpe-recovery-disk-with-pxelinux-v5-wimboot/ "https://www.howtogeek.com/162070/it-geek-how-to-network-boot-pxe-the-winpe-recovery-disk-with-pxelinux-v5-wimboot/")
```

[http://forum.ipxe.org/showthread.php?tid=7445](http://forum.ipxe.org/showthread.php?tid=7445 "http://forum.ipxe.org/showthread.php?tid=7445")
