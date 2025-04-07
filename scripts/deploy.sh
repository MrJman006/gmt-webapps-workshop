#! /usr/bin/env bash

##  
##  MANUAL PAGE
##      @{THIS_SCRIPT_NAME}
##  
##  USAGE
##      @{THIS_SCRIPT_NAME} [options]
##  
##  DESCRIPTION
##      Deploys each directory to the website hosting associated with
##      this GitHub repo (https://mrjman006.github.io/gmt-webapps-workshop).
##  
##  OPTIONS
##      -h|--help
##          Show this manual page.
##  
##  END
##      

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

readonly THIS_SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
readonly THIS_SCRIPT_DIR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly LIVE_DOMAIN_URL="https://mrjman006.github.io/gmt-webapps-workshop"

function show_manual_page()
{
    grep -E "^##  " "${THIS_SCRIPT_DIR_PATH}/${THIS_SCRIPT_NAME}" |
        sed -E "s/^##  //" |
        sed -E "s/@\{THIS_SCRIPT_NAME\}/${THIS_SCRIPT_NAME}/g"
}

function parse_cli()
{
    #
    # Parse options.
    #

    if $(echo "$@" | grep -Eq "(^|\s)(-h|--help)(\s|$)")
    then
        show_manual_page
        exit 1
    fi

    while [ $# -gt 0 ]
    do
        local token="${1}"

        case "${token}" in
            --)
                shift
                break
                ;;
            -?)
                echo "Invalid option '${token}'. Need --help?"
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
}

function check_for_uncommited_changes()
{
    if $(git status | grep -Pq "Changes not staged for commit")
    then
        echo "Error: The repo has non-commited changes. Either discard them or stash them before attempting to deploy."
        return 1
    fi
}

function stage_all_lessons()
{
set -x
    mkdir -p _stage

    local LESSON_DIR_PATH
    for LESSON_DIR_PATH in $(find -maxdepth 1 -name "lesson-*" | sort)
    do
        local LESSON_NAME="$(basename "${LESSON_DIR_PATH}")"
    
        #
        # Stage the lesson site files.
        #
   
        if [ -e "${LESSON_DIR_PATH}"/frontend ]
        then
            "${LESSON_DIR_PATH}"/scripts/build-frontend-site.sh
            mkdir -p _stage/"${LESSON_NAME}"
            cp -r "${LESSON_DIR_PATH}"/_frontend/. _stage/"${LESSON_NAME}"
        else
            mkdir -p _stage/"${LESSON_NAME}"
            cp -r "${LESSON_DIR_PATH}"/. _stage/"${LESSON_NAME}"
        fi
    
        #
        # Change localhost links.
        #
    
        find "_stage/${LESSON_NAME}" -type f |
            xargs -L 1 sed -Ei "s|http://127.0.0.1:9999|${LIVE_DOMAIN_URL}/${LESSON_NAME}|g"
    
        #
        # Add a link for the lesson site to the root index.
        #
    
        echo "<a href=\"${LESSON_NAME}\">${LESSON_NAME}</a><br>" >> _stage/index.html
    done
set +x
}

#function stageLatestLessonSite()
#{
#    local LATEST_LESSON_PATH="$(find . -maxdepth 1 -name "lesson-*" | sort | tail -n 1)"
# 
#    #
#    # Stage the lesson site files.
#    #
#   
#    if [ -e "${LATEST_LESSON_PATH}/frontend" ]
#    then
#        rsync -ai "${LATEST_LESSON_PATH}/_frontend/" _stage/latest
#    else
#        rsync -ai "${LATEST_LESSON_PATH}/" _stage/latest
#    fi
#
#    #
#    # Remove unnecessary files.
#    #
#
#    local FILE_LIST=()
#
#    FILE_LIST+=("_stage/latest/README.md")
#    FILE_LIST+=("_stage/latest/package.json")
#
#    local FILE
#    for FILE in "${FILE_LIST[@]}"
#    do
#        [ -e "${FILE}" ] && rm "${FILE}"
#    done
#
#    #
#    # Change localhost links.
#    #
#    
#    find "_stage/latest" -type f -exec sed -ri "s|http://127.0.0.1:9999|https://mrjman006.github.io/gmt-webapps-workshop/latest|g" {} \;
#    
#    #
#    # Add a link for the lesson site to the root index.
#    #
#    
#    echo "<a href=\"latest\">latest</a><br>" >> "_stage/index.html"
#}
#
#function deployStagedSites()
#{
#    #
#    # GitHub Pages are automatically deployed for files in a remote branch
#    # called 'gh-pages'. So we need to add just the staged site files to the
#    # named branch and GitHub will take care of the rest.
#
#    #
#    # Commit the staging directory so we can add the staged files to the
#    # 'gh-pages' remote branch. Save the previous HEAD state so we can remove
#    # the staging commit from the history when we are done.
#    #
#    
#    local ORIGINAL_HEAD="$(git rev-parse --short HEAD)"
#    git add --force _stage
#    git commit -m "Deploying staged lesson sites." 
#  
#    # 
#    # Remove old versions of the 'gh-pages' remote branch. 
#    #
#
#    git push -d origin gh-pages
#
#    #
#    # Push just the contents of the staging directory to the 'gh-pages' remote
#    # branch.
#    #
#
#    git subtree push --prefix _stage origin gh-pages
#    
#    #
#    # Now that the staged files are deployed, we can restore the git repo
#    # to it's original state.
#    #
#    
#    git reset --hard "${ORIGINAL_HEAD}"
#}

function main()
{
    :

    check_for_uncommited_changes
    stage_all_lessons

    #stageLessonSites || return $?
   
    #stageLatestLessonSite || return $?

    #deployStagedSites || return $?
}

parse_cli "$@"
main
