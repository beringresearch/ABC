import sys
from . import argparser
from . import cluster

def main():
    markers, files, weights, cluster_size, nskip = argparser.parse_input_filepaths(sys.argv)
    images_folder, logs_folder = argparser.create_output_folder()
    cluster.run(markers, files, weights, images_folder, logs_folder, cluster_size,  nskip)

if __name__ == '__main__':
    main()
