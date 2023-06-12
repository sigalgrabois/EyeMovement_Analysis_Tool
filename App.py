create a App class - to create the GUI
class App:
    # constructor method
    def __init__(self, master):
        # create a frame
        frame = Frame(master)
        # create 2 buttons
        self.button1 = Button(frame, text="QUIT", fg="red", command=frame.quit)
        self.button2 = Button(frame, text="Hello", fg="green", command=self.say_hi)
        # pack the buttons
        self.button1.pack(side=LEFT)
        self.button2.pack(side=LEFT)
        # pack the frame
        frame.pack()
create a method to print a message
    def say_hi(self):
        print("hi there, everyone!")

# create the root window
root = Tk()
# create an instance of the App class
app = App(root)
# enter the main loop
root.mainloop()

# create a gui to choose the image
root = Tk()
root.title("Choose an image")