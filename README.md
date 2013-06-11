Gyc
===

Wrapper around `git` to manage system configuration files in GIT repositories.

Two different repositories

User repository
---------------

To store 'user' configuration, mainly dot files like rc files, no private datas.
There could be one for each user.

It is meant to be stored on a public repository for sharing with other Linux Users.

Alias: `gyc`

System repository
-----------------

To store 'system' configuration, like system programs configuration files.
Run as root with sudo to handle permissions issues.
There should be one for the all system.

Goal: track the system configuration and permit users to experiment some complex configurations.

Alias: `sgyc`


Install
-------

Setup the following variable in the `install.sh` file if you want to change them

    GYC_WORK_TREE='/'
    GYC_GIT_DIR="${HOME}/.gyc/git_bare"

Run `install.sh` and add the printed `alias` line to your .rc file


Features
--------

* creation command                         -> OK, ready for comments
* share repository between all computers   -> branches named as hostname
* try to detect "password" stored in files -> Matching some patterns, see in hooks, ready for comments


