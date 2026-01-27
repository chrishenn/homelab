# layout works but can't get installer to use layout as cache in container. wah-wah

$wd = $PSScriptRoot
write-host "detected script location as: $wd"

write-host "downloading vs_buildtools.exe if needed"
$btexe = "$wd/bt.exe"
if (!(test-path "$btexe")) {
    irm https://aka.ms/vs/16/release/vs_buildtools.exe -o "$btexe"
}

write-host "launching buildtools layout command"
$nfo = New-Object System.Diagnostics.ProcessStartInfo
$nfo.FileName = "$btexe"
$nfo.Arguments =  `
     '--layout {0}' -f "$wd/bt_cache" `
     + ' --quiet --wait --norestart' `
     + ' --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended' `
     + ' --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools' `
     + ' --add Microsoft.VisualStudio.Workload.MSBuildTools' `
     + ' --add Microsoft.VisualStudio.Workload.UniversalBuildTools' `
     + ' --add Microsoft.VisualStudio.Component.VC.ATLMFC'
$p = [System.Diagnostics.Process]::Start($nfo)
$p.WaitForExit()

if ($p.exitcode -ne 0) {
    write-host "FAILED: vs buildtools layout failed with code: " $p.exitcode
} else {
    write-host "SUCCESS: vs buildtools layout success at $wd/bt_cache"
}
exit $p.ExitCode;
