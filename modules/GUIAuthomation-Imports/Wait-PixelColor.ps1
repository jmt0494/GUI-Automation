#Stops the script until the target pixel RGB value matches the provided RGB value
#useful for waiting for network requests and page loading times.
#Much better than using Start-Sleep and hoping you gave it enough time for the page to load.
function Wait-PixelColor {
    param(
        [Pixel] $pixel,
        [Bool] $debug = $false,
        [int] $seconds = 10
    )

    $targetColor = Get-ColorAtPixel -pixel $pixel

    for ($i=0; ($targetColor -ne $pixel.Color) -and ($i -lt $seconds*2); $i++) {
        Start-Sleep -Milliseconds 500
        $targetColor = Get-ColorAtPixel -pixel $pixel -debug $debug
    }

    if ($targetColor -ne $pixel.Color) {return $false}
    else {return $true}
}