import sys
from . import argparser
from . import autoencoder

def main():
    markers, input_files, nskip, transform = argparser.parse_input_filepaths(sys.argv)
    images_folder, logs_folder = argparser.create_output_folder()
    autoencoder.run(markers, input_files, nskip, images_folder, logs_folder, transform)

if __name__ == '__main__':
    main()
