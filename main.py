# This is a sample Python script.

# Press Shift+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.
import pyedflib
import numpy as np

def upload_file(path):
    file_name = pyedflib.data.get_generator_filename()
    f = pyedflib.EdfReader(file_name)
    n = f.signals_in_file
    signal_labels = f.getSignalLabels()
    sigbufs = np.zeros((n, f.getNSamples()[0]))
    for i in np.arange(n):
        sigbufs[i, :] = f.readSignal(i)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    upload_file('PyCharm')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
