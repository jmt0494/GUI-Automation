#region BoilerPlate
<#
Windows Machine often scale the display up on higher resolutions, to make the screen easier to see.
The actual resolution of the screen, for example a 4k monitor will usually run 3840 X 2160, is refered to as the physical resolution.
The processor works off the scaled resolution, for example a 3840 X 2160 with a 150% scaling will be treated as 2560 X 1440, this is refered to as the logical resolution.
Because the physical and logical resolution often are not the same, it is nessesary to adjust for the scaling when working with powershells native functions.
In order to make the script capture the whole screen in its bitmaps we need to account for this scaled.
We also need to account for the scaling in the clicker class to make everything match the physical resolution of the screen
#>


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

        float scale = scaling();

        // Move the mouse
        INPUT[] input = new INPUT[3];

        input[0].mi.dx = x * (int)(65535 / (System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width * scale));
        input[0].mi.dy = y * (int)(65535 / (System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height * scale));
        input[0].mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;

        // Left mouse button down
        input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;

        // Left mouse button up
        input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;

        SendInput(3, input, Marshal.SizeOf(input[0]));
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


class Pixel {
    [int] $X
    [int] $Y
    [String] $Color

    Pixel([hashtable]$Properties) {$this.Init($Properties)}

    [void] Init([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }
}


#returns a bitmap of the current screen
function Get-ScreenBitmap {
    $bitmap = (New-Object System.Drawing.Bitmap $adjustedWidth, $AdjustedHeight)
    $rectangle = New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $adjustedWidth, $AdjustedHeight
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rectangle.X, $rectangle.Y, 0, 0, $rectangle.Size)
    return $bitmap
}


#returns a target pixel RGB from a bitmap. 
#By default it will use Get-ScreenBitmap for the bitmap, but a bitmap can be provided as well.
#this will help with perfomance if you need to iteroate over multiple pixels
function Get-ColorAtPixel {
    param (
        [Pixel] $pixel,
        [System.Drawing.Bitmap] $bitmap = [System.Drawing.Bitmap](Get-ScreenBitmap)
    )
    #this is to debug the pixel is that is being targeted
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
    $bitMap.save("./bitmap.png")

    $color = $bitmap.GetPixel($pixel.X, $pixel.Y)
    $color.Name
}


#Stops the script until the target pixel RGB value matches the provided RGB value
#useful for waiting for network requests and page loading times.
#Much better than using Start-Sleep and hoping you gave it enough time for the page to load.
function Wait-PixelColor {
    param(
        [Pixel] $Pixel
    )

    $targetPixel = Get-ColorAtPixel -x $Pixel.X -y $Pixel.Y

    while($targetPixel -ne $Pixel.Color) {
        Start-Sleep -Milliseconds 500
        $targetPixel = Get-ColorAtPixel -x $Pixel.X -y $Pixel.Y
    }
}


#Clicks at the specified coordinates. I think it is just cleaner to write the function name than calling the clicker class
function Click {
    param([Pixel]$pixel)
    #because of the way mouse locations are calculated, the mouse drifts the farther you go from the origin. These hard coded values correct that drift.
    [Clicker]::LeftClickAtPoint($pixel.X + ($pixel.X * 0.00390625),$pixel.Y + ($pixel.Y * 0.01111111111))
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

#endregion

#Add custome functions here

#used to find the location and color of a pixel
function Test-CooridinatesAndColor {
    $xval = 800
    $yval = 800
    $color = Get-ColorAtPixel -x $xval -y $yval
    Write-Host $color
    Click $xval $yval
}

# put main script logic here
function Main {
    
}

# Main

Test-CooridinatesAndColor

