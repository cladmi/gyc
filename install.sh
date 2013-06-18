#! /bin/bash
#
# git@github.com:cladmi/gyc.git
#
set -u   # error with undefined variables
SCRIPT_FOLDER="$(dirname $0)"


GYC_WORK_TREE="${HOME}/"
GYC_GIT_DIR="${HOME}/.gyc/git_bare/"

S_GYC_WORK_TREE="/"
S_GYC_GIT_DIR="/var/lib/sgyc/"


# # Create or update repository in $GYC_GIT_DIR # #
__create_gyc_repository() {
        WORK_TREE=$1
        GIT_DIR=$2

        echo "Create gyc repository with"
        echo "    root_dir = '${WORK_TREE}'"
        echo "    git_dir  = '${GIT_DIR}'"

        mkdir -p $(dirname ${GIT_DIR})
        test -d ${GIT_DIR} && echo "Updating existing repository '${GIT_DIR}"

        __setup_gyc_repository
}


__add_exclude_pattern()  {
        pattern=$1
        comment=$2
        excl_file=$3
        grep -F "$pattern" "$excl_file"  | grep  -v '^ *#'
        if [ $? -ne 0 ]; then
                echo "# $comment"  >> $EXCL
                echo "$pattern"    >> $EXCL
        fi


}

#
# Configure repository,
#    can be re-run if no modifications have been hand made to the repository
#
__setup_gyc_repository() {
        WORK_TREE=$1
        GIT_DIR=$2
        GYC="git --git-dir=${GIT_DIR} --work-tree=${WORK_TREE}"

        # init/reinit repository
        $GYC init > /dev/null
        # alias to add files
        #   by default all files are excluded so -f is required to add
        $GYC config alias.fadd 'add -f'

        __add_exclude_pattern  '*'          "Exclude all files by default, to add files, use '-f'"  "${EXCL}"

        # Use hostname as branch name
        $GYC branch | grep -q " ${HOSTNAME}$" 2> /dev/null # test branch exist
        if [ $? -ne 0 ]; then
                $GYC checkout -b ${HOSTNAME} 2>/dev/null
        fi


}


create_gyc_repository() {
        WORK_TREE="$GYC_WORK_TREE"
        GIT_DIR="$GYC_GIT_DIR"
        EXCL="${GIT_DIR}/info/exclude"
        __create_gyc_repository  "$WORK_TREE"  "$GIT_DIR"


        # Hooks to match unwanted files in a public repository

        # TODO   add checking file permissions like: .ssh/ folder  go with no read permission
        cp -r ${SCRIPT_FOLDER}/hooks ${GIT_DIR}/
}

create_s_gyc_repository() {
        WORK_TREE="$S_GYC_WORK_TREE"
        GIT_DIR="$S_GYC_GIT_DIR"
        EXCL="${GIT_DIR}/info/exclude"
        __create_gyc_repository  "$WORK_TREE"  "$GIT_DIR"

        __add_exclude_pattern  '!*.pacnew'  "Include '.pacnew' to show files that need update on archlinux"  "${EXCL}"


        echo
        echo 'Add the following alias to your .bashrc/.zshrc/.yourrc file and source it to add alias'
        echo
        echo $(alias gyc)
}



