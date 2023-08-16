import time
import numpy as np
import pandas as pd
import tkinter as tk
from tkinter import PhotoImage
from tkinter import *
from PIL import Image, ImageTk, ImageGrab
import subprocess
import seaborn as sns


from PIL.ImageDraw import ImageDraw
import matplotlib.pyplot as plt

from PicsData import load_data_pics, Picture
import openpyxl
from openpyxl import Workbook
import os


# TODO:
# create a video from the images with the eye movement
# create a heatmap from the eye movement
# add a function to see many experimenters at the same time on the same image
# same image with different sizes on the same window - 4 images
# write the app itself

def close(ws):
    ws.destroy()

def resize_func(canvas, image, width, height):
    resize_img = image.resize((width, width))
    img = ImageTk.PhotoImage(resize_img)
    canvas.config(image=img)
    canvas.image = img


def save_image(canvas):
    # take the image from the canvas with all that is on it
    # and export it to a png file
    canvas.postscript(file="eyes_movement.ps", colormode='color')
    img = Image.open("eyes_movement.ps")
    img.save("eyes_movement.png", "png")



def create_heatmap(width, height, heat_fixations):
    # Define the number of grids in x and y directions
    grid_size = 20

    # Convert heat_fixations to a pandas DataFrame
    df_heatmap = pd.DataFrame(heat_fixations, columns=["x", "y"])

    # Create a 2D histogram of the fixations
    heatmap, xedges, yedges = np.histogram2d(df_heatmap["x"], df_heatmap["y"], bins=grid_size, range=[[0, width], [0, height]])

    # Create a DataFrame from the heatmap values
    df_heatmap = pd.DataFrame(heatmap, index=range(grid_size), columns=range(grid_size))

    # Create a heatmap plot using seaborn
    plt.figure(figsize=(8, 6))
    sns.heatmap(df_heatmap, square=True, cbar=True, xticklabels=False, yticklabels=False)
    plt.title("Eye Movement Heatmap")
    plt.xlabel("Grid X Coordinate")
    plt.ylabel("Grid Y Coordinate")
    plt.imshow(heatmap, extent=[xedges[0], xedges[-1], yedges[0], yedges[-1]], cmap='hot', alpha=0.7)
    plt.show()


def show_image(df, image_path, width, height, trail_num, method, root1):
    trails_num = np.unique(trail_num)
    trail_colors = {}
    for num in trails_num:
        trail_colors[num] = "#%06x" % np.random.randint(0, 0xFFFFFF)
    # make a list out of the 3th column in the data frame - start x of the eye movement
    # Extract the desired columns
    # save the values from the 3th column in a list not with loc
    start_x = df['x start (pixels)'].values.tolist()
    start_y = df['y start (pixels)'].values.tolist()
    end_x = df['x end (pixels)'].values.tolist()
    end_y = df['y end (pixels)'].values.tolist()

    root1.geometry("900x900")
    root1.anchor(CENTER)

    # add a button to save the image with the trails on it
    button = tk.Button(root1, text="Save Image", command=lambda: save_image(canvas1))
    button.pack(side="top", fill="both", expand="yes", padx="10", pady="10")
    # add a button to create a heatmap of the trails on the image
    button = tk.Button(root1, text="Create Heatmap",
                       command=lambda: create_heatmap(new_width, new_height, heatmap_points))
    button.pack(side="top", fill="both", expand="yes", padx="10", pady="10")
    image_path = image_path.replace("'", "")
    img_dir = "./ImagesAllSize900x900"
    image = Image.open(img_dir + "/" + image_path)
    new_width = int(float(width.replace("'", "").replace('"', '')))
    new_height = int(float(height.replace("'", "").replace('"', '')))

    # Convert the string to a raw string
    # image = Image.open(image_path)
    img = image.resize((new_width, new_height))
    my_img = ImageTk.PhotoImage(img)
    screen_width = root1.winfo_screenwidth()
    screen_height = root1.winfo_screenheight()
    canvas1 = tk.Canvas(root1, width=screen_width, height=screen_height)
    canvas1.create_image(0, 0, anchor=NW, image=my_img)
    canvas1.pack()

    size_list = [900, 450, 225, 112]
    scale_factors = [1, 2, 4, 8.0357]
    # create a dictionary of the size list and the scale factor
    scale_dict = dict(zip(size_list, scale_factors))
    chosen_factor = scale_dict[new_width]

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
    heatmap_points = []
    default_color = "#0000FF"
    # Draw circles and lines between them
    for i in range(len(start)):
        x1, y1 = start[i]
        x2, y2 = end[i]
        x1, y1 = (x1 - x_axis_padding) / chosen_factor, (y1 - y_axis_padding) / chosen_factor
        heatmap_points.append((x1, y1))
        x2, y2 = (x2 - x_axis_padding) / chosen_factor, (y2 - y_axis_padding) / chosen_factor
        heatmap_points.append((x2, y2))
        # Check if the coordinates are valid
        if x2 == -510.0 or y2 == -90.0:
            continue

        # Draw circle
        if method == "2":
            trail_number = trail_num[i]
            color = trail_colors[trail_number]

        else:
            if len(trails_num) == 1:
                trail_number = trails_num[0]
                color = trail_colors[trail_number]
            else:
                color = default_color
        not_good_size = (x2 - x1 > 10) or (y2 - y1 > 10)
        if not_good_size:
            continue
        else:
            canvas1.create_oval(x1, y1, x2, y2, fill=color, width=4, outline=color, tags="dot", activefill=color)

            # Draw line to previous point
            prev_x, prev_y = start[i - 1]
            prev_x, prev_y = (prev_x - x_axis_padding) / chosen_factor, (prev_y - y_axis_padding) / chosen_factor
            canvas1.create_line(prev_x, prev_y, x1, y1, width=5, fill=color)

            canvas1.create_text(((x1 + prev_x) / 2) + 4, ((y1 + prev_y) / 2) - 4,
                               text=str(int(trail_number)) + " , " + str(i),
                               fill="yellow", font="Arial 10 bold")

    root1.mainloop()
    return x_axis_padding, y_axis_padding


