
. .\modules\GUIAuthomation-Imports\GUIAutomation-Imports.ps1

#Add custome functions here


# put main script logic here
function Main {
    $pixel = [Pixel]::new(@{X=100; Y=100; Color=""})
    $pixelColor = Get-ColorAtPixel $pixel
    $pixelColor
}

Main
