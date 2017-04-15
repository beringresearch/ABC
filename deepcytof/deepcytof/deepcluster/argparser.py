import argparse
import os

""" Parse the command line arguments passed to deepcluster.
"""

def parse_input_filepaths(args):
    filepath = '' 
    markers = ''
    weightpath = '' 

    parser = argparse.ArgumentParser(description='DeepCluster module.')
    parser.add_argument('-m', '--markers', help='Marker file name', required=True)
    parser.add_argument('-f', '--file', help='File name', required=True)
    parser.add_argument('-w', '--weights', help='Autoencoder weights', required=True)
    parser.add_argument('-c', '--ncells', nargs='?', help='Minimum number of cells', type=int, required=False, const=1, default = 750)
    parser.add_argument('-n', '--nskip', nargs='?',  help='Skip number of rows', type=int, required=False, const=1, default = 0)

    args = parser.parse_args()

    markers = args.markers
    filepath = args.file
    weightpath = args.weights
    ncells = args.ncells
    nskip = args.nskip
    

    cwd = os.getcwd()

    if not (os.path.isabs(markers)):
        markers = cwd+"/"+markers
    if not (os.path.isabs(filepath)):
        filepath = cwd+"/"+filepath
    if not (os.path.isabs(weightpath)):
        weightpath = cwd+"/"+weightpath
     
    
    return markers, filepath, weightpath, ncells, nskip

""" Creates a folder to store the output of the program, "cluster", below the current directory and returns the absolute path to that folder. """
def create_output_folder():
    cwd = os.getcwd()
    os.makedirs("deepcluster", exist_ok=True)
    os.makedirs("deepcluster/images", exist_ok=True)
    os.makedirs("deepcluster/logs", exist_ok=True)
    return cwd+"/deepcluster/images", cwd+"/deepcluster/logs"
