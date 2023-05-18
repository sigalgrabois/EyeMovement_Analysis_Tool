import os
from PIL import Image

def convert_ppm_to_png(ppm_file, png_file):
    with Image.open(ppm_file) as image:
        image.save(png_file)

def batch_convert_ppm_to_png(directory):
    ppm_files = [file for file in os.listdir(directory) if file.endswith(".ppm")]

    for ppm_file in ppm_files:
        ppm_path = os.path.join(directory, ppm_file)
        png_file = os.path.splitext(ppm_file)[0] + ".png"
        png_path = os.path.join(directory, png_file)

        convert_ppm_to_png(ppm_path, png_path)

    print("Conversion completed.")

# Example usage
directory = "C:/Users/User/PycharmProjects/FinalProject/ImagesAllSize900x900"
batch_convert_ppm_to_png(directory)

# Open the directory of the PNG files
