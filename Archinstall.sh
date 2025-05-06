#!/bin/bash

# Hacer ping a google.com
ping -c 1 google.com &> /dev/null

# Comprobar el estado de salida del último comando ejecutado
if [ $? -eq 0 ]; then
    echo "OK"
else
    echo "KO"
fi

#---------------------------------------------------------------------

#!/bin/bash

# Muestra los discos duros
lsblk

# Pide al usuario que seleccione un disco
echo "Introduce el nombre del disco que quieres particionar (ej. sda):"
read DISK

# Verifica que el disco existe
if [ ! -b "/dev/$DISK" ]; then
    echo "El disco /dev/$DISK no existe."
    exit 1
fi

# Crea la partición EFI
echo "Creando la partición EFI..."
parted /dev/$DISK mklabel gpt
parted /dev/$DISK mkpart ESP fat32 1MiB 513MiB
parted /dev/$DISK set 1 boot on

# Verifica que la partición EFI se creó correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al crear la partición EFI. Cancelando el resto del proceso."
    exit 1
fi

# Obtiene la cantidad de RAM en el sistema
RAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
RAM=$(($RAM / 1024))

# Crea la partición swap
echo "Creando la partición swap..."
parted /dev/$DISK mkpart primary linux-swap 513MiB $(($RAM + 513))MiB

# Crea la partición del sistema
echo "Creando la partición del sistema..."
parted /dev/$DISK mkpart primary btrfs $(($RAM + 513))MiB 100%

# Formatea las particiones
mkfs.fat -F32 /dev/${DISK}1
mkswap /dev/${DISK}2
mkfs.btrfs /dev/${DISK}3

echo "Las particiones han sido creadas exitosamente."

#----------------------------------------------------------------------

#!/bin/bash

# Pide al usuario que introduzca el nombre del disco
echo "Introduce el nombre del disco que quieres montar (ej. sda3):"
read DISK

# Verifica que el disco existe
if [ ! -b "/dev/$DISK" ]; then
    echo "El disco /dev/$DISK no existe."
    exit 1
fi

# Monta el volumen de btrfs
echo "Montando el volumen de btrfs..."
mount /dev/$DISK /mnt

# Verifica que el volumen se montó correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al montar el volumen de btrfs. Cancelando el resto del proceso."
    exit 1
fi

# Crea los subvolumenes
echo "Creando los subvolumenes..."
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

# Verifica que los subvolumenes se crearon correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al crear los subvolumenes. Cancelando el resto del proceso."
    umount /mnt
    exit 1
fi

# Desmonta el volumen
umount /mnt

# Monta todos los subvolumenes
echo "Montando todos los subvolumenes..."
mount -o noatime,compress=lzo,space_cache=v2,subvol=@root /dev/$DISK /mnt
mkdir -p /mnt/{boot,var,home,.snapshots}
mount -o noatime,compress=lzo,space_cache=v2,subvol=@var /dev/$DISK /mnt/var
mount -o noatime,compress=lzo,space_cache=v2,subvol=@home /dev/$DISK /mnt/home
mount -o noatime,compress=lzo,space_cache=v2,subvol=@snapshots /dev/$DISK /mnt/.snapshots

# Verifica que los subvolumenes se montaron correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al montar los subvolumenes. Cancelando el resto del proceso."
    umount /mnt /mnt/var /mnt/home /mnt/.snapshots
    exit 1
fi

echo "Los subvolumenes han sido creados y montados exitosamente."

#------------------------------------------------------------------------------------

#!/bin/bash

# Pide al usuario que introduzca el nombre del disco
echo "Introduce el nombre de la partición boot (ej. sda1):"
read DISK

# Verifica que el disco existe
if [ ! -b "/dev/$DISK" ]; then
    echo "El disco /dev/$DISK no existe."
    exit 1
fi

# Monta la partición boot
echo "Montando la partición boot..."
mount /dev/$DISK /mnt/boot

# Verifica que la partición se montó correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al montar la partición boot. Cancelando el resto del proceso."
    exit 1
fi

# Pregunta al usuario qué quiere instalar
# Pregunta al usuario qué kernel desea instalar
echo "¿Qué kernel desea instalar? [1] linux [2] linux-zen [3] linux-lts [4] linux-rt"
read KERNEL_OPTION

