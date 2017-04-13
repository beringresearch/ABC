import sys
from . import argparser
from . import cluster

def main():
    cluster_size, input_files = argparser.parse_input_filepaths(sys.arg)
    images_folder, logs_folder = argparser.create_output_folder()
    cluster.run(input_files, cluster_size, images_folder, logs_folder)

if __name__ == '__main__':
    main()
