#!/bin/bash

## This script is just a helper for the Droiddian kernel compilation.
# releng-tools will be used.
#
# Porting guide: https://github.com/droidian/porting-guide/blob/master/kernel-compilation.md

chmod +x /buildd/sources/debian/rules
cd /buildd/sources
rm -f debian/control
debian/rules debian/control

RELENG_HOST_ARCH=arm64 releng-build-package
