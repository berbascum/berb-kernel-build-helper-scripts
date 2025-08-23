#!/bin/bash

## Functions to set the configurator script required constants

## dkpt: Subtree initiator repo name vars
## droidian-kernel-packaging-templates
subtree_initiator_dkpt_set_vars() {
    initiator_name="dkpt"
    info "Loading subtree initiator ${initiator_name} constants..."
    ## Git user/organization
    git_user_subtree_init="berbascum"
    export git_user_repo_dkpt="berbascum"
    ## Repo names vars
    repo_name_subtree_init="droidian-kernel-build-helper-scripts"
    export repo_name_dkpt="droidian-kernel-packaging-templates"
    ## Branch names vars
    repo_branch_subtree_init="subtree-init/droidian-kernel-packaging-templates"
    # export repo_branch_name_dkpt="" ## Arg supplied
    ## Script file name without extension
    ## Will be used by curl as base for pattern
    script_basename_subtree_init="subtree-init-droidian-kernel-packaging-template"
    ## Dir where subtree will be initiated
    export subtree_dkpt_dir="droidian-kernel-packaging"
    export subtree_dkpt_path="${subtree_dkpt_dir}"
}
