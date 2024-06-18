import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np

def create_heatmap(start_points, end_points, width, height):
    # Calculate the number of bins in each dimension
    num_bins_x = width + 1
    num_bins_y = height + 1

    # Create an empty heatmap array
    heatmap = np.zeros((num_bins_y, num_bins_x))

    # Add start points to the heatmap
    for x, y in start_points:
        heatmap[y][x] += 1

    # Add end points to the heatmap
    for x, y in end_points:
        heatmap[y][x] += 2

    # Plot the heatmap
    plt.figure(figsize=(10, 8))
    sns.heatmap(heatmap, cmap='coolwarm', square=True, cbar=False)
    plt.title('Eye Movement Heatmap')
    plt.xlabel('X Position')
    plt.ylabel('Y Position')
    plt.show()


# Sample start and end points
start_points = [(100, 100), (150, 250), (300, 400)]
end_points = [(20, 180), (160, 100), (350, 380)]

# Width and height of the picture
width = 500
height = 500

# Call the create_heatmap function
create_heatmap(start_points, end_points, width, height)