case $KERNEL_OPTION in
    1)
        KERNEL="linux"
        ;;
    2)
        KERNEL="linux-zen"
        ;;
    3)
        KERNEL="linux-lts"
        ;;
    4)
        KERNEL="linux-rt"
        ;;
    *)
        echo "Opción no válida. Cancelando el resto del proceso."
        umount /mnt/boot
        exit 1
        ;;
esac
echo "¿Qué editor de texto quieres instalar? [1] nano [2] vi [3] vim [4] neovim"
read EDITOR_OPTION

case $EDITOR_OPTION in
    1)
        EDITOR="nano"
        ;;
    2)
        EDITOR="vi"
        ;;
    3)
        EDITOR="vim"
        ;;
    4)
        EDITOR="neovim"
        ;;
    *)
        echo "Opción no válida. Cancelando el resto del proceso."
        umount /mnt/boot
        exit 1
        ;;
esac
echo "¿Qué procesador tienes? [1] AMD [2] Intel"
read MICROCODE_OPTION

case $MICROCODE_OPTION in
    1)
        MICROCODE="amd-ucode"
        ;;
    2)
        MICROCODE="intel-ucode"
        ;;
    *)
        echo "Ese procesador no existe. Cancelando el resto del proceso."
        umount /mnt/boot
        exit 1
        ;;
esac

# Instala los paquetes seleccionados
echo "Instalando los paquetes seleccionados..."
pacstrap /mnt base $KERNEL $EDITOR $MICROCODE linux-firmware

# Verifica que los paquetes se instalaron correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al instalar los paquetes. Cancelando el resto del proceso."
    umount /mnt/boot
    exit 1
fi

# Genera el archivo fstab
echo "Generando el archivo fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Verifica que el archivo fstab se generó correctamente
if [ $? -ne 0 ]; then
    echo "Hubo un error al generar el archivo fstab. Cancelando el resto del proceso."
    umount /mnt/boot
    exit 1
fi

echo "El script se ha ejecutado exitosamente."


#--------------------------------------------------------------------------

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

timedatectl list-timezones | grep Madrid

hwclock --systohc

echo "es_ES.UTF-8" > /etc/locale.gen

locale-gen

echo "LANG=es_ES.UTF-8" > /etc/locale.conf

echo "KEYMAP=es_ES" > /etc/vconsole.conf

echo "archlinux" > /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1  localhost
::1        localhost
127.0.1.1  archlinux.localdomain    archlinux
EOF

passwd

pacman -S grub efibootmgr networkmanager network-manager-applet dialog mtools dosfstools git reflector snapper hplip xdg-utils xdg-user-dirs alsa-utils pulseaudio inetutils base-devel linux-headers

cat <<EOF > /etc/mkinitcpio.conf
# vim:set ft=sh
# MODULES
# The following modules are loaded before any boot hooks are
# run.  Advanced users may wish to specify all system modules
# in this array.  For instance:
#     MODULES=(usbhid xhci_hcd)
MODULES=(btrfs)

# BINARIES
# This setting includes any additional binaries a given user may
# wish into the CPIO image.  This is run last, so it may be used to
# override the actual binaries included by a given hook
# BINARIES are dependency parsed, so you may safely ignore libraries
BINARIES=()

# FILES
# This setting is similar to BINARIES above, however, files are added
# as-is and are not parsed in any way.  This is useful for config files.
FILES=()

# HOOKS
# This is the most important setting in this file.  The HOOKS control the
# modules and scripts added to the image, and what happens at boot time.
# Order is important, and it is recommended that you do not change the
# order in which HOOKS are added.  Run 'mkinitcpio -H <hook name>' for
# help on a given hook.
# 'base' is _required_ unless you know precisely what you are doing.
# 'udev' is _required_ in order to automatically load modules
# 'filesystems' is _required_ unless you specify your fs modules in MODULES
# Examples:
##   This setup specifies all modules in the MODULES setting above.
##   No RAID, lvm2, or encrypted root is needed.
#    HOOKS=(base)
#
##   This setup will autodetect all modules for your system and should
##   work as a sane default
#    HOOKS=(base udev autodetect modconf block filesystems fsck)
#
##   This setup will generate a 'full' image which supports most systems.
##   No autodetection is done.
#    HOOKS=(base udev modconf block filesystems fsck)
#
##   This setup assembles a mdadm array with an encrypted root file system.
##   Note: See 'mkinitcpio -H mdadm_udev' for more information on RAID devices.
#    HOOKS=(base udev modconf keyboard keymap consolefont block mdadm_udev encrypt filesystems fsck)
#
##   This setup loads an lvm2 volume group.
#    HOOKS=(base udev modconf block lvm2 filesystems fsck)
#
##   This will create a systemd based initramfs which loads an encrypted root filesystem.
#    HOOKS=(base systemd autodetect modconf kms keyboard sd-vconsole sd-encrypt block filesystems fsck)
#
##   NOTE: If you have /usr on a separate partition, you MUST include the
#    usr and fsck hooks.
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)

