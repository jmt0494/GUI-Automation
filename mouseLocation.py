# credit to https://www.youtube.com/watch?v=-7cFtMnseLI

import subprocess
from pynput import mouse

def on_click(x, y, button, pressed):
    if button == mouse.Button.left and pressed:
        print("Mouse clicked at: {}".format((x, y)))
        result = subprocess.run([r"powershell.exe", r".\pixel-color.ps1 -xcoord {} -ycoord {}".format(x, y)], capture_output=True, text=True)
        print(result.stdout)

with mouse.Listener(on_click=on_click) as listener:
    listener.join()
