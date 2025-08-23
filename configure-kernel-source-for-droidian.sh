#!/bin/bash

## This script configures a Linux kernel source for Droidian.
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


TOOL_NAME="cks-droidian"

subtree_initiator_dkpt_set_vars() {
    ## Subtree initiator repo name vars
    ## dkpt: droidian-kernel-packaging-templates
    ## This function contains the editable vars
    ## which will be the base for constructing the
    ## urls for the git and curl operations
    git_user="berbascum"
    repo_name_subtree_init="droidian-kernel-build-helper-scripts"
    repo_branch_subtree_init="subtree-init/droidian-kernel-packaging-templates"

    ## Set var script file name without extension
    ## Will be used by curl as base for pattern
    script_basename_subtree_init="subtree-init-droidian-kernel-packaging-template"
}

subtree_initiator_dkpt_set_vars_logic() {
    ## Set var for curl search pattern (might be by other tools)
    script_name_subtree_init_search_pattern="^${script_basename_subtree_init}.*\.sh$"

    ## Define git urls basedd on protocol/service
    ## ssh/https raw/api
    ## Required by the below url vars
    git_protocols_def

    ## url vars for git and curl operations
    repo_url_subtree_init_branch_api="${repo_url_api}/?ref=${repo_branch_subtree_init}"
    repo_url_subtree_init_branch_raw="${repo_url_raw}/${repo_branch_subtree_init}"
}

bbl_integration() {
    ## Configure and download bbl-general-lib
    bbl_general_version="1111"
    ## Download bbl-general from github
    wget -O /tmp/bbl_general_lib_${bbl_general_version} https://raw.githubusercontent.com/berbascum/bbl-general-lib/refs/heads/berb-develop/bbl_general_lib-main.sh
    if [ "$?" -ne "0" ]; then
        echo "bbl-general download failed!"
        exit 1
    fi
    ## Check expected/dloaded  bbl-general versions
    version_dloaded=$(grep "TOOL_VERSION_INT=\"1111\"$" /tmp/bbl_general_lib_${bbl_general_version} | awk -F'"' '{print $2}')
    version_expected="${bbl_general_version}"
    ## bbl-general expected must be ame as dloaded
    if [ "${version_expected}" != "${version_dloaded}" ]; then
        echo "Wrong bbl-general version. Expected: ${version_expected} but downloaded ${version_dloaded}"
        exit 1
    fi
    ## Load only the log-level and required functions
    BBL_LOAD_STAGE="log-level"
    ## Log path vars
    LOG_FULLPATH="${HOME}/logs/${TOOL_NAME}"
    ## Load libs
    . /tmp/bbl_general_lib_${bbl_general_version}
    ## Config log level
    FLAG_TYPE="value"
    fn_bbgl_config_log_level $@
    ## Config log
    FLAG_TYPE="empty"
    fn_bbgl_config_log $@
    ## Search for the --help$ flag in the arguments
    FLAG_TYPE="empty"
    fn_bbgl_help_check_flag $@
}

check_arg() {
    for arg in $@; do
        arg_found="$(echo "${arg}" | grep "\-\-${search_arg_str}" | awk -F'=' '{print $2}')"
        [ -n "${arg_found}" ] && break
    done
}
export -f check_arg

help_quick() {
    echo; echo "Quick Help:"
    echo
    fn_bbgl_help_log_level
    echo
    fn_bbgl_help_log_enable
}

check_dir_reqs() {
    # Check if the current dir is a git repo
    [ -d ".git" ] || abort "Not in a git repo!"

    # Check if the current dir is a kernel source dir
    [ -f Kconfig -a -f Makefile -a -d kernel -a -d arch ] || abort "Not in a kernel source dir!"
}

check_bin_reqs() {
    ## Required binaries
    which curl > /dev/null || abort "Please install the curl package"
    which git > /dev/null || abort "Please install the git package"
    which jq > /dev/null || abort "Please install the jq package"
}

subtree_initiator_print_repo_vars() {
    ## Print repo vars
    echo
    echo "Repository config vars:"
    echo
    echo  "- repo_name_subtree_init = ${repo_name_subtree_init}"
    echo  "- repo_branch_subtree_init = ${repo_branch_subtree_init}"
    echo  "- repo_url_subtree_init = ${repo_url_subtree_init}"
    echo  "- script_name_subtree_init = ${script_name_subtree_init}"
}

curl_gh_search_list_matching_files() {
    echo; echo "Searching files matching the pattern: ${file_pattern}"
    echo "url: ${url}"
    mapfile -t repo_files_found < <(
      curl -s --fail \
        ${url} | \
      jq -r --arg pattern "${file_pattern}" \
        '.[] | select(.type=="file" and (.name|test($pattern))) | .name')
    ## Check the resulting array
    if [ "${#repo_files_found[@]}" -eq "0" ]; then
        ## Print vars on error
        ${print_vars}
        abort "No files found matching the pattern"
    else
        echo "Files found:"
        printf '%s\n' ${repo_files_found[@]}
    fi
}

curl_gh_file_dload() {
    echo; echo "Starting curl download: ${file}"
    curl -s --fail ${url} -o ${dir_dload}/${file}
    if [ "$?" -eq "0" ]; then
        echo "Success: curl download: ${file}"
    else
        ## Print vars on error
        ${print_vars}
        abort "Failure: curl download: ${file}"
    fi
}
export -f curl_gh_file_dload

git_protocols_def() {
    ## github protocols
    export repo_url_proto='https://github.com/'
    export repo_url_api="https://api.github.com/repos/${git_user}/${repo_name_subtree_init}/contents"
    export repo_url_raw="https://raw.githubusercontent.com/${git_user}/${repo_name_subtree_init}/refs/heads"
}

subtree_initiator_script_search_dload() {
    ## Search for the initiator script
    file_pattern="${script_name_subtree_init_search_pattern}"
    url="${repo_url_subtree_init_branch_api}"
    print_vars="subtree_initiator_print_repo_vars"
    curl_gh_search_list_matching_files
    if [ "${#repo_files_found[@]}" -gt "1" ]; then
        echo "Many files found but one is expected!"
    fi
    script_name_subtree_init="${repo_files_found[0]}"

    ## Download the initiator script
    repo_url_subtree_init="${repo_url_subtree_init_branch_raw}/${script_name_subtree_init}"
    url="${repo_url_subtree_init}"
    file=${script_name_subtree_init}
    dir_dload="/tmp"
    print_vars="subtree_initiator_print_repo_vars"
    curl_gh_file_dload
}

subtree_initiator_dkpt_exec() {
    ## Load the subtree initiator repo configuration vars
    subtree_initiator_dkpt_set_vars
    ## Load the vars related to the repo config logic
    subtree_initiator_dkpt_set_vars_logic
    ## Check that all required binaries are avaliable
    check_bin_reqs
    ## Search and download the initiator script
    subtree_initiator_script_search_dload

    ## Execute the subtree initiator script
    chmod +x ${dir_dload}/${script_name_subtree_init}
    echo; echo "Starting execution: ${script_name_subtree_init}"
    export subtree_path="droidian-kernel-packaging"
    ${dir_dload}/${script_name_subtree_init} $@
}

## Load the bbl integration function
bbl_integration $@
## Check current dira requirements like git and kernel source
check_dir_reqs
## Load the subtree initiatos function for dkpt
subtree_initiator_dkpt_exec $@