# COMPRESSION
# Use this to compress the initramfs image. By default, zstd compression
# is used for Linux ≥ 5.9 and gzip compression is used for Linux < 5.9.
# Use 'cat' to create an uncompressed image.
#COMPRESSION="zstd"
#COMPRESSION="gzip"
#COMPRESSION="bzip2"
#COMPRESSION="lzma"
#COMPRESSION="xz"
#COMPRESSION="lzop"
#COMPRESSION="lz4"

# COMPRESSION_OPTIONS
# Additional options for the compressor
#COMPRESSION_OPTIONS=()

# MODULES_DECOMPRESS
# Decompress loadable kernel modules and their firmware during initramfs
# creation. Switch (yes/no).
# Enable to allow further decreasing image size when using high compression
# (e.g. xz -9e or zstd --long --ultra -22) at the expense of increased RAM usage
# at early boot.
# Note that any compressed files will be placed in the uncompressed early CPIO
# to avoid double compression.
#MODULES_DECOMPRESS="no"
EOF

mkinitcpio -p linux

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager

useradd -mG wheel xaviepunk

passwd xaviepunk

cat <<EOF > /etc/sudoers
## sudoers file.
##
## This file MUST be edited with the 'visudo' command as root.
## Failure to use 'visudo' may result in syntax or file permission errors
## that prevent sudo from running.
##
## See the sudoers man page for the details on how to write a sudoers file.
##

##
## Host alias specification
##
## Groups of machines. These may include host names (optionally with wildcards),
## IP addresses, network numbers or netgroups.
# Host_Alias	WEBSERVERS = www1, www2, www3

##
## User alias specification
##
## Groups of users.  These may consist of user names, uids, Unix groups,
## or netgroups.
# User_Alias	ADMINS = millert, dowdy, mikef

##
## Cmnd alias specification
##
## Groups of commands.  Often used to group related commands together.
# Cmnd_Alias	PROCESSES = /usr/bin/nice, /bin/kill, /usr/bin/renice, \
# 			    /usr/bin/pkill, /usr/bin/top
#
# Cmnd_Alias	REBOOT = /sbin/halt, /sbin/reboot, /sbin/poweroff
#
# Cmnd_Alias	DEBUGGERS = /usr/bin/gdb, /usr/bin/lldb, /usr/bin/strace, \
# 			    /usr/bin/truss, /usr/bin/bpftrace, \
# 			    /usr/bin/dtrace, /usr/bin/dtruss
#
# Cmnd_Alias	PKGMAN = /usr/bin/apt, /usr/bin/dpkg, /usr/bin/rpm, \
# 			 /usr/bin/yum, /usr/bin/dnf,  /usr/bin/zypper, \
# 			 /usr/bin/pacman

