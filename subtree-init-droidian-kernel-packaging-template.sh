#!/bin/bash

## Script to add droidian kernel packaging templates as git subtree
#
# Version 0.0.1
#
# Upstream-Name: droidian-kernel-build-helper-scripts
# Source: https://github.com/berbascum/droidian-kernel-build-helper-scripts/tree/subtree-init/droidian-kernel-packaging-templates
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
if [ -z "${subtree_dkpt_path}" ]; then
    echo "This script must be called from the main configure-kernel-source-for-droidian.sh"
    exit 1
fi


check_arg() {
    for arg in $@; do
        arg_found="$(echo "${arg}" | grep "\-\-${search_arg_str}" | awk -F'=' '{print $2}')"
        [ -n "${arg_found}" ] && break
    done
}

subtree_init_dkpt_set_vars() {
    ## Git user/organization
    [ -z "${git_user_repo_dkpt}" ] && \
        git_user_repo_dkpt="berbascum"
    ## Dir where subtree will be initiated
    [ -z "${subtree_dkpt_dir}" ] && \
        subtree_dkpt_dir="droidian-kernel-packaging"
    [ -z "${subtree_dkpt_path}" ] && \
        subtree_dkpt_path="${subtree_dkpt_dir}"
    ## Repo name vars
    [ -z "${repo_name_dkpt}" ] && \
        repo_name_dkpt="droidian-kernel-packaging-templates"
    ## Branch name vars
    [ -z "${repo_branch_name_dkpt}" ] && \
        repo_branch_name_dkpt="" # Arg supplied, skipped
    ## Set the subtree git remote name
    git_remote_name="origin-Kpackaging"

    ## Initialize the git args
    [ -n "${git_args_subtree_dload_dkpt}" ] && git_args="${git_args_dkpt}" || git_args=""
}

subtree_init_dkpt_exec() {
    ## Check for --template-branch-dkpt arg
    search_arg_str='template-branch-dkpt='
    check_arg $@
    branch_arg="${arg_found}"
    [ -n "${branch_arg}" ] || abort "Missing --${search_arg_str}<name> arg"

    ## Set url vars for ssh/https raw/api
    git_user="${git_user_repo_dkpt}"
    repo_name="${repo_name_dkpt}"
    ## Returns repo_fslocal_proto|repo_url_proto
    if [ "${repo_git_mode_subtree_dkpt}" == "url" ]; then
        ## Set the url var
        repo_url="${repo_url_proto}/${repo_name}"
        git_protocols_def
        INFO "repo url defined = ${repo_url}"
    elif [ "${repo_git_mode_subtree_dkpt}" == "fs-local" ]; then
        repo_fslocal_path="${repo_git_fslocal_path_subtree_dkpt}"
        git_protocols_def
        INFO "repo fslocal path defined = ${repo_fslocal_path}"
        INFO "repo fslocal (proto) defined = ${repo_fslocal_proto}"
    fi

    ## Check if the specified branch exists
    repo_branch="${branch_arg}"
    #repo_url= Defined above, after git_protocols_def

    git_branch_exists
    template_branch_dkpt="${branch_found}"
    info  "template_branch_dkpt = ${template_branch_dkpt}"

    ## Add the repo as git remote
    if [ "${repo_git_mode_subtree_dkpt}" == "url" ]; then
        git remote add -f ${git_remote_name} ${repo_url}
    elif [ "${repo_git_mode_subtree_dkpt}" == "fs-local" ]; then
        git remote add -f ${git_remote_name} ${repo_fslocal_path}
    fi

    git subtree add --prefix=${subtree_dkpt_path} ${git_remote_name} ${template_branch_dkpt} ${git_args} || abort "Subtree download failed!"

    ./${subtree_dkpt_path}/gitignore-kernel-droidian-patcher.sh
    info "Adding and committing the patched .gitignore..."
    git add .gitignore
    git commit -m "(gitignore) droidian: patch Droidian tracking rules"

    info "Creating required symbolic links..."
    ln -sv ${subtree_dkpt_path}/droidian/ droidian
    ln -sv ${subtree_dkpt_path}/debian/ debian

    mkdir -v ${subtree_dkpt_path}/scripts
}

## Start subtree initialization if not done yet.
subtree_init_dkpt_set_vars
if [ -d "${subtree_dkpt_path}" ]; then
    INFO "Dir ${subtree_dkpt_path} found. Skipping subtree_init_dkpt..."
else
    check_bin_reqs
    check_bin_reqs
    subtree_init_dkpt_exec $@
fi
