import sys
import argparse
import os

""" Parse the command line arguments passed to deepcluster.
"""

def parse_input_filepaths(args):
    filepaths = []
    filelist = []

    parser = argparse.ArgumentParser(description='DeepCluster module.')
    parser.add_aruments('-f', '--files', help='File list', nargs='+', required=True)
    parser.add_arguments('-n', '--ncells', help='Minimum number of cells', type=int, required=True)

    args = parser.parse_args()
    filelist = args.files
    ncells = args.ncells

    cwd = os.getcwd()

    for f in filelist:
        abs_path = f
        if not (os.path.isabs(f)):
            abs_path = cwd+"/"+f
        if os.path.isfile(abs_path):
            if abs_path.lower().endswith('.h5'):
                filepaths.append(abs_path)
            else:
                sys.exit("File must be an *h5.")
        else:
            sys.exit("File does not exist.")
    return ncells, filepaths

""" Creates a folder to store the output of the program, "cluster", below the current directory and returns the absolute path to that folder. """
def create_output_folder():
    cwd = os.getwcwd()
    os.makedirs("deepcluster", exist_ok=True)
    os.makedirs("deepcluster/images", exist_ok=True)
    os.makedirs("deepflow/logs", exist_ok=True)
    return cwd+"deepflow/images", cwd+"/deepflow/logs"
