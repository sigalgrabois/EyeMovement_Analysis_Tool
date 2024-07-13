import subprocess
import tkinter as tk
from datetime import time
from tkinter import filedialog, simpledialog

import pandas as pd
from numpy.core.defchararray import isdigit

from PicsData import Picture, load_data_pics
from main import choose_pic, extract_data, show_image, show_image_multi


# this function will run the app and will be called from the main.py file
def run_App():
    def load_data():
        # run the preprocessEdfToCsv.exe file as a subprocess
        subprocess.run("preprocessEdfToCsv.exe")

    def show_single_participant():
        # run the ExtractDataEDFv_2.exe file as a subprocess - this will create the Data.csv file
        subprocess.run("ExtractDataEDFv_2.exe")
        time.sleep(5)
        # Ask the user for the path of the images dataset
        data_path = simpledialog.askstring("Input", "Enter the path of the images dataset:",
                                           parent=root)
        images = load_data_pics(data_path)
        # Ask the user for the image index
        index = simpledialog.askinteger("Input", "Enter the index of the image to display:",
                                        parent=root, minvalue=0, maxvalue=160)

        if index is not None:
            # display a picture for the selected participant index and dataset path
            print(f"Displaying image for participant {index} from path {data_path}")
        else:
            print("No index entered.")
        df = pd.read_csv('Data.csv', header=0, delimiter=",")
        df.columns = ['image_index num', 'eye fix', 'x start (pixels)', 'y start (pixels)', 'x end (pixels)',
                      'y end (pixels)',
                      'start diff (start trail- start event)', 'end diff (end trail- send event)',
                      'duration of fixation',
                      '', 'amplitude in pixels', 'amplitude in degrees', 'write peak velocity deg/s',
                      'write average velocity deg/s', '', 'size', 'category', 'trail number']

        # Create a new window
        eye_movement_window = tk.Toplevel(root)
        eye_movement_window.title("Eye Movement Visualization")
        image_name, width, height, image_id, image_category_id = choose_pic(images, index)
        chosen_image = Picture(image_name, width, height, image_id, image_category_id)
        image_idx = chosen_image.image_id
        # in df search for the image index and from the line of the index bring me the trail number
        # Search for the image index in the DataFrame
        # Check available column names
        print(df.columns)
        matching_row = df[df['image_index num'] == image_idx]
        trail_number = matching_row.loc[:, 'trail number'].values[0].T

        # Check if a matching row is found
        if matching_row.empty:
            print(f"No trail number found for image index {image_idx}")

        x, y = show_image(matching_row, image_name, width, height, trail_number, 1, eye_movement_window)
        # add to Data.csv the headers from the df
        df.to_csv('Data.csv', header=True, index=False)
        # Make sure to call the mainloop() on the new window to keep it active
        eye_movement_window.mainloop()

    def show_multi_participant():
        # Ask the user for the path of the images dataset
        data_path = simpledialog.askstring("Input", "Enter the path of the images dataset:",
                                           parent=root)
        if data_path is not None:
            # Ask the user for the image index
            index = simpledialog.askinteger("Input", "Enter the index of the image to display:",
                                            parent=root, minvalue=0, maxvalue=160)

            if index is not None:
                # Add code to display a picture for the selected participant index and dataset path
                # ...
                print(f"Displaying image for participant {index} from path {data_path}")
            else:
                print("No index entered.")
        else:
            print("No path entered.")

        images = load_data_pics(data_path)
        # catch exception if index is out of boundaries
        try:
            image_name, width, height, image_id, image_category_id = choose_pic(images, index)
        except:
            print("Index out of boundaries")
            return
        chosen_image = Picture(image_name, width, height, image_id, image_category_id)
        image_idx = chosen_image.image_id
        df = extract_data(image_idx)
        # Create a new window
        eye_movement_window = tk.Toplevel(root)
        eye_movement_window.title("Eye Movement Visualization")
        if df.empty:
            print(f"No trail number found for image index {image_idx}")
        else:
            trail_numbers = df.loc[:, 'source_csv'].values.T
            heatmap_points = show_image_multi(df, image_name, width, height, trail_numbers, 2, eye_movement_window)

    # Create the main application window
    root = tk.Tk()
    root.title("EyeMovement Visualizer")

    # Set the window size
    root.geometry("600x300")  # Width x Height

    # Create a welcome label
    welcome_label = tk.Label(root, text="Welcome to the EyeMovement Visualizer", font=("Helvetica", 16, "bold"))
    welcome_label.pack(pady=20)

    # Create buttons with some styling
    button_style = {"font": ("Helvetica", 12), "padx": 20, "pady": 10, "bg": "#A7585F", "fg": "white"}

    load_button = tk.Button(root, text="Load Data", command=load_data, **button_style)
    single_button = tk.Button(root, text="Single Participant", command=show_single_participant, **button_style)
    multi_button = tk.Button(root, text="Multi Participant", command=show_multi_participant, **button_style)

    # Pack buttons
    load_button.pack()
    single_button.pack()
    multi_button.pack()

    # Start the GUI event loop
    root.mainloop()


run_App()
