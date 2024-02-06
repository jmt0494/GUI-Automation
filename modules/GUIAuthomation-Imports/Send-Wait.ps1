#Stops the script until the target pixel RGB value matches the provided RGB value
#useful for waiting for network requests and page loading times.
#Much better than using Start-Sleep and hoping you gave it enough time for the page to load.
function Wait-PixelColor {
    param(
        [Pixel] $pixel
    )

    $targetColor = Get-ColorAtPixel -pixel $pixel

    while($targetColor -ne $pixel.Color) {
        Start-Sleep -Milliseconds 500
        $targetColor = Get-ColorAtPixel -pixel $pixel
    }
}