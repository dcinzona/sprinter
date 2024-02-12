# Scan and compare project source directories for duplicate metadata using
# file path and file names, and file API names and labels.
# This script is intended to be run from the command line.
# Usage: python project-scan.py

import os
import json
from collections import defaultdict

# Read sfdx-project.json to get the package directories
sfdx_project = None
with open("sfdx-project.json") as f:
    sfdx_project = json.load(f)
package_directories = sfdx_project["packageDirectories"]

# get path of each package directory
package_directories_path = []
for package_directory in package_directories:
    package_directories_path.append(package_directory["path"])

print("Scanning packages: ", ", ".join(package_directories_path))

# Set metadata folders within package directories to scan
metadata_folders = [
    "aura",
    "classes",
    "components",
    "flexipages",
    "lwc",
    "objects",
    "pages",
    "permissionsets",
    "tabs",
    "triggers",
    "staticresources",
]

# find all subdirectories within the package directories using os.walk
# if any of the metadata folders are found, add them to the list of
# metadata folders to scan
metadata_paths_per_package = defaultdict(list)
for package_directory in package_directories_path:
    for root, dirs, files in os.walk(package_directory):
        for metadata_folder in metadata_folders:
            if metadata_folder in dirs:
                pth = os.path.relpath(
                    os.path.join(root, metadata_folder), package_directory
                )
                metadata_paths_per_package[package_directory].append(pth)

# check if there are any duplicate filenames within the metadata folders
# for each metadata folder, find all files
# if any files have the same name, add them to the list of duplicate files
scanned_files = defaultdict(list)

# Special directories (where subfolders replace all components, like LWC)
special_directories = ["aura", "lwc"]
files_to_skip = ["jsconfig.json"]


def getKeyForFilePath(filepath) -> str:
    for bundleparent in special_directories:
        bundlefolder = "/" + bundleparent + "/"
        if bundlefolder in filepath:
            spl = filepath.split("/")
            filepath = "/".join(spl[:-1])
    return filepath


def get_duplicate_files(metadata_folder, package_path):
    for root, dirs, files in os.walk(metadata_folder):
        # skip if root ends with __tests__
        if "__tests__" in root:
            continue
        # check if file parent is folder with special directories
        for file in files:
            if file in files_to_skip:
                continue
            # if the current directory is a special directory, we only need to check subfolders, not files
            rp = os.path.relpath(root, package_path)
            relative_path = rp.replace(package_path, "")
            file_path = os.path.join(relative_path, file)
            fp = getKeyForFilePath(file_path)
            # add to scanned files if not already in value
            if fp not in scanned_files.keys():
                scanned_files[fp] = [package_path]
            else:
                if package_path not in scanned_files[fp]:
                    scanned_files[fp].append(package_path)


for package in metadata_paths_per_package.keys():
    # print("Scanning Package:", package)
    for metadata_path in metadata_paths_per_package[package]:
        dir_to_scan = os.path.join(package, metadata_path)
        get_duplicate_files(dir_to_scan, package)


# get unique entries from duplicate_files
unique_duplicate_files = defaultdict(list)

for key in scanned_files.keys():
    if len(scanned_files[key]) > 1:
        unique_duplicate_files[key] = scanned_files[key]

# print results if dupes found
if len(unique_duplicate_files) == 0:
    print("No duplicate files found.")
else:
    print("Duplicate Components:")
    for key in unique_duplicate_files.keys():
        print(" ", key)
        for package in unique_duplicate_files[key]:
            print("   ->", package)
