export WINEDLLOVERRIDES="${WINEDLLOVERRIDES},winemenubuilder.exe=d"

EXPORT_FUNCTIONS setup

_COMMON_SETUP_RUN=0

_COMMON_USER_KEYS=(
    '{374DE290-123F-4565-9164-39C4925E467B}' # Downloads
    'Desktop'
    'Personal'
    'My Music'
    'My Videos'
    'My Pictures'
    'Templates'
)

common_setup() {
    if [[ "${_COMMON_SETUP_RUN}" -eq 0 ]]; then
        wineboot
        common_remove_user_symlinks
        _COMMON_SETUP_RUN=1
    fi
}

common_remove_user_symlinks() {
    local p

    for k in "${_COMMON_USER_KEYS[@]}"; do
        p="$(wine reg query 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders' /v "$k" | dos2unix | sed -En 's/.*?REG_SZ\s+(.*)/\1/p' | head -1)"
        p="$(win2unixpath "$p")"

        if [[ $? -eq 0 ]]; then
            if [[ -L "$p" ]]; then
                rm -v "$p"
                mkdir -v "$p"
            fi
        else
            echo "Failed to get $k directory, ignoring"
        fi
    done
}

