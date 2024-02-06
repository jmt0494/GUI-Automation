#pastes provided text into the focus. Faster than usings Send-Wait
function Enter-Text {
    param($text)

    Set-Clipboard -Value $text

    Send-Wait "^v"
}