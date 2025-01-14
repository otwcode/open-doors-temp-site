#!/bin/bash
set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

for file in 'database.yml' 'cable.yml'
do
  file1=$(<"config/$file")
  file2=$(<"config/$file~")
  echo "$file1" > "config/$file~"
  echo "$file2" > "config/$file"
done