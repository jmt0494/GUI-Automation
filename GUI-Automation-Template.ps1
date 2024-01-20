<#
Windows Machine often scale the display up on higher resolutions, to make the screen easier to see.
The actual resolution of the screen, for example a 4k monitor will usually run 3840 X 2160, is refered to as the physical resolution.
The processor works off the scaled resolution, for example a 3840 X 2160 with a 150% scaling will be treated as 2560 X 1440, this is refered to as the logical resolution.
Because the physical and logical resolution often are not the same, it is nessesary to adjust for the scaling when working with powershells native functions.
In order to make the script capture the whole screen in its bitmaps I have had to adjust the size it is capturing.
As a result I have adjusted all other function to work off of the logical resolution.
This way the coordinates of the clicker class will match with the coordinates of other functions on the screen.
It may have been possible to adjust the Clicker class to match the physical resolution instead, but I didn't.
This works well enough for me, so just know that if your resolution is scaled up it you may be moving more than one pixel for each coordinate value you adjust.
#>

# this class simulates mouse clicks
$cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class Clicker
{
    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-input
    [StructLayout(LayoutKind.Sequential)]
    struct INPUT
    { 
        public int        type; // 0 = INPUT_MOUSE
                                // 1 = INPUT_KEYBOARD
                                // 2 = INPUT_HARDWARE
        public MOUSEINPUT mi;
    }

    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/ns-winuser-mouseinput
    [StructLayout(LayoutKind.Sequential)]
    struct MOUSEINPUT
    {
        public int    dx;
        public int    dy;
        public int    mouseData;
        public int    dwFlags;
        public int    time;
        public IntPtr dwExtraInfo;
    }

    // This covers most use cases although complex mice may have additional buttons.
    // There are additional constants you can use for those cases, see the MSDN page.
    const int MOUSEEVENTF_MOVE       = 0x0001;
    const int MOUSEEVENTF_LEFTDOWN   = 0x0002;
    const int MOUSEEVENTF_LEFTUP     = 0x0004;
    const int MOUSEEVENTF_RIGHTDOWN  = 0x0008;
    const int MOUSEEVENTF_RIGHTUP    = 0x0010;
    const int MOUSEEVENTF_MIDDLEDOWN = 0x0020;
    const int MOUSEEVENTF_MIDDLEUP   = 0x0040;
    const int MOUSEEVENTF_WHEEL      = 0x0080;
    const int MOUSEEVENTF_XDOWN      = 0x0100;
    const int MOUSEEVENTF_XUP        = 0x0200;
    const int MOUSEEVENTF_ABSOLUTE   = 0x8000;

    const int screen_length = 0x10000;

    // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-sendinput
    [System.Runtime.InteropServices.DllImport("user32.dll")]
    extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

    public static void LeftClickAtPoint(int x, int y)
    {
        // Move the mouse
        INPUT[] input = new INPUT[3];

        input[0].mi.dx = x * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
        input[0].mi.dy = y * (65535 / System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
        input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;

        // Left mouse button down
        input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;

        // Left mouse button up
        input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;

        SendInput(3, input, Marshal.SizeOf(input[0]));
    }
}
'@

#this class finds the scaling factor, required to make screen grabs and pixel coordinate match the mouse coordinates
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;

public class DPI {
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
"@ -ReferencedAssemblies 'System.Drawing.dll' -ErrorAction Stop

Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$scaleFactor = [DPI]::scaling()
$screen = [System.Windows.Forms.Screen]::PrimaryScreen
$adjustedWidth = [int][Math]::Round($screen.Bounds.Width * $scaleFactor)
$AdjustedHeight = [int][Math]::Round($screen.Bounds.Height * $scaleFactor)

#returns a bitmap of the current screen
function Get-ScreenBitmap {
    $bitmap = (New-Object System.Drawing.Bitmap $adjustedWidth, $AdjustedHeight)
    return $bitmap
}

#adjusts an x coordinate for resolution scaling
function Get-AdjustedX {
    param ($x)

    $adjustedX = [int]($x * ($scaleFactor-($adjustedWidth / 100000)))
    return $adjustedX
}

##adjusts an y coordinate for resolution scaling
function Get-AdjustedY {
    param($y)
    $adjustedY = [int]($y * ($scaleFactor-($AdjustedHeight / 100000)))
    return $adjustedY
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

    $rectangle = New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $adjustedWidth, $AdjustedHeight

    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rectangle.X, $rectangle.Y, 0, 0, $rectangle.Size)


    $adjustedX = Get-AdjustedX
    $adjustedY = Get-AdjustedY

    <# #this is to debug the pixel is that is being targeted
    $red = [System.Drawing.Color]::Red
    $bitmap.SetPixel($adjustedX-1, $adjustedY-1, $red)
    $bitmap.SetPixel($adjustedX-1, $adjustedY, $red)
    $bitmap.SetPixel($adjustedX-1, $adjustedY+1, $red)
    $bitmap.SetPixel($adjustedX, $adjustedY-1, $red)
    $bitmap.SetPixel($adjustedX, $adjustedY, $red)
    $bitmap.SetPixel($adjustedX, $adjustedY+1, $red)
    $bitmap.SetPixel($adjustedX+1, $adjustedY-1, $red)
    $bitmap.SetPixel($adjustedX+1, $adjustedY, $red)
    $bitmap.SetPixel($adjustedX+1, $adjustedY+1, $red)
    $bitMap.save("C:\Users\John of the Cross\Desktop\bitmap.png")
    #>

    $color = $bitmap.GetPixel($adjustedX, $adjustedY)
    $color
}

#Stops the script until the target pixel RGB value matches the provided RGB value
#useful for waiting for network requests and page loading times.
#Much better than using Start-Sleep and hoping you gave it enough time for the page to load.
function Wait-PixelColor {
    param(
        $x,
        $y,
        $r,
        $g,
        $b
    )

    $pixel = Get-ColorAtPixel -x $x -y $y

    while(($pixel.R -ne $r) -and ($pixel.G -ne $g) -and ($pixel.B -ne $b)) {
        Start-Sleep -Milliseconds 500
        $pixel = Get-ColorAtPixel -x $x -y $y
    }
}

#Clicks at the specified coordinates. I think it is just cleaner to write the function name than calling the clicker class
function Click {
    param($x, $y)
    [Clicker]::LeftClickAtPoint($x,$y)
}

#Simulates keyboard presses. Can execute any hotkeys as well as type text. 
#For a list of spcial keys see https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys?view=windowsdesktop-8.0&redirectedfrom=MSDN
function Send-Wait {
    param($keys)
    [System.Windows.Forms.SendKeys]::SendWait($keys)
}

#pastes provided text into the focus. Faster than usings Send-Wait
function Enter-Text {
    param($text)

    Set-Clipboard -Value $text

    Send-Wait "^v"
}

#presses tab as many times as needed. Used to navigate elements of a page
function Tab {
    param($numOfTabs)

    for($i=0; $i -lt $numOfTabs; $i++) {
        Send-Wait "{TAB}"
    }
}

#Add custome functions here

#used to find the location and color of a pixel
function Test-CooridinatesAndColor {
    $xval = 100
    $yval = 100
    Write-Host $(Get-ColorAtPixel -x $xval -y $yval)
    Click $xval $yval
}

# put main script logic here
function Main {
    
}

# Main

Test-CooridinatesAndColor