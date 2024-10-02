#The order of these are important
using module ..\pixel\pixel.psm1
. .\modules\GUIAuthomation-Imports\Core.ps1
. .\modules\GUIAuthomation-Imports\Click.ps1 #This requires Core.ps1
. .\modules\GUIAuthomation-Imports\Get-ScreenBitMap.ps1 #This Requires Core.ps1
. .\modules\GUIAuthomation-Imports\Get-ColorAtPixel.ps1 #this requires Core.ps1 and Get-ScreenBitMap.ps1
. .\modules\GUIAuthomation-Imports\Wait-PixelColor.ps1 #This requires Get-ColorAtPixel.ps1
. .\modules\GUIAuthomation-Imports\Find-Pixel.ps1 #This requires Gen-ScreenBitMap.ps1
. .\modules\GUIAuthomation-Imports\Send-Wait.ps1
. .\modules\GUIAuthomation-Imports\Enter-Text.ps1 #This reuqires Send-Wait
. .\modules\GUIAuthomation-Imports\Tab.ps1 #This reuqires Send-Wait