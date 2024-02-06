#returns a bitmap of the current screen
function Get-ScreenBitmap {
    $bitmap = (New-Object System.Drawing.Bitmap $adjustedWidth, $AdjustedHeight)
    $rectangle = New-Object -TypeName System.Drawing.Rectangle -ArgumentList 0, 0, $adjustedWidth, $AdjustedHeight
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($rectangle.X, $rectangle.Y, 0, 0, $rectangle.Size)
    return $bitmap
}