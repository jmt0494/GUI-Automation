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