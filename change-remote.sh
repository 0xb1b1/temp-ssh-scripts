#!/bin/bash

# USAGE: This script changes the origin of your ATOM GitLab repository.
# Please use it on any repository that we have moved to the new ML Services subgroup.

check_if_git() {
    # Check if the currect directory is a git repository using the git command

    if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]; then
        return 0;
    else
        return 1;
    fi
}

main() {
    if check_if_git; then
        echo "You are in a git repository, proceeding..."
     else
         echo "You are not in a git repository, terminating..."
         exit 1
    fi

    # Get the current origin URL
    CURRENT_ORIGIN=$(git config --get remote.origin.url)  # Looks like ssh://git@gitlab.enigmagroup.tech:2224/enigma/machine-learning/jiggl/videoimages/thea_promethea.git

    # Check if origin URL is not empty
    if [ -z "${CURRENT_ORIGIN}" ]; then
        echo "Current origin is empty, terminating..."
        exit 1;
    fi

    echo "Current origin URL is ${CURRENT_ORIGIN}"

    # Get project name (last part with .git)
    PROJECT=${CURRENT_ORIGIN##*/}
    echo "Project name is ${PROJECT}"

    echo "Please grab your new origin URL from GitLab \(go to the repo, find the blue Code button and choose an appropriate option\)."
    echo "If you with to add OAUTH2 auth info to the URL, please do so manually — and paste the result below."
    read -rp "New origin URL: " NEW_ORIGIN
    echo "New origin URL is ${NEW_ORIGIN}"
    read -rp "Press Return to continue, or Ctrl+C to cancel..."

    # Set new origin
    echo "Setting new origin URL..."
    git remote set-url origin "${NEW_ORIGIN}"

    echo "Done. If you wish to check the result, run 'git remote -v' and look for the new origin URL."
    echo "To test the new remote address, run 'git fetch'."
}

main
