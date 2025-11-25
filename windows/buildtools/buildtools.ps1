## pretty sure this does NOT work
# vs buildtools pwsh

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$cli = [System.Net.WebClient]::new()
$tmp = "C:\TEMP"
if (!(Test-Path $tmp)) {
    [void](mkdir $tmp)
}

$bt_exe = Join-Path $tmp "vs_buildtools.exe"
$bt_exe_url = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
$cli.DownloadFile($bt_exe_url, $bt_exe)

# paths
$bt_cache = "C:\bt_cache"
$bt_shared = "C:\bt_shared"
$bt_inst = "C:\bt"

# populate the cache with "layout" command
& $bt_exe `
    --quiet --wait --norestart `
    --layout $bt_cache `
    --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended `
    --add "Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools" `
    --add "Microsoft.VisualStudio.Workload.MSBuildTools" `
    --add "Microsoft.VisualStudio.Workload.UniversalBuildTools" `
    --add "Microsoft.VisualStudio.Component.VC.ATLMFC"

# install buildtools from cache with no downloads
& $bt_exe `
    --quiet --wait --norestart --noweb `
    --path install=$bt_inst `
    --path cache=$bt_cache `
    --path shared=$bt_shared `
    --add "Microsoft.VisualStudio.Workload.VCTools" --includeRecommended `
    --add "Microsoft.VisualStudio.Workload.ManagedDesktopBuildTools" `
    --add "Microsoft.VisualStudio.Workload.MSBuildTools" `
    --add "Microsoft.VisualStudio.Workload.UniversalBuildTools" `
    --add "Microsoft.VisualStudio.Component.VC.ATLMFC"

## cleanup
rm -r "$tmp"
