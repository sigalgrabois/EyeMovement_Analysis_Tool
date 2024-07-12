# Eye Movement Analysis Tool

## Overview
This is a Python-based tool for analyzing eye movement data collected during experiments. The tool provides functionalities to visualize eye movements on images, create heatmaps, and perform various data analysis tasks.
This tool uses [edfImport](https://github.com/alexander-pastukhov/edfImport.git) for initial preprocessing of the data.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

## Installation
1. Clone this repository to your local machine: [https://github.com/sigalgrabois/EyeMovement_Analysis_Tool.git](https://github.com/sigalgrabois/EyeMovement_Analysis_Tool.git)
2. Navigate to the project directory
3. run the exe file in the dist folder
4. The application will launch a graphical user interface (GUI) for interacting with eye movement data and images.

## Usage
1. Run the application by executing the main script.
2. Run the script app.py from the cmd in the working directory.

## Features
- **Data Loading**: Process and load eye movement data from edf files to CSV files.
- **Image Visualization**: Display images with eye movement trails.
- **Heatmap Creation**: Generate heatmaps to visualize eye movement patterns.
- **Single Participant View**: Analyze data for a single participant.
- **Multi-Participant View**: Analyze data for multiple participants on the same image.
- **Data Export**: Export analyzed data and visualizations.

## Running Instructions
To use the Eye Movement Analysis Tool, follow these steps:
1. Clone the repository to your local machine:
 ```bash
git clone https://github.com/sigalgrabois/FinalProject.git
```
2. Navigate to the project directory:
 ```bash
cd FinalProject
```
3. Navigate to the project directory App:
 ```bash
cd App
```
4. In this folder there is a zip file, extract to the file in the working folder, and choose to export it to the App folder.
5. Double click the file "EyeMovement.exe" or Run the executibule file:
 ```bash
   ./EyeMovement.exe
```

## Getting Started
In order to run the two parts of the eye movement analysis that the tool offers, you must make sure that you have the images.xlsx file provided with the project. When you click on the "Single Participant" or "Multi Participant" button, you will first be asked to insert a path to the file containing the data of the images. You must enter images.xlsx and continue according to the instructions.

1. Load Eye Movement Data:
- Click the "Load Data" button to preprocess and load eye movement data.

2. Single Participant Analysis:
- Click the "Single Participant" button to analyze data for a single participant.
- Choose an image from the dataset and view eye movement trails.

3. Multi-Participant Analysis:
- Click the "Multi Participant" button to analyze data for multiple participants.
- Select an image to view eye movement trails of all participants on the same image.

4. Export Results:
- Save visualizations or analyzed data as needed.

## Contributing
Contributions to this project are welcome! If you'd like to contribute, please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix: `git checkout -b feature/your-feature-name`.
3. Make your changes and commit them: `git commit -m "Add your feature description"`.
4. Push your changes to your fork: `git push origin feature/your-feature-name`.
5. Open a pull request to the main repository.

## results
visualization of 1 participant with 1 picture and his eyemovements on the picture:
<p align="center">
  <img src="https://github.com/Shachar-Oron/Eye_movements_Analysis_tool/blob/main/WhatsApp%20Image%202024-06-30%20at%2020.44.28_3591a378.jpg?raw=true" alt="level 1" width="45%"/>
</p>
visualization of a heatmap next to the eye movements trajectory:
<p align="center">
  <img src="https://github.com/Shachar-Oron/Eye_movements_Analysis_tool/blob/main/WhatsApp%20Image%202024-06-30%20at%2020.44.52_73c5cbc0.jpg?raw=true" alt="level 1" width="45%"/>
</p>
visualization of a one picture with multiple eye movements of different participants:
<p align="center">
  <img src="https://github.com/Shachar-Oron/Eye_movements_Analysis_tool/blob/main/WhatsApp%20Image%202024-06-30%20at%2020.45.12_a922df20.jpg?raw=true" alt="level 1" width="45%"/>
</p>

## Requirements
- Python 3.7
- MATLAB installed
