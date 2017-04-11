import sys
import argparse
import os

""" Parses the command line arguments passed to deepflow. Checks the files for validity and converts the input filepaths from relative to absolute.
    Returns a list of absolute filepaths for the input files, if they are all valid, terminates if any are not. """
def parse_input_filepaths(args):
    filepaths = []
    filelist = []
    markers = '' 
    
    parser = argparse.ArgumentParser(description='DeepFlow module.')
    parser.add_argument('-m', '--markers', help='Marker file name',required=True)
    parser.add_argument('-f', '--files', help='File list', nargs='+', required=True)
    parser.add_argument('-n', '--nskip', help='Rows to be skipped', type=int, required=True)

    args = parser.parse_args()
    
    markers = args.markers
    filelist = args.files
    nskip = args.nskip

    cwd = os.getcwd()

    if not (os.path.isabs(markers)):
        markers = cwd+"/"+markers 

    for f in filelist: 
            abs_path = f 
            if not (os.path.isabs(f)):
                abs_path=cwd+"/"+f
            if os.path.isfile(abs_path):
                if abs_path.lower().endswith('.txt'):
                    filepaths.append(abs_path) 
                else:
                    sys.exit("Not a text file.")
            else:
                sys.exit("File does not exist.")
     
    return markers, filepaths, nskip

""" Creates a folder to store the output of the program, "images", below the current directory, and returns the absolute path to that folder. """
def create_output_folder():
    cwd = os.getcwd()
    os.makedirs("deepflow", exist_ok=True)
    os.makedirs("deepflow/images", exist_ok=True)
    os.makedirs("deepflow/logs", exist_ok=True)
    return cwd+"/deepflow/images/", cwd+"/deepflow/logs/"
