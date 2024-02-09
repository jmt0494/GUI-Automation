using module ..\pixel\pixel.psm1
#returns a target pixel RGB from a bitmap. 
#By default it will use Get-ScreenBitmap for the bitmap, but a bitmap can be provided as well.
#this will help with perfomance if you need to iteroate over multiple pixels
function Get-ColorAtPixel {
    param (
        [Pixel] $pixel,
        [System.Drawing.Bitmap] $bitmap = [System.Drawing.Bitmap](Get-ScreenBitmap),
        [bool] $debug = $false
    )
    #this is to debug the pixel is that is being targeted
    if ($debug -eq $true) {
        $red = [System.Drawing.Color]::Red
        $bitmap.SetPixel($pixel.X-2, $pixel.Y-2, $red)
        $bitmap.SetPixel($pixel.X-2, $pixel.Y-1, $red)
        $bitmap.SetPixel($pixel.X-2, $pixel.Y, $red)
        $bitmap.SetPixel($pixel.X-2, $pixel.Y+1, $red)
        $bitmap.SetPixel($pixel.X-2, $pixel.Y+2, $red)
        $bitmap.SetPixel($pixel.X-1, $pixel.Y-2, $red)
        $bitmap.SetPixel($pixel.X-1, $pixel.Y-1, $red)
        $bitmap.SetPixel($pixel.X-1, $pixel.Y, $red)
        $bitmap.SetPixel($pixel.X-1, $pixel.Y+1, $red)
        $bitmap.SetPixel($pixel.X-1, $pixel.Y+2, $red)
        $bitmap.SetPixel($pixel.X, $pixel.Y-2, $red)
        $bitmap.SetPixel($pixel.X, $pixel.Y-1, $red)
        $bitmap.SetPixel($pixel.X, $pixel.Y+1, $red)
        $bitmap.SetPixel($pixel.X, $pixel.Y+2, $red)
        $bitmap.SetPixel($pixel.X+1, $pixel.Y-2, $red)
        $bitmap.SetPixel($pixel.X+1, $pixel.Y-1, $red)
        $bitmap.SetPixel($pixel.X+1, $pixel.Y, $red)
        $bitmap.SetPixel($pixel.X+1, $pixel.Y+1, $red)
        $bitmap.SetPixel($pixel.X+1, $pixel.Y+2, $red)
        $bitmap.SetPixel($pixel.X+2, $pixel.Y-2, $red)
        $bitmap.SetPixel($pixel.X+2, $pixel.Y-1, $red)
        $bitmap.SetPixel($pixel.X+2, $pixel.Y, $red)
        $bitmap.SetPixel($pixel.X+2, $pixel.Y+1, $red)
        $bitmap.SetPixel($pixel.X+2, $pixel.Y+2, $red)
        $bitMap.save("C:\Users\John of the Cross\Desktop\scripts\GUI-Automation\bitmap.png")
    }
    $color = $bitmap.GetPixel($pixel.X, $pixel.Y)
    $color.Name
}