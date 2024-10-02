using module ..\pixel\pixel.psm1
#loops through a definded regin of the screen to find the location of a particular pixel color.
#use when the pixel you are looking for in not always in the same exact spot of the screen.
function Find-Pixel {
    param(
        [Pixel] $startPixel, # the top left cornor of the area to be searched, and the color of the pixel we are looking for
        [String] $failureMessage = "something went wrong",
        [System.Drawing.Bitmap] $screenShot = [System.Drawing.Bitmap](Get-ScreenBitMap),
        [int] $xBound = $screenShot.Width, #width of the area to search
        [int] $yBound = $screenShot.Height, #height of the area to search
        [int] $incriment = 100, #distance between each pixel that gets checked, the smaller the number the slower the execution, but the higher accuracy
        [boolean] $debug = $false
    )
    $pixel = [Pixel]::new(@{X=0; Y=0; Color=""})
    $yBound += $startPixel.Y
    $xBound += $startPixel.X

    for ($i = $startPixel.Y; $i -lt $xBound; $i += $incriment) {
        for ($j = $startPixel.X; $j -lt $xBound; $j += $incriment) {
            $pixel = [Pixel]::new(@{X=$j; Y=$i; Color=""})
            $nextPixel = Get-ColorAtPixel -pixel $pixel -bitmap $screenShot -debug $debug
            if ($nextPixel -eq $startPixel.Color) {
                return $pixel
            }
        }
    }
    Write-Host "X: $($pixel.X) Y: $($pixel.Y) $(Get-ColorAtPixel -pixel $pixel -bitmap $screenShot -debug $true -path $path -filename 
    $filename)"
    Write-warning $failureMessage
    return $false
}