inherit win64 battlenet
inherit dxvk esync 

EXPORT_FUNCTIONS setup

export WINEDLLOVERRIDES="${WINEDLLOVERRIDES},nvapi=d,nvapi64=d"

overwatch_setup() {
    dxvk_setup
    battlenet_setup

    mkdir -pv "${WINEPREFIX}/drive_c/users/$USER/My Documents/Overwatch/Settings/"
    cp -v "${FILES_DIR}/overwatch/Settings_v0.ini" "${WINEPREFIX}/drive_c/users/$USER/My Documents/Overwatch/Settings/Settings_v0.ini"
}
