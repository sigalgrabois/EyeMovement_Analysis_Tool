# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import pyedflib
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import PhotoImage
from tkinter import *
from PIL import Image, ImageTk


def close(ws):
    ws.destroy()


def resize_func(canvas, image, width, height):
    resize_img = image.resize((width, width))
    img = ImageTk.PhotoImage(resize_img)
    canvas.config(image=img)
    canvas.image = img


def show_image(df):
    # make a list out of the 3th column in the data frame - start x of the eye movement
    # Extract the desired columns
    # save the values from the 3th column in a list not with loc
    start_x = df['x start (pixels)'].values.tolist()
    start_y = df['y start (pixels)'].values.tolist()
    end_x = df['x end (pixels)'].values.tolist()
    end_y = df['y end (pixels)'].values.tolist()

    start_diffx = df['x start (pixels)'].values.tolist()
    start_diffy = df['y start (pixels)'].values.tolist()
    end_diffx = df['x end (pixels)'].values.tolist()
    end_diffy = df['y end (pixels)'].values.tolist()

    root = tk.Tk()
    root.title("eyes movement")


    # open the image file and convert it to a PhotoImage object
    image = PhotoImage(file="data/image.png").zoom(7)
    image_width, image_height = image.width(), image.height()
    # create a canvas to hold the image
    canvas = tk.Canvas(root, width=1500, height=1100)
    canvas_width, canvas_height = canvas.winfo_width(), canvas.winfo_height()


    canvas.pack()

    # display the image on the canvas
    canvas.create_image(0, 0, anchor='nw', image=image)
    # make a zip of the two lists - start x and start y
    start = list(zip(start_x, start_y))
    end = list(zip(end_x, end_y))
    # draw the points on the image
    for i in range(len(start)):
        x1, y1 = start[i]
        x2, y2 = end[i]
        canvas.create_oval(x1, y1, x2, y2, fill='red', outline='red')

    # button = tk.Button(root,
    #                    text='EXIT PROGRAM',
    #                    font=("Times", 14),
    #                    command=lambda: close(root)
    #                    )
    # button.pack(pady=100)
    root.mainloop()


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # connect to Matlab and run the script that will create csv file of the data
    # open the csv file and read it into a pandas data frame
    df = pd.read_csv('data/Data.csv', header=0, delimiter=",")
    show_image(df)
