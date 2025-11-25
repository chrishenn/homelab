# can't get this to work
# running the buildtools installer from powershell

write-host "launching: buildtools install"
$bt = "C:\bt"
$nfo = New-Object System.Diagnostics.ProcessStartInfo
$nfo.FileName = "C:\bt.exe"
$nfo.Arguments = `
    '--quiet --wait --norestart --nocache' `
    + ' --path install={0}' -f "$bt" `
    + ' --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended' `
    + ' --add Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools' `
    + ' --add Microsoft.VisualStudio.Workload.MSBuildTools' `
    + ' --add Microsoft.VisualStudio.Workload.UniversalBuildTools' `
    + ' --add Microsoft.VisualStudio.Component.VC.ATLMFC'
$p = [System.Diagnostics.Process]::Start($nfo)
$p.WaitForExit()
if ($p.exitcode -ne 0) {
    write-host "FAILED: vs buildtools install failed with code:" $p.exitcode
} else {
    write-host "SUCCESS: vs buildtools install success"
}
exit $p.ExitCode
