#! /usr/bin/env bash

##  
##  MANUAL PAGE
##      @{THIS_SCRIPT_NAME}
##  
##  USAGE
##      @{THIS_SCRIPT_NAME} [options]
##  
##  DESCRIPTION
##      Deploys the frontend site.
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

function main()
{
    cd "${THIS_SCRIPT_DIR_PATH}"/..

    mkdir -p _frontend
    cp -r frontend/. _frontend
}

parse_cli "$@"
main
