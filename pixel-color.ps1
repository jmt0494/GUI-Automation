# this class simulates mouse clicks
$cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class Clicker
{
    [DllImport("gdi32.dll")]
   static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
   public enum DeviceCap {
       VERTRES = 10,
       DESKTOPVERTRES = 117
   }
   public static float scaling() {
       Graphics g = Graphics.FromHwnd(IntPtr.Zero);
       IntPtr desktop = g.GetHdc();
       int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
       int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);
       return (float)PhysicalScreenHeight / (float)LogicalScreenHeight;
   }
}
'@

Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$scaleFactor = [Clicker]::scaling()
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$adjustedWidth = [int][Math]::Round($screen.Bounds.Width * $scaleFactor)
$AdjustedHeight = [int][Math]::Round($screen.Bounds.Height * $scaleFactor)

#returns a bitmap of the current screen
function Get-ScreenBitmap {
    $bitmap = (New-Object System.Drawing.Bitmap $adjustedWidth, $AdjustedHeight)
    $rectangle = New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $adjustedWidth, $AdjustedHeight
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rectangle.X, $rectangle.Y, 0, 0, $rectangle.Size)
    return $bitmap
}

#returns a target pixel RGB from a bitmap. 
#by default it will use Get-ScreenBitmap for the bitmap, but a bitmap can be provided as well.
#this will help with perfomance if you need to iteroate over multiple pixels
function Get-ColorAtPixel {
    param (
        [int]$x,
        [int]$y,
        [System.Drawing.Bitmap] $bitmap = [System.Drawing.Bitmap](Get-ScreenBitmap)
    )
    #this is to debug the pixel is that is being targeted
    <#
    $red = [System.Drawing.Color]::Red
    $bitmap.SetPixel($x-2, $y-2, $red)
    $bitmap.SetPixel($x-2, $y-1, $red)
    $bitmap.SetPixel($x-2, $y, $red)
    $bitmap.SetPixel($x-2, $y+1, $red)
    $bitmap.SetPixel($x-2, $y+2, $red)
    $bitmap.SetPixel($x-1, $y-2, $red)
    $bitmap.SetPixel($x-1, $y-1, $red)
    $bitmap.SetPixel($x-1, $y, $red)
    $bitmap.SetPixel($x-1, $y+1, $red)
    $bitmap.SetPixel($x-1, $y+2, $red)
    $bitmap.SetPixel($x, $y-2, $red)
    $bitmap.SetPixel($x, $y-1, $red)
    $bitmap.SetPixel($x, $y+1, $red)
    $bitmap.SetPixel($x, $y+2, $red)
    $bitmap.SetPixel($x+1, $y-2, $red)
    $bitmap.SetPixel($x+1, $y-1, $red)
    $bitmap.SetPixel($x+1, $y, $red)
    $bitmap.SetPixel($x+1, $y+1, $red)
    $bitmap.SetPixel($x+1, $y+2, $red)
    $bitmap.SetPixel($x+2, $y-2, $red)
    $bitmap.SetPixel($x+2, $y-1, $red)
    $bitmap.SetPixel($x+2, $y, $red)
    $bitmap.SetPixel($x+2, $y+1, $red)
    $bitmap.SetPixel($x+2, $y+2, $red)
    $bitMap.save("./bitmap.png")
    #>

    $color = $bitmap.GetPixel($x, $y)
    $color.Name
}

# put main script logic here
function Main {
    $location = python .\mouseLocation.py
    $coordinates = $location -split ' '
    $x = [int]$coordinates[0]
    $y = [int]$coordinates[1]

    Write-Host "$x $y"
    Write-Host $(Get-ColorAtPixel $x $y)

}

while ($true){
    Main
}