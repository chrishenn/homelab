# windows_vm

windows VMs running on qemu/kvm on a linux host
build an image using packer

---

probably do this
https://github.com/Baune8D/packer-windows-desktop/tree/main

# this is where the hooks are called by the hook helper

# Before a VM is started, before resources are allocated:

/etc/libvirt/hooks/qemu.d/$vmname/prepare/begin/\*

# Before a VM is started, after resources are allocated:

/etc/libvirt/hooks/qemu.d/$vmname/start/begin/\*

# After a VM has started up:

/etc/libvirt/hooks/qemu.d/$vmname/started/begin/\*

# After a VM has shut down, before releasing its resources:

/etc/libvirt/hooks/qemu.d/$vmname/stopped/end/\*

# After a VM has shut down, after resources are released:

/etc/libvirt/hooks/qemu.d/$vmname/release/end/\*
