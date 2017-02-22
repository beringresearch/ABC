import sys
from . import argparser
from . import autoencoder

def main():
    input_files = argparser.parse_input_filepaths(sys.argv)
    output_folder = argparser.create_output_folder()
    autoencoder.run(input_files, output_folder)

if __name__ == '__main__':
    main()