def run_matlab_script(matlab_app):
    # run the matlab
    print("matlab script has been run")
    # run the ExtractDataEDF.exe file that will create the csv file
    subprocess.call(matlab_app)


def choose_pic(images, image_category_id):
    user_choice_pic = image_category_id

    for image in images:
        if image.image_id == int(user_choice_pic) or image.image_name == user_choice_pic:
            image_size = image.image_size.replace("'", "")
            image_name = image.image_name.replace("'", "")
            return str(image_name), image_size, image.image_size, image.image_id, image.image_category_id

    # If the loop completes without returning a value, the choice was not found
    print("Image not found. Please make sure to enter a valid image ID or image name.")
    return None, None, None


def extract_data(image_index):
    dataframes = []  # List to store DataFrames from each CSV file

    # Get a list of all CSV files in the 'exposure_csv' folder
    csv_files = [file for file in os.listdir('exposure_csv') if file.endswith('.csv')]

    # Iterate through each CSV file
    for csv_file in csv_files:
        file_path = os.path.join('exposure_csv', csv_file)

        # Define column names
        column_names = ['image_index num', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)',
                      'y end (pixels)',
                      'start diff (start trail- start event)', 'end diff (end trail- send event)',
                      'duration of fixation',
                      '', 'amplitude in pixels', 'amplitude in degrees', 'write peak velocity deg/s',
                      'write average velocity deg/s', '', 'size', 'category', 'trail number']

        # Read the CSV file into a DataFrame and assign column names
        df = pd.read_csv(file_path, delimiter='\t', header=None, names=column_names)

        # Filter rows with the specified image index and append to the list
        selected_rows = df[df['image_index num'] == image_index]

        # Add a new column 'source_csv' with the CSV file's index
        selected_rows['source_csv'] = int(csv_file.split('.')[0])  # Assuming filenames are numeric

        dataframes.append(selected_rows)

    # Concatenate the DataFrames from all files into a single DataFrame
    combined_df = pd.concat(dataframes, ignore_index=True)

    return combined_df


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    # create a gui to choose the image
    method = input("choose the method: (1)one pic for one person, or (2)one pic with all the people? (1/2)")
    # use the load pictures to load a list of all the images in the folder
    path = input("please enter the path of the images data set: ")
    images = load_data_pics(path)
    if method == "2":
        image_name, width, height, image_id, image_category_id = choose_pic(images)
        chosen_image = Picture(image_name, width, height, image_id, image_category_id)
        image_idx = chosen_image.image_id
        df = extract_data(image_idx)
    else:
        df = pd.read_csv('Data.csv', header=0, delimiter=",")
        df.columns = ['image_index num', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)',
                      'y end (pixels)',
                      'start diff (start trail- start event)', 'end diff (end trail- send event)',
                      'duration of fixation',
                      '', 'amplitude in pixels', 'amplitude in degrees', 'write peak velocity deg/s',
                      'write average velocity deg/s', '', 'size', 'category', 'trail number']

    if method == "1":  # 1 pic for one person
        # # connect to Matlab and run the script that will create csv file of the data
        # # open the csv file and read it into a pandas data frame
        # matlab_app = "ExtractDataEDFv_2_1.exe"
        # run_matlab_script(matlab_app)
        # # wait for the csv file to be created - 15 seconds should be enough
        # time.sleep(7)
        image_name, width, height, image_id, image_category_id = choose_pic(images)
        chosen_image = Picture(image_name, width, height, image_id, image_category_id)
        image_idx = chosen_image.image_id
        # in df search for the image index and from the line of the index bring me the trail number
        # Search for the image index in the DataFrame
        matching_row = df[df['image_index num'] == image_idx]
        trail_number = matching_row.loc[:, 'trail number'].values[0].T

        # Check if a matching row is found
        if matching_row.empty:
            print(f"No trail number found for image index {image_idx}")

        x, y = show_image(matching_row, image_name, width, height, trail_number, method)
        # add to Data.csv the headers from the df
        df.to_csv('Data.csv', header=True, index=False)
    else:
        found = False
        for image in images:
            if image.image_id == image_idx[0]:
                found = True
                image_name, width, height, image_id, image_category_id = image.image_name, image.image_size, image.image_size, image.image_id, image.image_category_id
                chosen_image = Picture(image_name, width, height, image_id, image_category_id)
                trail_numbers = df.loc[:, 'trail number'].values.T
                x_axis_padding, y_axis_padding = show_image(df, image_name, width, height, trail_numbers, method)
        if not found:
            print("Image not found. Please make sure to enter a valid image ID or image name.")

            # Call the function to extract data for the specified image index
            extracted_data = extract_data(image_idx)

            # Display the extracted data
            print(extracted_data)


