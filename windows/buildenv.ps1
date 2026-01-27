$repo = "$PSScriptRoot"
$ErrorActionPreference = 'Stop';
$ProgressPreference = 'SilentlyContinue';

function direxist (
    [Parameter(Mandatory = $true)][string] $dir
) {
    return Test-Path -Path "$dir" -PathType Container
}

function fexist (
    [Parameter(Mandatory = $true)][string] $file
) {
    return Test-Path -Path "$file" -PathType Leaf
}

function pause (
    $message
) {
    Write-Host "$message" -ForegroundColor Yellow
    $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function mode_build {
    if ($env:UserName -eq "ContainerAdministrator") {
        write-host "currently in a container. Will not proceed"
        exit 1
    }
    docker-compose -f containers/windows/build-native/compose.yml build win-builder
}

function mode_attach {
    if ($env:UserName -eq "ContainerAdministrator") {
        write-host "currently in a container. Will not proceed"
        exit 1
    }
    docker-compose -f containers/windows/build-native/compose.yml run -it --rm win-builder
}

function mode_compile {
    # quick check that most of the src files are here for compile - sometimes I just copy the files needed for pkg
    $src = direxist "$repo/src"
    $deps = direxist "$repo/deps"
    $windows = direxist "$repo/windows"
    $cmake = fexist "$repo/CMakeLists.txt"
    if (!($src -and $deps -and $windows -and $cmake)) {
        write-host "error: compile: required files missing from repo: src=$src deps=$deps windows=$windows cmakelists.txt=$cmake"
        exit 1
    }

    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_MAKE_PROGRAM=ninja `
        -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl `
        -DCMAKE_LINKER=lld-link -DCMAKE_RC_COMPILER_INIT=llvm-rc `
        -G Ninja -S .\ -B ./build
    cmake --build ./build --target all
}

function mode_pkg {
    # make sure built bins are in a './build' dir before proceeding to packaging
    $build_tgt = "$repo/build"
    if (!(test-path "$build_tgt/src/*.exe") -or !(test-path "$build_tgt/src/*.dll")) {
        write-host "error: msi-pkg: exes or dlls missing from build folder. call './buildenv.ps1 compile' first"
        exit 1
    }

    # wix Product.wxs looks in build/src/Release for .exe's and .dll's
    [void](mkdir -ea 0 "$build_tgt/src/Release")
    cp "$build_tgt/src/*.exe" "$build_tgt/src/Release/"
    cp "$build_tgt/src/*.dll" "$build_tgt/src/Release/"

    # cd to .\windows\installer for pkg deps installs; build msi
    Set-Location -Path "$repo\windows\installer"
    msbuild project.sln -p:Configuration=Release -p:Platform=x64 -p:RestorePackagesConfig=true -restore
    Set-Location -Path "$repo"

    # copy built installer out to project root
    $msi = "$repo\windows\installer\bin\x64\Release\installer.msi"
    if (!(Test-Path -Path $msi)) {
        write-host "error: failed to find build .msi at $msi"
        exit 1
    }
    cp "$msi" "$repo"
    write-host "`nsuccess: copied installer.msi to $repo"
}

function mode_install {
    $msi = Get-ChildItem *.msi | ForEach-Object {$_.Name}
    if (!(Test-Path "$msi" -PathType Leaf)) {
        throw 'FAILED: msi installer not found'
    }
    Write-Output "found installer msi: $msi"

    $p = Start-Process -Wait -Passthru msiexec "/i $msi /qn"
    if ($p.exitcode -ne 0) {
        throw "FAILED: msi install failed"
    }
    write-host "SUCCESS: msi installed`n"
}

switch ($args[0]) {
    "build" {
        mode_build; break
    }
    "attach" {
        mode_attach; break
    }
    "compile" {
        mode_compile; break
    }
    "pkg" {
        mode_pkg; break
    }
    "install" {
        mode_install; break
    }
    "compile_pkg" {
        mode_compile; mode_pkg; break
    }
    "compile_pkg_install" {
        mode_compile; mode_pkg; mode_install; break
    }
    default {
        write-host "skill issue. bad arg to script"
    }
}
