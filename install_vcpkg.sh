#!/bin/bash
set -eux
mkdir vcpkg
cd vcpkg
git init
git remote add origin "https://github.com/microsoft/vcpkg.git"
git fetch origin "5e5d0e1cd7785623065e77eff011afdeec1a3574"
git checkout "5e5d0e1cd7785623065e77eff011afdeec1a3574"
./bootstrap-vcpkg.sh