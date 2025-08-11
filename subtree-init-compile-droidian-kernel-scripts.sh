#!/bin/bash

## Script to add the branch droidian-kernel-compile-helper as subtree
#
# Version 0.0.1
#
# Upstream-Name: droidian-kernel-build-helper-scripts
# Source: https://github.com/berbascum/droidian-kernel-build-helper-scripts
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

repository_url="https://github.com/berbascum/droidian-kernel-build-helper-scripts"
subtree_dir="scripts/build-kernel"
remote_name="origin-Kcompile-helper"
git_sub_args="--squash"

## Check if the script is called from the main subtree script
if [ -n "${subtree_main_path}" ]; then
    subtree_path="${subtree_main_path}/${subtree_dir}"
else
    subtree_path="droidian/${subtree_dir}"
fi

abort() {
    echo; echo "$(basename $0): $*"; exit 1
}

[ -d ".git" ] || abort "Not on a git repo"

check_args() {
    for arg in $@; do
        arg_found="$(echo "${arg}" | grep "\-\-${search_arg_str}" | awk -F'=' '{print $2}')"
        [ -n "${arg_found}" ] && break
    done
}

repository_branch="helper/compile-droidian-kernel-scripts"

echo  "repository_branch = ${repository_branch}"

git remote add ${remote_name} ${repository_url}
git subtree add --prefix=${subtree_path} ${remote_name} ${repository_branch} ${git_sub_args}

## Add the subtree dir to the subtree-main .gitignorewhet required
## Don't commit the modified .gitignore, because should be untracked in the subtree-main repo.
#if [ -n "${subtree_main_dir}" ]; then
#    echo "Adding \"\" to .gitignore..."
#    echo "" >> ${subtree_main_path}/.gitignore
#fi
