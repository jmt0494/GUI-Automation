using module .\modules\pixel\pixel.psm1
param($debug = $false)
. .\modules\GUIAuthomation-Imports\GUIAutomation-Imports.ps1

#Add custome functions here


# put main script logic here
function Main {
    $pixel = [Pixel]::new(@{X=100; Y=100; Color="ffffffff"})
    Find-Pixel -startPixel $pixel -xBound 100 -yBound 100 -incriment 10
}

Main
