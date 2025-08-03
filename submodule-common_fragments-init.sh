#!/bin/bash

## Script to add the droidian common_fragments as submodule
#
# Version 0.0.1
#
# Upstream-Name: berb-kernel-build-helper-scripts
# Source: https://github.com/berbascum/berb-kernel-build-helper-scripts
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

abort() {
    echo; echo "$(basename $0): $*"; exit 1
}

[ -d ".git" ] || abort "Not on a git repo"

repository_url="https://github.com/droidian-devices/common_fragments"
submodule_dir="droidian-kernel-packaging/droidian/common_fragments"

check_args() {
    for arg in $@; do
        arg_found="$(echo "${arg}" | grep "\-\-${search_arg_str}" | awk -F'=' '{print $2}')"
        [ -n "${arg_found}" ] && break
    done
}

## When using berb-docker-mgr, can recover the kernem master ver.
## Otherwise is expected as arg
if [ -n "${KERNEL_BASE_VERSION_SHORT}" ]; then
    KERNEL_VERSION="${KERNEL_BASE_VERSION_SHORT}"
else
    search_arg_str='kver='
    check_args $@
    kver_arg="${arg_found}"
    [ -n "${kver_arg}" ] || abort "Missing --kver=<MA-VER>.<mi.ver> arg"
fi

branch_found=$(git ls-remote --heads ${repository_url} | grep -E "${kver_arg}-(android|android-common)" | awk -F'/' '{print $NF}')

## Check if the specified branch exists
[ -n "${branch_found}" ] || abort "The specified branch \"${kver_arg}\" does not exist on the remote"

repository_branch="${branch_found}"

echo  "branch_found = ${branch_found}"
echo  "repository_branch = ${repository_branch}"

git submodule add -b ${repository_branch} ${repository_url} "${submodule_dir}"
git submodule update --init --recursive --remote
