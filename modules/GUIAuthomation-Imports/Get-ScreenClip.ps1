using module ..\pixel\pixel.psm1

function Get-ScreenClip {
    param(
        [System.Drawing.Bitmap] $bitmap = [System.Drawing.Bitmap](Get-ScreenBitmap),
        [Pixel] $startingPixel = [Pixel]::new(@{X=0; Y=0; Color=""}),
        [int] $width = 100,
        [int] $height = 100,
        [bool] $debug = $false,
        [string] $path = "Screen-Shot",
        [string] $filename = "ScreenClip"
    )

    $clip = (New-Object System.Drawing.Bitmap $width, $height)

    for ($i = 0; $i -lt $height; $i++) {
        for ($j = 0; $j -lt $width; $j++) {
            $currentPixel = $bitmap.getPixel($startingPixel.X+$j, $startingPixel.Y+$i)
            $clip.SetPixel($j, $i, $currentPixel)
        }
    }

    if ($debug -eq $true) {
        $dirPath = "c:\Documents\scripts\debug\$($path)"
        if(-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath
        }
        $clip.save("dirPath\$($filename).bmp")
    }

    return $clip
}