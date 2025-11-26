function sdo ([string] $cmd, $print = $False) {
    write-host $cmd
    if ($print) {
        Invoke-Expression $cmd
    } else {
        [void](Invoke-Expression $cmd)
    }
}

function rm_svc ([string] $svcname, $print = $False) {
    sdo "& sc.exe stop $svcname" $print
    sdo "& sc.exe delete $svcname" $print
    sdo "& sc.exe query $svcname" $print
}

function rm_takeown ([string] $dir) {
    if (Test-Path $dir) {
        sdo "takeown.exe /F '$dir' /R /A /D Y"
        sdo "icacls.exe     '$dir' /T /C /grant Administrators:F"
        sdo "Remove-Item    '$dir' -Recurse -Force"
    }
}

function srm ([string] $path, $print = $False) {
    sdo "rm -r -force -ea 0 '$path'" $print
}

##---------------------------------------------------

function del_cni {
    rm -r -force /etc/cni
    rm -r -force /CalicoWindows
    rm -r -force /host/etc/cni
    rm -r -force /host/opt/cni
    rm -r -force /hpc
}

function del_for_rejoin {
    rm -r -force /etc/kubernetes/kubelet.conf
    rm -r -force /etc/kubernetes/pki/ca.crt
    stop-service kubelet
}
function del_for_preparenode {
    rm -r -force C:\k\kubelet.exe
    rm -r -force C:\var\lib\kubelet\etc\kubernetes\pki
}

function del_all {
    rm_svc "kubelet"
    rm_svc "containerd"

    $tmpdir = "C:\_____tmp_____"
    mkdir -p $tmpdir
    [void](Invoke-Expression "robocopy $tmpdir $env:programdata\containerd /s /e /mir /w:0 /r:0")
    rm -r -force $env:programdata\containerd
    [void](Invoke-Expression "robocopy $tmpdir $env:programfiles\containerd /s /e /mir /w:0 /r:0")
    rm -r -force $env:programfiles\containerd
    rm -r -force $tmpdir

    srm "C:\k\"
    srm "C:\etc\"
    srm "C:\var\"
    srm "C:\opt\"
    srm "C:\dev\"
    srm "C:\hpc\"
    srm "C:\host\"
    srm "C:\cni.log"
    srm "C:\Install-Containerd.ps1"
    srm "C:\PrepareNode.ps1"
    srm "C:\*.tar.gz"
    srm "C:\ProgramData\nerdctl"
    srm "C:\Program Files\nssm"
    srm "$HOME\bin"
    srm "$HOME\bin2"
    srm "$HOME\.kube"
    srm "$HOME\.crictl"

    restart-computer -F
}

# sus? does this delete the whole computer? corrupted the pwsh install?
#function rm_robo ([string] $dir, $print = $False) {
#    $tmpdir = "C:\_____tmp_____"
#    if (Test-Path $tmpdir) {
#        write-host "error: temp dir for robo delete already exists"
#        exit
#    }
#    mkdir -p $tmpdir
#    robocopy "$tmpdir" "$dir" /s /e /mir /w:0 /r:0
#    srm $dir
#    srm $tmpdir
#}
