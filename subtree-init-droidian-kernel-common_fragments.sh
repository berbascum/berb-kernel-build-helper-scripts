#!/bin/bash

## Script to initialize a kernel version branch from droidian common_fragments as subtree
#
# Version_0.1.1
#
# Upstream-Name: droidian-kernel-build-helper-scripts
# Source: https://github.com/berbascum/droidian-kernel-build-helper-scripts/tree/subtree-init/droidian-kernel-common_fragments
#
# Copyright (C) 2025 Berbascum <berbascum@ticv.cat>
# All rights reserved.
#
# BSD 3-Clause License
#
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Set constants
git_user="droidian-devices"
repo_name="common_fragments"
repo_url="https://github.com/${git_user}/${repo_name}"
remote_name="upstream-common_fragments"
subtree_path="droidian/common_fragments"
git_args="--squash"

## Print stdout functions
error() {
    echo "ERROR: $*"; exit 1
}

info() {
    echo "INFO: $*"
}

# Check if the current dir is a git repo
[ -d ".git" ] || error "Not in a git repo!"
    
# Check if the current dir is a kernel source dir
[ -f Kconfig -a -f Makefile -a -d kernel -a -d arch ] || error "Not in a kernel source dir!"

## When using berb-docker-mgr, can recover the kernem master ver.
## Otherwise is expected as arg
if [ -n "${KERNEL_BASE_VERSION_SHORT}" ]; then
    KERNEL_VERSION="${KERNEL_BASE_VERSION_SHORT}"
else
    for arg in $@; do
        KERNEL_VERSION="$(echo "${arg}" | grep "\-\-kver=" \
	    | awk -F'=' '{print $2}')"
    done
fi

echo ""

[ -n "${KERNEL_VERSION}" ] || error "$(basename $0): Missing -kver=<MA-VER>.<mi.ver> arg"

branch_found=$(git ls-remote --heads ${repo_url} | grep -E "${KERNEL_VERSION}-(android|android-common)" | awk -F'/' '{print $NF}')

## Check if exist a branch for the specified kernel version
[ -n "${branch_found}" ] || error "$(basename $0): The specified common_fragments branch does not exist"

info  "branch_found = ${branch_found}"

repo_branch="${branch_found}"

git remote add ${remote_name} ${repo_url}
git subtree add --prefix=${subtree_path} ${remote_name} ${repo_branch} ${git_args} || abort "Subtree download failed!"
