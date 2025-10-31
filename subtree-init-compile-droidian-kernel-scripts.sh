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


## TODO: Some rewrites are required to use this script as standalone.
if [ -z "${subtree_cdks_path}" ]; then
    echo "This script must be called from the main configure-kernel-source-for-droidian.sh"
    exit 1
fi

## TODO: upgrade to git_protocol
repository_url="https://github.com/berbascum/droidian-kernel-build-helper-scripts"

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

subtree_init_cdks_set_vars() {
    ## Git user/organization
    [ -z "${git_user_repo_cdks}" ] && \
        git_user_repo_cdks="berbascum"
    ## Dir where subtree will be initiated
    [ -z "${subtree_cdks_dir}" ] && \
        subtree_cdks_dir="droidian/scripts/build-kernel"
    [ -z "${subtree_cdks_path}" ] && \
        subtree_cdks_path="${subtree_cdks_dir}"
    ## Repo name vars
    [ -z "${repo_name_cdks}" ] && \
        repo_name_cdks="droidian-kernel-build-helper-scripts"
    ## Branch name vars
    [ -z "${repo_branch_name_cdks}" ] && \
        repo_branch_name_cdks="helper/compile-droidian-kernel-scripts"
    ## Set the subtree git remote name
    git_remote_name="origin-Kcompile-helper"

    ## Initialize the git args
    [ -n "${git_args_subtree_dload_cdks}" ] && git_args="${git_args_cdks}" || git_args="--squash"
}

subtree_init_cdks_exec() {
    ## Set url vars for ssh/https raw/api
    git_user="${git_user_repo_cdks}"
    repo_name="${repo_name_cdks}"
    ## Returns repo_fslocal_proto|repo_url_proto
    if [ "${repo_git_mode_subtree_cdks}" == "url" ]; then
        ## Set the url var
        repo_url="${repo_url_proto}/${repo_name}"
        git_protocols_def
        INFO "repo url defined = ${repo_url}"
    elif [ "${repo_git_mode_subtree_cdks}" == "fs-local" ]; then
        repo_fslocal_path="${repo_git_fslocal_path_subtree_cdks}"
        git_protocols_def
        INFO "repo fslocal path defined = ${repo_fslocal_path}"
        INFO "repo fslocal (proto) defined = ${repo_fslocal_proto}"
    fi

    ## Check if the specified branch exists
    repo_branch_name="${repo_branch_name_cdks}"
    #repo_url= Defined above, after git_protocols_def

    git_branch_exists
    info  "repo_branch_name = ${repo_branch_name}"


    ## Add the repo as git remote
    if [ "${repo_git_mode_subtree_cdks}" == "url" ]; then
        git remote add -f ${git_remote_name} ${repo_url}
    elif [ "${repo_git_mode_subtree_cdks}" == "fs-local" ]; then
        git remote add -f ${git_remote_name} ${repo_fslocal_path}
    fi

    git subtree add --prefix=${subtree_cdks_path} ${git_remote_name} ${repo_branch_name} ${git_args} || abort "Subtree download failed!"
}

## Start subtree initialization if not done yet.
subtree_init_cdks_set_vars
if [ -d "${subtree_cdks_path}" ]; then
    INFO "Dir ${subtree_cdks_path} found. Skipping subtree_init_cdks..."
else
    check_bin_reqs
    subtree_init_cdks_exec $@
fi


## TODO: Add the subtree dir to the subtree-main .gitignorewhet required
## Don't commit the modified .gitignore, because should be untracked in the subtree-main repo.
#if [ -n "${subtree_main_dir}" ]; then
#    echo "Adding \"\" to .gitignore..."
#    echo "" >> ${subtree_main_path}/.gitignore
#fi
