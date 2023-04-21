import time

import pyedflib
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import PhotoImage
from tkinter import *
from PIL import Image, ImageTk
import subprocess


# TODO:
# 1. subprocess to run the matlab script that will create the csv file
# 2. create the trajectory of the eyes movement
# 3. divide the trajectory into trails by different colors. each trail will be a different color


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
    root.geometry("900x900")
    image = Image.open('data/image.png')
    img = image.resize((900, 900))
    my_img = ImageTk.PhotoImage(img)
    canvas = tk.Canvas(root, width=900, height=900)
    canvas.create_image(0, 0, anchor=NW, image=my_img)
    canvas.pack()

    # make a zip of the two lists - start x and start y
    start = list(zip(start_x, start_y))
    end = list(zip(end_x, end_y))
    # draw the points on the image
    original_image_width = 1920
    original_image_height = 1080
    new_image_width = 900
    new_image_height = 900
    x_axis_padding = 510
    y_axis_padding = 90

    for i in range(len(start)):
        x1, y1 = start[i]
        x2, y2 = end[i]
        x1, y1 = x1 - x_axis_padding, y1 - y_axis_padding
        x2, y2 = x2 - x_axis_padding, y2 - y_axis_padding

        canvas.create_oval(x1, y1, x2, y2, fill="red", width=15, outline="red", tags="oval", activefill="red")
        canvas.pack()

    root.mainloop()


def run_matlab_script():
    # run the matlab
    print("matlab script has been run")
    # run the ExtractDataEDF.exe file that will create the csv file
    subprocess.call("ExtractDataEDF.exe")


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # connect to Matlab and run the script that will create csv file of the data
    # open the csv file and read it into a pandas data frame
    run_matlab_script()
    # wait for the csv file to be created - 15 seconds should be enough
    time.sleep(20)

    df = pd.read_csv('Data.csv', header=0, delimiter=",")
    # change the header of the data frame to the desired names - ['', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)', 'y end (pixels)', 'start diff (start trail- start event)','end diff (end trail- send event)'
    # ,'duration of fixation', 'amplitude in pixels', 'amplitude in degrees', 'write peak', 'velocity deg/s', 'write average velocity deg/s', 'trail number']
    df.columns = ['left eye', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)', 'y end (pixels)',
                  'start diff (start trail- start event)', 'end diff (end trail- send event)', 'duration of fixation',
                  '', 'amplitude in pixels', 'amplitude in degrees', 'write peak velocity deg/s',
                  'write average velocity deg/s', '', '', '', 'trail number']
    show_image(df)
