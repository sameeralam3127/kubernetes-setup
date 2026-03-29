!#/bin/bash

# This script is used to set up the environment for system design interviews.
# It installs necessary tools and libraries, and sets up the environment for coding.
# Update the package list and install necessary tools
sudo apt-get update
sudo apt-get install -y build-essential git vim
# Install Python and necessary libraries
sudo apt-get install -y python3 python3-pip