##
## Defaults specification
##
## Preserve editor environment variables for visudo.
## To preserve these for all commands, remove the "!visudo" qualifier.
Defaults!/usr/bin/visudo env_keep += "SUDO_EDITOR EDITOR VISUAL"
##
## Use a hard-coded PATH instead of the user's to find commands.
## This also helps prevent poorly written scripts from running
## arbitrary commands under sudo.
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/bin"
##
## You may wish to keep some of the following environment variables
## when running commands via sudo.
##
## Locale settings
# Defaults env_keep += "LANG LANGUAGE LINGUAS LC_* _XKB_CHARSET"
##
## Run X applications through sudo; HOME is used to find the
## .Xauthority file.  Note that other programs use HOME to find   
## configuration files and this may lead to privilege escalation!
# Defaults env_keep += "HOME"
##
## X11 resource path settings
# Defaults env_keep += "XAPPLRESDIR XFILESEARCHPATH XUSERFILESEARCHPATH"
##
## Desktop path settings
# Defaults env_keep += "QTDIR KDEDIR"
##
## Allow sudo-run commands to inherit the callers' ConsoleKit session
# Defaults env_keep += "XDG_SESSION_COOKIE"
##
## Uncomment to enable special input methods.  Care should be taken as
## this may allow users to subvert the command being run via sudo.
# Defaults env_keep += "XMODIFIERS GTK_IM_MODULE QT_IM_MODULE QT_IM_SWITCHER"
##
## Uncomment to disable "use_pty" when running commands as root.
## Commands run as non-root users will run in a pseudo-terminal,
## not the user's own terminal, to prevent command injection.
# Defaults>root !use_pty
##
## Uncomment to run commands in the background by default.
## This can be used to prevent sudo from consuming user input while
## a non-interactive command runs if "use_pty" or I/O logging are
## enabled.  Some commands may not run properly in the background.
# Defaults exec_background
##
## Uncomment to send mail if the user does not enter the correct password.
# Defaults mail_badpass
##
## Uncomment to enable logging of a command's output, except for
## sudoreplay and reboot.  Use sudoreplay to play back logged sessions.
## Sudo will create up to 2,176,782,336 I/O logs before recycling them.
## Set maxseq to a smaller number if you don't have unlimited disk space.
# Defaults log_output
# Defaults!/usr/bin/sudoreplay !log_output
# Defaults!/usr/local/bin/sudoreplay !log_output
# Defaults!REBOOT !log_output
# Defaults maxseq = 1000
##
## Uncomment to disable intercept and log_subcmds for debuggers and
## tracers.  Otherwise, anything that uses ptrace(2) will be unable
## to run under sudo if intercept_type is set to "trace".
# Defaults!DEBUGGERS !intercept, !log_subcmds
##
## Uncomment to disable intercept and log_subcmds for package managers.
## Some package scripts run a huge number of commands, which is made
## slower by these options and also can clutter up the logs.
# Defaults!PKGMAN !intercept, !log_subcmds
##
## Uncomment to disable PAM silent mode.  Otherwise messages by PAM
## modules such as pam_faillock will not be printed.
# Defaults !pam_silent

##
## Runas alias specification
##

##
## User privilege specification
##
root ALL=(ALL:ALL) ALL

## Uncomment to allow members of group wheel to execute any command
# %wheel ALL=(ALL:ALL) ALL

## Same thing without a password
%wheel ALL=(ALL:ALL) NOPASSWD: ALL

## Uncomment to allow members of group sudo to execute any command
# %sudo	ALL=(ALL:ALL) ALL

## Uncomment to allow any user to run sudo if they know the password
## of the user they are running the command as (root by default).
# Defaults targetpw  # Ask for the password of the target user
# ALL ALL=(ALL:ALL) ALL  # WARNING: only use this together with 'Defaults targetpw'

## Read drop-in files from /etc/sudoers.d
@includedir /etc/sudoers.d
EOF

pacman -S bash-completion

exit

umount -a

reboot now

sudo umount /.snapshots

sudo rm -r /.snapshots

sudo snapper -c root create-config /

sudo btrfs subvolume delete /.snapshots

sudo mkdir /.snapshots

sudo mount -a

sudo chmod 750 /.snapshots

cat <<FDL > /etc/snapper/configs/root

# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"


# btrfs qgroup for space aware cleanup algorithms
QGROUP=""


# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"


# users and groups allowed to work with config
ALLOW_USERS="xaviepunk"
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="no"


# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"


# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="3600"
NUMBER_LIMIT="50"
NUMBER_LIMIT_IMPORTANT="10"


# create hourly snapshots
TIMELINE_CREATE="yes"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="yes"

# limits for timeline cleanup
TIMELINE_MIN_AGE="3600"
TIMELINE_LIMIT_HOURLY="5"
TIMELINE_LIMIT_DAILY="7"
TIMELINE_LIMIT_WEEKLY="0"
TIMELINE_LIMIT_MONTHLY="10"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="0"


# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="3600"

FDL

sudo systemctl enable --now snapper-timeline.timer

sudo systemctl enable --now snapper-cleanup.timer
