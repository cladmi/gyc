#! /bin/bash
#
# git@github.com:cladmi/gyc.git
#

# change to the install folder
SCRIPT_FOLDER="$(dirname $0)"

GYC_WORK_TREE='/'
GYC_GIT_DIR="${HOME}/.gyc/git_bare"

alias gyc="git --git-dir=${GYC_GIT_DIR} --work-tree=${GYC_WORK_TREE}"
GYC="git --git-dir=${GYC_GIT_DIR} --work-tree=${GYC_WORK_TREE}"


#
# Create or update repository in $GYC_GIT_DIR
#
__create_gyc_repository() {
    echo "Create gyc repository with
        root_dir = '${GYC_WORK_TREE}'
        git_dir  = '${GYC_GIT_DIR}'"

    mkdir -p $(dirname ${GYC_GIT_DIR})

    if [ -e ${GYC_GIT_DIR} ]; then
        echo "Updating existing repository '${GYC_GIT_DIR}"
    fi

    __setup_gyc_repository

}

#
# Configure repository,
#    can be re-run if no modifications have been hand made to the repository
#
__setup_gyc_repository() {

    # init/reinit repository
    $GYC init > /dev/null

    # Exclude all files by default
    EXCL=${GYC_GIT_DIR}/info/exclude
    grep -q '^\*$' $EXCL 2> /dev/null # only * in line
    if [ $? -ne 0 ]; then
        echo '# Exclude all files by default, to add files, use "-f"' >> $EXCL
        echo '*' >> $EXCL
    fi

    # Use hostname as branch name
    $GYC branch | grep -q " ${HOSTNAME}$" 2> /dev/null # test branch exist
    if [ $? -ne 0 ]; then
        $GYC checkout -b ${HOSTNAME} 2>/dev/null
    fi

    # alias to add files
    #   by default all files are excluded so -f is required to add
    $GYC config alias.fadd 'add -f'

    # Hooks to match files
    cp -r ${SCRIPT_FOLDER}/hooks ${GYC_GIT_DIR}/

}


__create_gyc_repository

echo
echo 'Add the following alias to your .bashrc/.zshrc/.yourrc file and source it to add alias'
echo
echo $(alias gyc)

