packer {
    required_plugins {
        qemu = {
            source  = "github.com/hashicorp/qemu"
            version = "~> 1"
        }
        vagrant = {
            source  = "github.com/hashicorp/vagrant"
            version = "~> 1"
        }
    }
}

source "qemu" "servercore2022" {

    accelerator        = "kvm"

    shutdown_command   = "timeout 3 > nul & C:\\Windows\\System32\\Sysprep\\sysprep.exe /generalize /oobe /shutdown /unattend:E:\\sysprep.xml"

    cd_files           = [ "provision.ps1", "drivers" ]
    cd_content         = {
        "/sysprep.xml" = templatefile("sysprep.xml.tmpl", { hostname = "Win2022Core" })
    }

    cd_label           = "unattended"
    communicator       = "winrm"
    winrm_username     = "vagrant"
    winrm_password     = "vagrant"

    winrm_insecure     = true
    disk_interface     = "virtio-scsi"
    disk_cache         = "unsafe"
    disk_discard       = "unmap"
    disk_detect_zeroes = "unmap"
    disk_compression   = true
    format             = "qcow2"
    headless           = false
    net_device         = "virtio-net"

    qemuargs = [
        ["-cpu", "host"],
        ["-device", "pcie-root-port,port=16,chassis=1,id=pci.1,bus=pcie.0,multifunction=on,addr=0x2"],
        ["-device", "pcie-root-port,port=17,chassis=2,id=pci.2,bus=pcie.0,addr=0x2.0x1"],
        ["-device", "virtio-scsi-pci,id=scsi0,bus=pci.1,addr=0x0"],
        ["-device", "scsi-hd,bus=scsi0.0,drive=drive0"],
        ["-device", "virtio-balloon-pci,id=balloon0,bus=pcie.0,addr=0x4"],
        ["-device", "virtio-tablet-pci,id=input0,bus=pci.2,addr=0x0"],
        ["-device", "pcie-root-port,port=18,chassis=3,id=pci.3,bus=pcie.0,addr=0x2.0x2"],
    ]
}

build {
    sources = [ "sources.qemu.servercore2022", ]

    post-processors {
        post-processor "vagrant" {
            compression_level = "9"
            output            = "servercore2022.box"
            only              = [ "qemu.servercore2022", ]
        }
    }
}
