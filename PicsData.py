# DOTO
import pandas as pd


# create a Picture class
# the fileds will be image_name	image_category	image_size(pixels)	image_id	image_category_id

class Picture:
    def __init__(self, image_name, image_category, image_size, image_id, image_category_id):
        self.image_name = image_name
        self.image_category = image_category
        self.image_size = image_size
        self.image_id = image_id
        self.image_category_id = image_category_id
        self.trail_number = 0

    def set_trail_number(self, trail_number):
        self.trail_number = trail_number

    def get_trail_number(self):
        return self.trail_number

    def get_image_name(self):
        return self.image_name

    def get_image_category(self):
        return self.image_category

    def get_image_size(self):
        return self.image_size

    def get_image_id(self):
        return self.image_id

    def get_image_category_id(self):
        return self.image_category_id
    def print(self):
        print(self.image_name)
        print(self.image_category)
        print(self.image_size)
        print(self.image_id)
        print(self.image_category_id)

    def load_picture(self):
        image = self.open(self.image_name)
        return image


def load_data_pics(file):
    # read the csv file into a pandas data frame
    df = pd.read_excel(file, engine='openpyxl')
    print(df.columns)

    # create a list of Picture objects
    pics_list = []
    # iterate over the rows of the data frame
    for index, row in df.iterrows():
        # create a Picture object
        pic = Picture(row['image_name'], row['image_category'], row['image_size'], row['image_id'],
                      row['image_category_id'])
        # add the Picture object to the list
        pics_list.append(pic)
    return pics_list



def print_pic_list(pics_list):
    for pic in pics_list:
        print(pic.get_image_name())
        print(pic.get_image_category())
        print(pic.get_image_size())
        print(pic.get_image_id())
        print(pic.get_image_category_id())
        print(pic.get_trail_number())
        print("*********************")

