If you have multiple gpus and want to use one for host and one for VM, they need to be in different
iommu groups.

in my case it worked out. if not, see

- https://github.com/bryansteiner/gpu-passthrough-tutorial?tab=readme-ov-file
- https://queuecumber.gitlab.io/linux-acs-override/
- https://vfio.blogspot.com/2014/08/iommu-groups-inside-and-out.html

---

ACS Override Patch (Optional):

For most linux distributions, the ACS Override Patch requires you to download the kernel source code, manually insert
the ACS patch, compile + install the kernel, and then boot directly from the newly patched kernel.8

Since I'm running a Debian-based distribution, I can use one of the pre-compiled kernels with the ACS patch already
applied. After extracting the package contents, install the kernel and headers:

$ sudo dpkg -i linux-headers-5.3.0-acso_5.3.0-acso-1_amd64.deb
$ sudo dpkg -i linux-image-5.3.0-acso_5.3.0-acso-1_amd64.deb
$ sudo dpkg -i linux-libc-dev_5.3.0-acso-1_amd64.deb

Navigate to /boot and verify that you see the new initrd.img and vmlinuz:

$ ls
config-5.3.0-7625-generic initrd.img-5.3.0-7625-generic vmlinuz
config-5.3.0-acso initrd.img-5.3.0-acso vmlinuz-5.3.0-7625-generic
efi initrd.img.old vmlinuz-5.3.0-acso
initrd.img System.map-5.3.0-7625-generic vmlinuz.old
initrd.img-5.3.0-24-generic System.map-5.3.0-acso

We still have to copy the current kernel and initramfs image onto the ESP so that they are automatically loaded by EFI.
We check the current configuration with kernelstub:

$ sudo kernelstub --print-config
kernelstub.Config : INFO Looking for configuration...
kernelstub : INFO System information:

    OS:..................Pop!_OS 19.10
    Root partition:....../dev/dm-1
    Root FS UUID:........2105a9ac-da30-41ba-87a9-75437bae74c6
    ESP Path:............/boot/efi
    ESP Partition:......./dev/nvme0n1p1
    ESP Partition #:.....1alt="virtman_3"
    NVRAM entry #:.......-1
    Boot Variable #:.....0000
    Kernel Boot Options:.quiet loglevel=0 systemd.show_status=false splash amd_iommu=on
    Kernel Image Path:.../boot/vmlinuz
    Initrd Image Path:.../boot/initrd.img
    Force-overwrite:.....False

kernelstub : INFO Configuration details:

ESP Location:................../boot/efi
Management Mode:...............True
Install Loader configuration:..True
Configuration version:.........3

You can see that the "Kernel Image Path" and the "Initrd Image Path" are symbolic links that point to the old kernel and
initrd.

$ ls -l /boot
total 235488
-rw-r--r-- 1 root root 235833 Dec 19 11:56 config-5.3.0-7625-generic
-rw-r--r-- 1 root root 234967 Sep 16 04:31 config-5.3.0-acso
drwx------ 6 root root 4096 Dec 31 1969 efi
lrwxrwxrwx 1 root root 29 Dec 20 11:28 initrd.img -> initrd.img-5.3.0-7625-generic
-rw-r--r-- 1 root root 21197115 Dec 20 11:54 initrd.img-5.3.0-24-generic
-rw-r--r-- 1 root root 95775016 Jan 17 00:33 initrd.img-5.3.0-7625-generic
-rw-r--r-- 1 root root 94051072 Jan 18 19:57 initrd.img-5.3.0-acso
lrwxrwxrwx 1 root root 29 Dec 20 11:28 initrd.img.old -> initrd.img-5.3.0-7625-generic
-rw------- 1 root root 4707483 Dec 19 11:56 System.map-5.3.0-7625-generic
-rw-r--r-- 1 root root 4458808 Sep 16 04:31 System.map-5.3.0-acso
lrwxrwxrwx 1 root root 26 Dec 20 11:28 vmlinuz -> vmlinuz-5.3.0-7625-generic
-rw------- 1 root root 11398016 Dec 19 11:56 vmlinuz-5.3.0-7625-generic
-rw-r--r-- 1 root root 9054592 Sep 16 04:31 vmlinuz-5.3.0-acso
lrwxrwxrwx 1 root root 26 Dec 20 11:28 vmlinuz.old -> vmlinuz-5.3.0-7625-generic

Let's change that:

$ sudo rm /boot/vmlinuz
$ sudo ln -s /boot/vmlinuz-5.3.0-acso /boot/vmlinuz
$ sudo rm /boot/initrd.img
$ sudo ln -s /boot/initrd.img-5.3.0-acso /boot/initrd.img

Verify that the symbolic links now point to the correct kernel and initrd images:

$ ls -l /boot
total 235488
-rw-r--r-- 1 root root 235833 Dec 19 11:56 config-5.3.0-7625-generic
-rw-r--r-- 1 root root 234967 Sep 16 04:31 config-5.3.0-acso
drwx------ 6 root root 4096 Dec 31 1969 efi
lrwxrwxrwx 1 root root 27 Jan 18 20:02 initrd.img -> /boot/initrd.img-5.3.0-acso
-rw-r--r-- 1 root root 21197115 Dec 20 11:54 initrd.img-5.3.0-24-generic
-rw-r--r-- 1 root root 95775016 Jan 17 00:33 initrd.img-5.3.0-7625-generic
-rw-r--r-- 1 root root 94051072 Jan 18 19:57 initrd.img-5.3.0-acso
lrwxrwxrwx 1 root root 29 Dec 20 11:28 initrd.img.old -> initrd.img-5.3.0-7625-generic
-rw------- 1 root root 4707483 Dec 19 11:56 System.map-5.3.0-7625-generic
-rw-r--r-- 1 root root 4458808 Sep 16 04:31 System.map-5.3.0-acso
lrwxrwxrwx 1 root root 24 Jan 18 20:02 vmlinuz -> /boot/vmlinuz-5.3.0-acso
-rw------- 1 root root 11398016 Dec 19 11:56 vmlinuz-5.3.0-7625-generic
-rw-r--r-- 1 root root 9054592 Sep 16 04:31 vmlinuz-5.3.0-acso
lrwxrwxrwx 1 root root 26 Dec 20 11:28 vmlinuz.old -> vmlinuz-5.3.0-7625-generic

Finally, add the ACS Override Patch to your list of kernel parameter options:

$ sudo kernelstub --add-options "pcie_acs_override=downstream"

Reboot and verify that the IOMMU groups for your graphics cards are different:

...
IOMMU Group 30 0c:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Navi
10 [Radeon RX 5600 OEM/5600 XT / 5700/5700 XT] [1002:731f] (rev c4)
IOMMU Group 31 0c:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Navi 10 HDMI Audio [1002:ab38]
IOMMU Group 32 0d:00.0 VGA compatible controller [0300]: NVIDIA Corporation Device [10de:2206] (rev a1)
IOMMU Group 32 0d:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:1aef] (rev a1)
...
