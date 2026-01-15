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

## TODO: Some rewrites are required to use this script as standalone.
if [ -z "${subtree_dkcf_path}" ]; then
    echo "This script must be called from the main configure-kernel-source-for-droidian.sh"
    exit 1
fi

subtree_init_dkcf_set_vars() {
    ## Set the subtree git remote name
    git_remote_name="upstream-common_fragments"
    debug  "${FUNCNAME[0]}: ${subtree_name}: Defined git_remote_name = ${git_remote_name}"

    ## Set url vars for ssh/https raw/api
    repo_name="${repo_git_name_stuff}"
    debug  "${FUNCNAME[0]}: ${subtree_name}: Defined repo_name = ${repo_name}"
    git_args="${git_args_repo_subtree_stuff}"
    debug  "${FUNCNAME[0]}: ${subtree_name}: Defined git_args = ${git_args}"

    ## Conditional url vars protocols_def
    if [ "${repo_git_mode_stuff}" == "url" ]; then
        ## Set git user
        git_user="${git_user_repo_stuff}"
        debug  "${FUNCNAME[0]}: ${subtree_name}: Defined git_user = ${git_user}"
        ## Set repo url
        git_protocols_def
        repo_url="${repo_url_proto}/${repo_name}"
        INFO "repo url defined = ${repo_url}"
    ## Conditional fs-local vars protocols_def
    elif [ "${repo_git_mode_stuff}" == "fs-local" ]; then
        repo_fslocal_path="${repo_git_fslocal_path_subtree}"
        debug  "${FUNCNAME[0]}: ${subtree_name}: Defined repo_fslocal_path = ${repo_fslocal_path}"
        git_protocols_def
        INFO "repo fslocal path defined = ${repo_fslocal_path}"
        INFO "repo fslocal (proto) defined = ${repo_fslocal_proto}"
    fi

    ## Set subtree_path
    if [ -n "${subtree_dkcf_path}" ]; then
        subtree_path="${subtree_dkcf_path}"
    else
        subtree_path="${subtree_dir}"
        ## Avoid continue if the droidian dir in the kernel source
        ## root dir is a symlink and this script runs as standalone.
        test -L droidian && error "The droidian dir in the kernel source root dir is a symlink. Aborting!"
    fi
}

subtree_init_dkcf_exec() {
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

    [ -n "${KERNEL_VERSION}" ] || error "$(basename $0): Missing --kver=<MA-VER>.<mi.ver> arg"

    ## Check if the specified branch exists
    repo_branch_name="${KERNEL_VERSION}-android\$|${KERNEL_VERSION}-android-common\$"
    #repo_url= Defined above, after git_protocols_def

    git_branch_exists
    repo_branch_name="${branch_found}"
    info  "repo_branch_name = \"${repo_branch_name}\""
    # OLD branch_found=$(git ls-remote --heads ${repo_url} | grep -E "${KERNEL_VERSION}-(android|android-common)" | awk -F'/' '{print $NF}')

    ## Check if exist a branch for the specified kernel version
    [ -n "${branch_found}" ] || error "$(basename $0): The specified common_fragments branch \"${branch_found}\" does not exist"

    ## Add the repo as git remote
    if [ "${repo_git_mode_stuff}" == "url" ]; then
        debug  "${FUNCNAME[0]}: ${subtree_name}: Adding remote \"${git_remote_name}\" \"${repo_url}\""
        git remote add -f --no-tags ${git_remote_name} ${repo_url}
    elif [ "${repo_git_mode_stuff}" == "fs-local" ]; then
        debug  "${FUNCNAME[0]}: ${subtree_name}: Adding remote \"${git_remote_name}\" \"${repo_fslocal_path}\""
        git remote add -f --no-tags ${git_remote_name} ${repo_fslocal_path}
    fi

    debug "Command init subtree: git subtree add --prefix=subtree_dkcf_path=\"${subtree_dkcf_path}\" git_remote_name=\"${git_remote_name}\" \"${branch_found}\" git_args=\"${git_args}\""
    git subtree add --prefix=${subtree_dkcf_path} ${git_remote_name} ${branch_found} ${git_args} || error "Subtree download failed!"
}

## Start subtree initialization if not done yet.
subtree_init_dkcf_set_vars
if [ -d "${subtree_dkcf_path}" ]; then
    INFO "Dir ${subtree_dkcf_path} found. Skipping subtree_init_dkcf..."
else
    check_bin_reqs
    subtree_init_dkcf_exec $@
fi
