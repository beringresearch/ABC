import sys
import os

""" Parses the command line arguments passed to deepflow. Checks the files for validity and converts the input filepaths from relative to absolute.
    Returns a list of absolute filepaths for the input files, if they are all valid, terminates if any are not. """
def parse_input_filepaths(args):
    filepaths = []

    if len(sys.argv) < 2:
        sys.exit("deepflow is a tool which takes as inputs .fcs files, and saves graphs which display the data in 2-dimensions.\n\nUsage: deepflow [example1.txt, example2.txt...]")
    else:
        for file in sys.argv[1:]:
            cwd = os.getcwd()
            abs_path = file
            if not (os.path.isabs(file)):
                abs_path=cwd+"/"+file
            print(abs_path)
            if os.path.isfile(abs_path):
                if abs_path.lower().endswith('.txt'):
                    filepaths.append(abs_path)
                    print(abs_path)
                else:
                    sys.exit("Not a text file.")
            else:
                sys.exit("File does not exist.")
        
        return filepaths

""" Creates a folder to store the output of the program, "images", below the current directory, and returns the absolute path to that folder. """
def create_output_folder():
    cwd = os.getcwd()
    os.makedirs("images", exist_ok=True)
    return cwd+"/images/"
