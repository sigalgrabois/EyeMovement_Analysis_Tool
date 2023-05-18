import time
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import PhotoImage
from tkinter import *
from PIL import Image, ImageTk, ImageGrab
import subprocess
from PicsData import load_data_pics
from PicsData import Picture


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


def show_image(df, image_path, width, height, trails_num):
    image_path = image_path
    trail_colors = {}
    # leave the columns of df that we need - where the column trail number is equal to the trail number we want
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

    start_diffx = df['x start (pixels)'].values.tolist()
    start_diffy = df['y start (pixels)'].values.tolist()
    end_diffx = df['x end (pixels)'].values.tolist()
    end_diffy = df['y end (pixels)'].values.tolist()

    root = tk.Tk()
    root.title("eyes movement")
    root.geometry("900x900")
    image_path = image_path.replace("'", "")
    img_dir = "C:/Users/User/PycharmProjects/FinalProject/ImagesAllSize900x900"
    image = Image.open(img_dir + "/" + image_path)
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
    x_axis_padding = float(original_image_width) / 2 - float(width) / 2
    y_axis_padding = float(original_image_height) / 2 - float(height) / 2

    # Draw circles and lines between them
    for i in range(len(start)):
        if [df['trail number'][i]] == trails_num:
            x1, y1 = start[i]
            x2, y2 = end[i]
            x1, y1 = x1 - x_axis_padding, y1 - y_axis_padding
            x2, y2 = x2 - x_axis_padding, y2 - y_axis_padding
            print("x1, y1: ")
            print(x1, y1)
            print("x2, y2: ")
            print(x2, y2)
            print(df['trail number'][i])

            # Draw circle
            trail_number = df.loc[i, 'trail number']
            color = trail_colors[trail_number]
            canvas.create_oval(x1, y1, x2, y2, fill=color, width=4, outline=color, tags="dot", activefill=color)
            # Draw line to previous point
            prev_x, prev_y = start[i - 1]
            prev_x, prev_y = prev_x - x_axis_padding, prev_y - y_axis_padding
            trail_number = df.loc[i, 'trail number']
            color = trail_colors[trail_number]
            canvas.create_line(prev_x, prev_y, x1, y1, width=5, fill=color)
            if df['trail number'][i] == trail_num:
                canvas.create_text(((x1 + prev_x) / 2) + 4, ((y1 + prev_y) / 2) - 4,
                                   text=str(int(trail_number)) + " , " + str(i),
                                   fill="black", font="Arial 10 bold")

    canvas.pack()
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
            print( "You chose image: " + image.image_name)
            image.image_size = image.image_size.replace("'", "")
            image.image_name = image.image_name.replace("'", "")

            print("Image size: " + str(image.image_size) + " pixels")
            print("Image size: " + str(image.image_size) + " pixels")
            return image.image_name, image.image_size, image.image_size, image

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
    image_name, width, height, chosen_image = choose_pic(images)
    # Search for the image index in the DataFrame
    matching_rows = df[df['image_index num'] == chosen_image.image_id]
    # Check if any matching rows are found
    if not matching_rows.empty:
        # Retrieve the trail numbers from all matching rows
        trail_numbers = matching_rows['trail number'].tolist()
        trail_num = trail_numbers[0]
        chosen_image.set_trail_number(trail_num)
        print(f"The trail numbers for image index {chosen_image.image_id} are: {trail_numbers}")
    else:
        print(f"No trail numbers found for image index {chosen_image.image_id}")
    show_image(df, image_name, width, height, chosen_image.trail_number)
    # add to Data.csv the headers from the df
    df.to_csv('Data.csv', header=True, index=False)


