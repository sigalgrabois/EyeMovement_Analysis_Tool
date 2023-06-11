import time
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import PhotoImage
from tkinter import *
from PIL import Image, ImageTk, ImageGrab
import subprocess

from PIL.ImageDraw import ImageDraw

from PicsData import load_data_pics, Picture
import openpyxl
from openpyxl import Workbook
import os


# TODO:
# 2. create the trajectory of the eyes movement
# 3. divide the trajectory into trails by different colors. each trail will be a different color


def close(ws):
    ws.destroy()


def resize_func(canvas, image, width, height):
    resize_img = image.resize((width, width))
    img = ImageTk.PhotoImage(resize_img)
    canvas.config(image=img)
    canvas.image = img


def save_data(df):
    print("save data")
    df.to_excel("eyes_movement.xlsx", sheet_name='eyes_movement', index=False)


def save_image(canvas):
    # take the image from the canvas with all that is on it
    # and export it to a png file
    canvas.postscript(file="eyes_movement.ps", colormode='color')
    img = Image.open("eyes_movement.ps")
    img.save("eyes_movement.png", "png")


def create_heatmap(df, image_path, width, height):
    pass


def show_image(df, image_path, width, height, trail_num):
    print("show image")
    trails_num = trail_num
    trail_colors = {}
    for i in range(1, trails_num + 1):
        trail_colors[i] = "#%06x" % np.random.randint(0, 0xFFFFFF)
    print(trail_colors)
    # make a list out of the 3th column in the data frame - start x of the eye movement
    # Extract the desired columns
    # save the values from the 3th column in a list not with loc
    start_x = df['x start (pixels)'].values.tolist()
    start_y = df['y start (pixels)'].values.tolist()
    end_x = df['x end (pixels)'].values.tolist()
    end_y = df['y end (pixels)'].values.tolist()

    root = tk.Tk()
    root.title("eyes movement")
    root.geometry("900x900")
    root.anchor(CENTER)

    # add a button to save the image with the trails on it
    button = tk.Button(root, text="Save Image", command=lambda: save_image(canvas))
    button.pack(side="top", fill="both", expand="yes", padx="10", pady="10")
    # add a button to create a heatmap of the trails on the image
    button = tk.Button(root, text="Create Heatmap", command=lambda: create_heatmap(df, image_path, width, height))
    button.pack(side="top", fill="both", expand="yes", padx="10", pady="10")
    image_path = image_path.replace("'", "")
    img_dir = "./ImagesAllSize900x900"
    image = Image.open(img_dir + "/" + image_path)

    # Convert the string to a raw string
    # image = Image.open(image_path)
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
    width = width.replace("'", "")
    height = height.replace("'", "")
    x_axis_padding = float(original_image_width) / 2 - float(width) / 2
    y_axis_padding = float(original_image_height) / 2 - float(height) / 2

    # Draw circles and lines between them
    for i in range(len(start)):
        x1, y1 = start[i]
        x2, y2 = end[i]
        x1, y1 = x1 - x_axis_padding, y1 - y_axis_padding
        x2, y2 = x2 - x_axis_padding, y2 - y_axis_padding
        print("x1, y1: ")
        print(x1, y1)
        print("x2, y2: ")
        print(x2, y2)

        # Draw circle
        trail_number = trails_num
        color = trail_colors[trail_number]
        canvas.create_oval(x1, y1, x2, y2, fill=color, width=4, outline=color, tags="dot", activefill=color)

        # Draw line to previous point
        prev_x, prev_y = start[i - 1]
        prev_x, prev_y = prev_x - x_axis_padding, prev_y - y_axis_padding
        trail_number = trail_number
        color = trail_colors[trail_number]
        canvas.create_line(prev_x, prev_y, x1, y1, width=5, fill=color)

        canvas.create_text(((x1 + prev_x) / 2) + 4, ((y1 + prev_y) / 2) - 4,
                           text=str(int(trail_number)) + " , " + str(i),
                           fill="yellow", font="Arial 10 bold")

    root.mainloop()


def run_matlab_script(matlab_app):
    # run the matlab
    print("matlab script has been run")
    # run the ExtractDataEDF.exe file that will create the csv file
    subprocess.call(matlab_app)


def choose_pic(images):
    user_choice_pic = input("Please choose a picture by the imageID or the image name: ")

    for image in images:
        if image.image_id == int(user_choice_pic) or image.image_name == user_choice_pic:
            print("You chose image: " + image.image_name)
            image_size = image.image_size.replace("'", "")
            image_name = image.image_name.replace("'", "")

            print("Image size: " + str(image_size) + " pixels")
            print("Image name: " + str(image_name))
            return str(image_name), image_size, image.image_size, image.image_id, image.image_category_id

    # If the loop completes without returning a value, the choice was not found
    print("Image not found. Please make sure to enter a valid image ID or image name.")
    return None, None, None


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # # connect to Matlab and run the script that will create csv file of the data
    # # open the csv file and read it into a pandas data frame
    # matlab_app = "ExtractDataEDFv_2_1.exe"
    # run_matlab_script(matlab_app)
    # # wait for the csv file to be created - 15 seconds should be enough
    # time.sleep(7)

    df = pd.read_csv('Data.csv', header=0, delimiter=",")
    # change the header of the data frame to the desired names - ['', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)', 'y end (pixels)', 'start diff (start trail- start event)','end diff (end trail- send event)'
    # ,'duration of fixation', 'amplitude in pixels', 'amplitude in degrees', 'write peak', 'velocity deg/s', 'write average velocity deg/s', 'trail number']
    df.columns = ['image_index num', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)',
                  'y end (pixels)',
                  'start diff (start trail- start event)', 'end diff (end trail- send event)', 'duration of fixation',
                  '', 'amplitude in pixels', 'amplitude in degrees', 'write peak velocity deg/s',
                  'write average velocity deg/s', '', 'size', 'category', 'trail number']
    # use the load pictures to load a list of all the images in the folder
    path = input("please enter the path of the images data set: ")
    images = load_data_pics(path)
    image_name, width, height, image_id, image_category_id = choose_pic(images)
    chosen_image = Picture(image_name, width, height, image_id, image_category_id)
    image_idx = chosen_image.image_id
    # in df search for the image index and from the line of the index bring me the trail number
    # Search for the image index in the DataFrame
    matching_row = df[df['image_index num'] == image_idx]
    print(matching_row)
    trail_number = matching_row.loc[:, 'trail number'].values[0].T

    # Check if a matching row is found
    if not matching_row.empty:
        # Retrieve the trail number from a different column in the matching row
        print(f"The trail number for image index {image_idx} is: {trail_number}")
    else:
        print(f"No trail number found for image index {image_idx}")

    show_image(matching_row, image_name, width, height, trail_number)
    # add to Data.csv the headers from the df
    df.to_csv('Data.csv', header=True, index=False)