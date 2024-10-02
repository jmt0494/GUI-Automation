using module ..\pixel\pixel.psm1

function Find-Pixel {
    param(
        [Pixel] $startPixel,
        [String] $failureMessage = "something went wrong",
        [System.Drawing.Bitmap] $screenShot = [System.Drawing.Bitmap](Get-ScreenBitMap),
        [int] $xBound = $screenShot.Width,
        [int] $yBound = $screenShot.Height,
        [int] $incriment = 100,
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