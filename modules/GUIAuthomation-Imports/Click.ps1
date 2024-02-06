using module ..\pixel\pixel.psm1
#Clicks at the specified coordinates. I think it is just cleaner to write the function name than calling the clicker class
function Click {
    param([Pixel]$pixel)
    #because of the way mouse locations are calculated, the mouse drifts the farther you go from the origin. These hard coded values correct that drift.
    [Clicker]::LeftClickAtPoint($pixel.X + ($pixel.X * 0.00390625),$pixel.Y + ($pixel.Y * 0.01111111111))
}