# Scan and compare project source directories for duplicate metadata using file path and file names, and file API names and labels.
# This script is intended to be run from the command line.
# Usage: python project-scan.py <project_directory>

import os
import json
from collections import defaultdict

# Read sfdx-project.json to get the package directories
sfdx_project = None
with open('sfdx-project.json') as f:
    sfdx_project = json.load(f)
package_directories = sfdx_project['packageDirectories']

# get path of each package directory
package_directories_path = []
for package_directory in package_directories:
    package_directories_path.append(package_directory['path'])

print('Package Directories:', package_directories_path)

# Set metadata folders within package directories to scan
metadata_folders = ['classes', 'components', 'objects', 'pages', 'triggers', 'staticresources']

# Check if metadata folders exist in any subdirectory within the package directories
# find all subdirectories within the package directories using os.walk
# if any of the metadata folders are found, add them to the list of metadata folders to scan
metadata_paths_per_package = defaultdict(list)
for package_directory in package_directories_path:
    for root, dirs, files in os.walk(package_directory):
        for metadata_folder in metadata_folders:
            if metadata_folder in dirs:
                metadata_paths_per_package[package_directory].append(os.path.relpath(os.path.join(root, metadata_folder), package_directory))

# check if there are any duplicate filenames within the metadata folders
# for each metadata folder, find all files
# if any files have the same name, add them to the list of duplicate files
scanned_files = dict()
duplicate_files = []


def get_duplicate_files(metadata_folder, package_path):
    for root, dirs, files in os.walk(metadata_folder):
        for file in files:
            relative_path = os.path.relpath(root, package_path)
            # remove the package directory from the relative path
            relative_path = relative_path.replace(package_path, '')
            file_path = os.path.join(relative_path, file)
            for key in scanned_files.keys():
                if key == file_path:
                    duplicate_files.append(file_path)
            scanned_files[file_path] = file


for package in metadata_paths_per_package.keys():
    print('Scanning Package:', package)
    for metadata_path in metadata_paths_per_package[package]:
        dir_to_scan = os.path.join(package, metadata_path)
        get_duplicate_files(dir_to_scan, package)


for file in duplicate_files:
    print('Duplicate File:', file)
