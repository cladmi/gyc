Gyc
===

Wrapper around `git` to manage system configuration files in a repository.


Install
-------

Setup the following variable in the `install.sh` file if you want to change them

    GYC_WORK_TREE='/'
    GYC_GIT_DIR="${HOME}/.gyc/git_bare"

Run `install.sh` and add the `alias` line to your .rc file


Features
--------

* creation command                         -> In progress
* share repository between all computers   -> branches named as hostname
* try to detect "password" stored in files -> Matching some patterns, see in hooks

* write permissions when pulling ?
* when to pull for news ?

