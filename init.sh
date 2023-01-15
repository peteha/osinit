#!/bin/bash
echo "## Setting Up OS Build Directory ##"
# Create Base DIR
mkdir -p /opt/osbuild
cd /opt/osbuild
##
##
echo "## Installing Scripts ##"
curl -fs https://raw.githubusercontent.com/peteha/labosinit/main/osinit.sh --output osinit.sh
chmod +x osinit.sh
curl -fs https://raw.githubusercontent.com/peteha/labosinit/main/certbuild.sh --output certbuild.sh
chmod +x certbuild.sh
##
##