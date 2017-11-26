# About

The Componolit baseband demo shows-cases the separation of the application
processor (AP) from the baseband processor (BP) using a virtualized instance of
Android on Genode. This setup is suitable to protect from attacks on the BP to
compromise the AP. With a trusted component on the path between AP and BP,
sophisticated policies can be enforced on the communication.

(TODO: Describe our current SPARK filter example.)

Note, that you need rather specific hardware to make this demo work out of the
box. Different scenarios may require significant adoption. The PC running
virtualized Android on Genode (on NOVA using VirtualBox) must be a *Lenovo
ThinkPad Yoga 12* or a *Lenovo Yoga 900-ISK* (without touch support for now).
As a phone providing the baseband functionality, we successfully used Motorola
G4 Play.

# Application Processor: The Android VM

We use the [Android-x86 project](http://www.android-x86.org/) as a basis for
our application processor VM. A release known to work is Android-x86 7.1-rc2.
Download the 64-bit ISO image (android-x86_64-7.1-rc2.iso).

## Preparing the VM

You need to install the desktop version of VirtualBox running on a 64-bit Linux
host. Other OSes and 32-bit images may work, but we haven't tried. Create a new
virtual machine of type "Linux" and version "Linux 2.6 / 3.x / 4.x (64-bit)"
with 2GB of RAM. Create a new virtual hard disk with with a size of at least
3.5 GB (depending on the size of your USB flash drive, see below). Chose a VDI
image that is dynamically allocated.

Open the *Settings* dialog for the newly created VM and add the Android-x86 you
have downloaded as a CD-ROM image in the *Storage* dialog. In the audio tab
uncheck "Enable Audio" to disable audio support. In the network tab enable
network Adapter 1 and set it to "NAT". In the *System/Processor* tab check
"Enable PAE/NX". Close the settings dialog and start the VM.

When the Android-x86 boot menu appears, select "Installation" and follow the
instruction. It is important to answer *No* when ask "Do you want to use GPT".
Otherwise the VM will not start in VirtualBox. Create one big partition which
you format with ext4. Answer *Yes* when being asked whether GRUB should be
installed. Also answer *Yes* when being asked for a read-write mounted /system
partition. Chose reboot once the installation has finished. Make sure to remove
the virtual CD-ROM to boot the VM from disk. When started, perform setup and
customization you find appropriate for the VM.

## Installing the VM

In this step we install the proxy relaying the communication between AP And BP
into the Android virtual machine. The required source is available from our
*rilproxy* repository. Note, that `ndk-build` from the [Android
NDK](https://developer.android.com/ndk/downloads/index.html) must be in your
path to build *rilproxy*.

```sh
$ git clone git@github.com:Componolit/rilproxy.git
$ cd rilproxy
$ make vm64
```

Attach the resulting *deploy.iso* image to your Android-x86 VM as you did with
the installation ISO earlier and boot up the VM. Open the *Terminal Emulator*
from the apps menu and run the installation script as super user:

```sh
$ su
# sh /mnt/media_rw/CDROM/install.sh
```

## Tweaking the VM

While the demo uses a virtual phone with typical phone screen size, Android-x86
as well as VirtualBox assume typical desktop PC resolutions. To get a proper
phone resolution, we add custom VESA resolution to the virtual machine.
Assuming the name of your VM is "android", do the following on the command line
of your *host* system:

```sh
$ VBoxManage setextradata "android" "CustomVideoMode1" "464x816x32"
```

*Note: This is for the ThinkPad Yoga 12. For the Yoga 900 demo, chose a
resolution of "768x1355x32" (see vm_width and vm_heigth parameters of the run
files)*

To enable the custom video mode in Android-x86, boot the *VM* in debug mode and
do the following:

```sh
$ su
# mount -o remount,rw /mnt  
# vi /mnt/grub/menu.lst
(add vga=864 to kernel command line)  
# umount /mnt
# reboot -f
```

## Preparing the disk image

To run the demo, you need at least a 4GB USB flash drive with 2 partitions on
it. It *must* have a GPT disk label (*not* MSDOS). The first partition holds
the Genode base system (100 MB usually suffice), the second partition contains
an Ext2 file system to hold the virtual machine disk image and configuration.

To create such an image, proceed as follows (assuming the USB drive is device
/dev/sdX). *Be very careful to use the correct device and backups if necessary
- the following steps will DESTROY your data irrevocably!*

```sh
$ sudo parted --script /dev/sdX mklabel gpt mkpart primary fat32 2048s 100MiB mkpart primary ext2 100MiB 100%
$ sudo mkfs.ext2 /dev/sdX2
```

Mount the second partition and copy the virtual machine prepared earlier into
the root directory. The configuration must be called *android.vbox* and the
disk image must be named *android.vdi* (this is the default when your named
your VM "android").

One manual change to the *android.vbox* configuration are necessary to make it
run on Genode. Change the attribute `location` of the node `HardDisk` to
"/vm/android.vdi".

## Build the demo

We assume you know how to setup a Genode build tree from the Genode
documentation. Checkout the [Componolit
repository](https://github.com/Componolit/componolit.git) into *repos/* and 
build the demo in your build directory:

```sh
$ make run/baseband_demo-tp_yoga_12
$ sudo if=var/run/baseband_demo-tp_yoga_12.partition.bak of=/dev/sdX1 bs=1M
```

# Baseband Processor: The Phone

While we require almost no modification to the system running on the phone, the
presence of an enabled SELinux requires a custom build of Lineage with a small
patch applied. The code name of the Motorola G4 Play is *harpia*, build and
installation instruction can be found in the [Lineage
wiki](https://wiki.lineageos.org/devices/harpia).

## Disabling SELinux

Before starting the build, apply the following patch to
`device/motorola/msm8916-common/BoardConfigCommon.mk`:

```diff
diff --git a/BoardConfigCommon.mk b/BoardConfigCommon.mk
index 4fa6c84..2e14d1b 100644
--- a/BoardConfigCommon.mk
+++ b/BoardConfigCommon.mk
@@ -39,6 +39,7 @@ TARGET_CPU_VARIANT := cortex-a53

 # Kernel
 BOARD_KERNEL_CMDLINE := console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom msm_rtb.filter=0x3F ehci-hcd.park=3 vmalloc=400M androidboot.bootdevice=7824900.sdhci utags.blkdev=/dev/block/bootdevice/by-name/utags utags.backup=/dev/block/bootdevice/by-name/utagsBackup movablecore=160M
+BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
 BOARD_KERNEL_BASE := 0x80000000
 BOARD_KERNEL_PAGESIZE := 2048
 BOARD_KERNEL_SEPARATED_DT := true
```

Then build and install the image as described in the Wiki.

## Installing rilproxy on the phone

Enable USB debugging in the developers menu of your freshly installed Motorola
G4 Play and plug it into your computer. In the *rilproxy* source directory (see
above) perform an installation onto the device:

```sh
$ make device
```
