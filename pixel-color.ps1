#Imports
using module .\modules\pixel\pixel.psm1
. .\modules\GUIAuthomation-Imports\Core.ps1
. .\modules\GUIAuthomation-Imports\Get-ScreenBitMap.ps1
. .\modules\GUIAuthomation-Imports\Get-ColorAtPixel.ps1


# This script listens for left clicks and returns the coordinates and color of the pixel clicked on
function Main {
    $location = python .\mouseLocation.py
    $coordinates = $location -split ' '
    $x = [int]$coordinates[0]
    $y = [int]$coordinates[1]

    Write-Host "$x $y"
    $pixel = [Pixel]::new(@{ X=$x; Y=$y; Color="" })
    Write-Host $( Get-ColorAtPixel -pixel $pixel )

}

while ($true){
    Main
}