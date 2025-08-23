#!/bin/bash

## This script configures a Linux kernel source for Droidian.
#
# Version_0.0.3
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


script_consts_load() {
    ## Defauls to get the constants config script
    script_consts_file_name="config-consts-subtree-initiators.sh"
    script_consts_file_url_base="https://raw.githubusercontent.com/berbascum/droidian-kernel-build-helper-scripts/refs/heads/droidian"

    ## Search for flags to override defaults
    ## --script-consts-file-name
    FLAG_TYPE="value"
    flag_name="script-consts-file-name"
    fn_bbgl_check_args_search_flag $@
    [ -n "${FLAG_FOUND_VALUE}" ] \
        && script_consts_file_name="${FLAG_FOUND_VALUE}"
    ## --script-consts-file-url-base
    FLAG_TYPE="value"
    flag_name="script-consts-file-url-base"
    fn_bbgl_check_args_search_flag $@
    [ -n "${FLAG_FOUND_VALUE}" ] \
        && script_consts_file_url="${FLAG_FOUND_VALUE}"
    debug "Script consts file name: ${script_consts_file_name}"
    debug "Script consts url base: ${script_consts_file_url_base}"
    ## Download the constants config script
    if [ ! -f "${script_consts_file_name}" ]; then
        wget ${script_consts_file_url_base}/${script_consts_file_name} || error "Download ${script_consts_file_name} failed!"
    fi
    ## Source the constants config script
    . ${script_consts_file_name}
}

subtree_initiator_shared_set_vars_logic() {
    ## Set var for curl search pattern (might be by other tools)
    script_name_subtree_init_search_pattern="^${script_basename_subtree_init}.*\.sh$"

    ## Define git urls basedd on protocol/service
    ## ssh/https raw/api
    ## Required by the below url vars
    git_user="${git_user_subtree_init}"
    repo_name="${repo_name_subtree_init}"
    git_protocols_def

    ## url vars for git and curl operations
    repo_url_subtree_init_branch_api="${repo_url_api}/?ref=${repo_branch_subtree_init}"
    repo_url_subtree_init_branch_raw="${repo_url_raw}/${repo_branch_subtree_init}"
}

bbl_integration() {
    ## Configure bbl libs
    bbl_path="/usr/lib/berb-bash-libs"
    ## bbl-general
    bbl_general_version="1121"
    bbl_general_filenaame="bbl_general_lib_${bbl_general_version}"
    ## Load libs
    LOG_FULLPATH="${HOME}/logs/${TOOL_NAME}"

    ## Load required bbl-general function groups
    . ${bbl_path}/${bbl_general_filenaame} verbose
    . ${bbl_path}/${bbl_general_filenaame} script-args
    . ${bbl_path}/${bbl_general_filenaame} environment

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

help_quick() {
    echo; echo "Quick Help:"
    echo
    fn_bbgl_help_log_level
    echo
    fn_bbgl_help_log_enable
    echo
    help_script_args
}

help_script_args() {
    ## Help for --script-consts-file-name flag
    echo "* --script-consts-file-name=<value>"
    echo "    Overrides the default script"
    echo "    name to use to configure the"
    echo "    main script consts"
    echo
    ## Help for --script-consts-file-url-base flag
    echo "* --script-consts-file-url-base=<value>"
    echo "    Overrides the default url for"
    echo "    downloading the script used to"
    echo "    configure the main script consts"
    echo "  Format:"
    echo "  https://raw.githubusercontent.com/"
    echo "  <USER>/<REPO_NAME>/refs/heads/<BRANCH_NAME>"
}

check_dir_reqs() {
    # Check if the current dir is a git repo
    [ -d ".git" ] || abort "Not in a git repo!"

    # Check if the current dir is a kernel source dir
    [ -f Kconfig -a -f Makefile -a -d kernel -a -d arch ] || abort "Not in a kernel source dir!"
}
export -f check_dir_reqs

check_bin_reqs() {
    ## Required binaries
    which curl > /dev/null || abort "Please install the curl package"
    which git > /dev/null || abort "Please install the git package"
    which jq > /dev/null || abort "Please install the jq package"
    dpkg -l | grep "bbl-general-lib" > /dev/null  || abort "Please install the bbl-general-lib package"
}
export -f check_bin_reqs

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
    export repo_url_proto="https://github.com/${git_user}"
    export repo_url_api="https://api.github.com/repos/${git_user}/${repo_name}/contents"
    export repo_url_raw="https://raw.githubusercontent.com/${git_user}/${repo_name}/refs/heads"
}
export -f git_protocols_def

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

git_branch_exists() {
    ## Check if the specified branch exists
    branch_found=$(git ls-remote --heads ${repo_url} | grep "/${repo_branch}$" | awk -F'/' '{print $NF}')
    if [ -n "${branch_found}" ]; then
        echo "Specified branch found on remote: \"${branch_found}\""
    else
        echo; echo "The specified branch \"${branch_arg}\" does not exist on the remote"
        if [ "${repo_access}" != "public" ]; then
            echo "Might be a pinentry fail. Set pinentry-[gnome3|qt] instead [tty|curses] in gpg-agent.conf"
        fi
        abort "Failure checking remote branch ${branch_arg}"
    fi
}
export -f git_branch_exists

subtree_initiator_shared_exec() {
    ## Load the vars related to the repo config logic
    subtree_initiator_shared_set_vars_logic
    ## Search and download the initiator script
    subtree_initiator_script_search_dload

    ## Configure script permissions
    chmod +x ${dir_dload}/${script_name_subtree_init}
    ## Execute the subtree initiator script
    echo; echo "Starting execution: ${script_name_subtree_init}"
    ${dir_dload}/${script_name_subtree_init} $@
}

subtree_initiator_dkpt_exec() {
    ## Load the subtree initiator repo configuration vars
    subtree_initiator_dkpt_set_vars
    export subtree_path="${subtree_dkpt_path}"
    ## Call the subtree initiator exec function
    subtree_initiator_shared_exec $@
}

## Check that all required binaries are avaliable
check_bin_reqs
## Load the bbl integration function
bbl_integration $@
## Load consts from the config script
script_consts_load $@
## Check current dir reqs like git and kernel source
check_dir_reqs
## Load the subtree initiatos function for dkpt
subtree_initiator_dkpt_exec $@
