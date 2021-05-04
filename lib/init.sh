die() {
    echo "error:" "${@}"
    exit 1
}

if ! [[ -d "${WP_DATA_PATH}" ]]; then
    die "WP_DATA_PATH not set or is not a directory!"
fi

if ! [[ -d "${WP_PLATFORM_PATH}" ]]; then
    die "WP_PLATFORM_PATH not set or is not a directory!"
fi

WPDEBUG="${WPDEBUG:-0}"
WP_INTERACTIVE="${WP_INTERACTIVE:-0}"
WP_PATH_AT_INIT="${PATH}"
CACHE_DIR="${WP_PLATFORM_PATH}/cache"
FILES_DIR="${WP_PLATFORM_PATH}/files"
WP_INHERITS=()
WP_PRESET_STACK=()
PS1="(winepreset) ${PS1}"

export WINEPREFIX="${WP_DATA_PATH}/prefix"
# e.g. winetricks uses this
export WINE="$(which wine)"

inherit() {
    for el in "${@}"; do
        wp_do_inherit "${el}"
    done
}

debug() {
    if [[ "${WPDEBUG}" -ge "$1" ]]; then
        shift
        echo "debug:" "${@}"
    fi
}

EXPORT_FUNCTIONS() {
    local el

    for el in "${@}"; do
        eval "${el} () { $(wp_current_preset)_${el}; }"
    done
}

init() {
    :
}

setup() {
    echo "This preset does not have any predefined setup script!"
    echo "To get started, source the 'env' script in the newly created prefix."
    echo "It will set up environment variables necessary for Wine to run applications in"
    echo "the prefix. To execute programs, just use 'wine' as normal, the selected Wine"
    echo "version (if any) has been added to the PATH variable."
    echo "To create launch scripts, run mklaunch <name> <command...>"
}

dlcache() {
    if ! [[ -d "${CACHE_DIR}" ]]; then
        mkdir "${CACHE_DIR}"
    fi

    if ! [[ -f "${CACHE_DIR}/$1" ]]; then
        wget -O "${CACHE_DIR}/$1" "$2"
    fi
}

mklaunch() {
    file="$1"
    shift

    (
        echo '#!/bin/bash'
        echo
        echo 'set -e'
        echo 'source "$(dirname "$0")"/env'
        echo
        printf 'PROGRAM=('
        
        for arg in "${@}"; do
            printf "'%s' " "${arg}"
        done
        
        echo ')'
        echo 'EXEC_DIR="$(dirname "$(win2unixpath "${PROGRAM[0]}")")"'
        echo
        echo 'cd "${EXEC_DIR}"'
        echo 'exec wine "${PROGRAM[@]}" "${@}"'
    ) > "${WP_DATA_PATH}/${file}"
    
    chmod +x "${WP_DATA_PATH}/${file}"
}

win2unixpath() {
    if grep -iq '^[A-Z]:\\' <<< "$1"; then
        (
            cd "${WINEPREFIX}/dosdevices/" || return 1
            fpath="$(tr '\\' '/' <<< "$1")" || return 1
            wp_cicd "$(dirname "${fpath}")" || return 1
            file="$(wp_correct_case "$(basename "${fpath}")")" || return 1
            echo "${PWD}/${file}"
        )
    else
        echo "$1"
    fi
}

wp_cicd() {
    local savedpath parts first part found entry
    savedpath="${PWD}"

    if ! [[ "$ZSH_VERSION" = "" ]]; then
        parts=("${(s[/])1}")
    else
        IFS=/ read -raparts <<< "$1"
    fi

    first=0
    for part in "${parts[@]}"; do
        if [[ $first -eq 0 ]] && [[ "${part}" = "" ]]; then
            cd /
        fi

        case "${part}" in
            ""|".")
                ;;
            "..")
                cd ..
                ;;
            *)
                entry="$(wp_correct_case "${part}")"

                if [[ $? -eq 0 ]]; then
                    cd "${entry}"
                else
                    echo "wp_cicd: $1: No such file or directory" >&2
                    cd "${savedpath}"
                    return 1
                fi

                ;;
        esac
        first=1
    done
}

wp_correct_case() {
    for entry in *; do
        if ! [[ "$ZSH_VERSION" = "" ]]; then
            [[ "${1:l}" = "${entry:l}" ]]
        else
            [[ "${1,,}" = "${entry,,}" ]]
        fi
        
        if [[ $? -eq 0 ]]; then
            echo "${entry}"
            return 0
        fi
    done
    
    echo "wp_correct_case: $1: No such file or directory" >&2
    return 1
}

wp_init() {
    WP_WINE_VERSION="$(${WINE} --version)"

    if [[ $? != 0 ]]; then
        die "could not detect a valid Wine installation!"
    fi

    debug 1 "using wine version '${WP_WINE_VERSION}' (at ${WINE})"

    export PATH="$(dirname ${WINE}):${WP_PATH_AT_INIT}"
    init
}

wp_setup() {
    setup
}

wp_do_inherit() {
    local path

    if ! wp_inherited "$1"; then
        path="${WP_PLATFORM_PATH}/presets/$1.sh"
        debug 1 "trying to load '${path}'"

        if ! [[ -f "${path}" ]]; then
            die "preset not found: '$1'"
        fi

        wp_preset_push "$1"
        source "${path}"
        wp_preset_pop
        WP_INHERITS+=("$1")
    fi
}

wp_preset_push() {
    WP_PRESET_STACK+=("$1")
}

wp_preset_pop() {    
    # unfortunately zsh doesn't decrease the array size with 'unset' so we have
    # to special-case it, and the zsh code doesn't work in bash
    if ! [[ "$ZSH_VERSION" = "" ]]; then
        WP_PRESET_STACK[-1]=()
    else
        unset 'WP_PRESET_STACK[-1]'
    fi
}

wp_current_preset() {
    echo "${WP_PRESET_STACK[-1]}"
}

wp_inherited() {
    local el

    for el in "${WP_INHERITS[@]}"; do
        if [[ "${el}" == "$1" ]]; then
            return 0
        fi
    done

    return 1
}
