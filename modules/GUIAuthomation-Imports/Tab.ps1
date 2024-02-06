#presses tab as many times as needed. Used to navigate elements of a page
function Tab {
    param($numOfTabs)

    for($i=0; $i -lt $numOfTabs; $i++) {
        Send-Wait "{TAB}"
    }
}
