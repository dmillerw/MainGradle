#!/usr/bin/python

import argparse
import getpass

from os.path import expanduser

# Argument setup
parser = argparse.ArgumentParser(description="Simple script to setup a new Minecraft Mod repository", prefix_chars="-+")
parser.add_argument('-r', action="store", dest="repoName", help="Repository Name", required=True)
parser.add_argument('-c', action="store_true", dest="clone", help="Clone MainGradle Repository", default=False)
parser.add_argument('-g', action="store_true", dest="gradle", help="Run Gradle scripts", default=False)
parser.add_argument('--username', action="store", dest="gitUser", help="GitHub Username")
parser.add_argument('--password', action="store", dest="gitPass", help="GitHub Password")
parser.add_argument('--repo-folder', action="store", dest="repoFolder", help="Main GitHub Repository Folder", default=expanduser("~") + "\Documents\Git Repos")

# Store the arguments
result = parser.parse_args()

print result