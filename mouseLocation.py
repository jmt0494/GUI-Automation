from pynput import mouse

def on_click(x, y, button, pressed):
    if button == mouse.Button.right and pressed:
        print("{} {}".format(x, y))
        # Stop the listener after the first click
        listener.stop()

# Create the listener without starting it immediately
listener = mouse.Listener(on_click=on_click)
# Start the listener
listener.start()
# Wait for the listener to finish (which happens after the first click)
listener.join()