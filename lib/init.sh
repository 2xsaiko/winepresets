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

export WP_DATA_PATH
export WP_PLATFORM_PATH

export WPDEBUG="${WPDEBUG:-0}"
export WP_INTERACTIVE="${WP_INTERACTIVE:-0}"
WP_PATH_AT_INIT="${PATH}"
export CACHE_DIR="${WP_PLATFORM_PATH}/cache"
export FILES_DIR="${WP_PLATFORM_PATH}/files"
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

wp_init() {
    WP_WINE_VERSION="$(${WINE} --version)"

    if [[ $? != 0 ]]; then
        die "could not detect a valid Wine installation!"
    fi

    debug 1 "using wine version '${WP_WINE_VERSION}' (at ${WINE})"

    export PATH="$(dirname ${WINE}):${WP_PATH_AT_INIT}:${WP_PLATFORM_PATH}/libexec"
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
