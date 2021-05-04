EXPORT_FUNCTIONS setup

battlenet_setup() {
    winetricks arial

    dlcache 'Battle.net-Setup.exe' 'https://eu.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe'

    mkdir -pv "${WINEPREFIX}/drive_c/users/$USER/Application Data/Battle.net/"
    cp -v "${FILES_DIR}/battlenet/Battle.net.config" "${WINEPREFIX}/drive_c/users/$USER/Application Data/Battle.net/Battle.net.config"

    wine "${CACHE_DIR}"/Battle.net-Setup.exe

    mklaunch 'launcher.sh' 'C:\Program Files (x86)\Battle.net\Battle.net.exe' --exec='launch Pro'
}
