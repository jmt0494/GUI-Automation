using module .\modules\pixel\pixel.psm1
param($debug = $false)
. .\modules\GUIAuthomation-Imports\GUIAutomation-Imports.ps1

#Add custome functions here


# put main script logic here
function Main {
    $pixel = [Pixel]::new(@{X=100; Y=100; Color="ffffffff"})
    $pic = Get-ScreenClip -startPixel $pixel -width 1000 -height 1000
    $dirPath = "C:\Documents\scripts\Temp\Pics"
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath
    }
    $pic.save("$dirPath\test.png")
}

Main
