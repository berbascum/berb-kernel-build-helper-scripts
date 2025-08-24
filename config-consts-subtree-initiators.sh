#!/bin/bash

## Functions to set the configurator script required constants

## dkpt: Subtree initiator repo name consts
## droidian-kernel-packaging-templates
subtree_initiator_dkpt_set_consts() {
    initiator_name="dkpt"
    info "Loading subtree initiator ${initiator_name} constants..."
    ## Git user/organization
    git_user_subtree_init_dkpt="berbascum"
    ## Repo names vars
    repo_name_subtree_init_dkpt="droidian-kernel-build-helper-scripts"
    ## Branch names vars
    repo_branch_subtree_init_dkpt="subtree-init/droidian-kernel-packaging-templates"
    ## Script file name without extension
    ## Will be used by curl as base for pattern
    script_basename_subtree_init_dkpt="subtree-init-droidian-kernel-packaging-template"

    ## Repository to download as subtree constants
    git_user_repo_dkpt="berbascum"
    repo_name_dkpt="droidian-kernel-packaging-templates"
    # export repo_branch_name_dkpt="" ## Arg supplied
    ## Dir where subtree will be initiated
    subtree_dkpt_dir="droidian-kernel-packaging"
    subtree_dkpt_path="${subtree_dkpt_dir}"
    ## args for the git subtree command
    git_args_dkpt=''
}
