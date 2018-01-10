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

# Running the demo

Once everything is set up, there are several options to run Android in a
virtual machine with an external baseband. The most convenient solution is
deploying Genode on real hardware using our demo run script. If you don't own a
suitable device, you can also run Genode on your Linux machine or run the demo
on Linux without our baseband filter.

## Genode/NOVA on real hardware

Currently the Lenovo ThinkPad Yoga 12 and the Lenovo Yoga 900 are supported for
the baseband separation demo. Other device may work with minor adjustments.

To run the demo, check out our forked Genode source tree from
[here](https://github.com/Componolit/genode/tree/baseband_fw_support_rndis) and
set it up as described in the README. Adding the external
[Componolit repository](https://github.com/Componolit/componolit.git) is analogous
to adding the external Genode world repository, refer to
[this documentation](https://github.com/genodelabs/genode-world/blob/master/README).
Make sure to check out the `baseband_fw branch` of the Componolit repository.

Once setup, execute the run script for the demo in your build directory:

```sh
$ make run/baseband_demo-tp_yoga_12 # or use run/baseband_demo-yoga_900
```

**WARNING: The next step will destroy all data on your USB drive or damage your system. BE CAREFUL!**

Copy the resulting image `./var/run/baseband_demo-tp_yoga_12.partition.bak` (or
`./var/run/baseband_demo-yoga_900.partition.bak`, respectively) onto the first
partition of the prepared USB drive and use it to boot your system.

```sh
$ sudo dd if=./var/run/baseband_demo-tp_yoga_12.partition.bak of=/dev/sdX1 bs=1M
```

## Linux host

The following scenarios run on your Linux host system without requiring a
separate PC. The baseband phone is connected via USB as usual.

**WARNING: This requires root privileges which can be harmful to your system. BE CAREFUL.**

All three variants require a tap interface and VirtualBox must be set up to use
it for networking. To manually create a TAP interface, the `tunctl` utility can
be installed (found in the `uml-utilities` package in Debian-based distros).
Create a TAP interface called `ril0`:

```sh
$ sudo tunctl -t ril0
```

Next, go to the *Settings* dialog of the Androix-x86 VM prepared earlier. In
the *Network* menu check *Enable Network Adapter* and chose *Bridged Adapter*
from the *Attached to* dropdown menu. Select the `ril0` network interfaces we
just created. Make sure no other network adapters are enabled.

## Genode/base-linux

Follow the instructions for Genode/NOVA above on how to prepare a Genode build
environement. Once setup, execute the run script for the base-linux demo in
your build directory:

```sh
$ IF_AP=ril0 IF_BP=PHONE_IF make run/test/baseband_fw_linux.run
```

Instead of PHONE_IF, substitute the RNDIS network interface offered by the
baseband phone. You should then see the baseband firewall component printing
out log messages.

Running the demo as ordinary user will fail with a permission denied error. The
reason is, that opening raw sockets is a privileged operation. You can grant
the respective components raw network permissions as follows:

```sh
$ sudo setcap cap_net_raw+ep ./app/linux_nic_raweth/client-linux_nic_raweth.stripped
$ sudo setcap cap_net_raw+ep ./server/linux_nic_raweth/server-linux_nic_raweth.stripped
```

The demo script should then run as expected. Note, that you need to repeat the
above step every time you clean you build directory or modify the source tree
in a way that triggers a rebuild of the *raweth* components.

## Linux network bridge

You can connetect baseband phone and application VM without the intermediate
baseband firewall using a Linux network bridge. To simplify the setup, you can
use a script provided with the rilproxy repository:

```sh
$ sudo ./scripts/rilbridge.sh ril0 PHONE_IF
```

Instead of PHONE_IF, substitute the RNDIS network interface offered by the
baseband phone.

## Software bridge

Similar to the Linux bridge, the software bridge from the rilproxy repository
may be used to relay packets between the two interfaces. Build and run it from
the `rilproxy` repository as follows:

```sh
$ make swbridge
$ ./swbridge ril0 PHONE_IF
```

Instead of PHONE_IF, substitute the RNDIS network interface offered by the
baseband phone.

## Wireshark

The Linux-based scenarios are idal to record the traffic between application
processor and baseband processor at the Android RIL level. Simply use tcpdump
or Wireshark on the ril0 interfaces. We provide a Wireshark dissector to
further analyze recorded traffic. To install it perform the follwing steps:

* Get the the Android RIL source:
  `git clone https://android.googlesource.com/platform/hardware/ril`
* Generate constants and definitions in `ril_h.lua`:
  `./scripts/convert_ril_h.py --output ril_h.lua /path/to/ril/source/.../include/telephony/ril.h`
* Copy `ril_h.lua` and `rilsocket.lua` to your Wireshark plugins directory

The Wireshark plugins directory may differ between distros and Wireshark
versions. Check *Help -> About Wireshark -> Directories -> Personal Plugins*
for the right location.
