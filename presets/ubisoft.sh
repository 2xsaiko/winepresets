inherit win64

EXPORT_FUNCTIONS setup

ubisoft_setup() {
    common_setup
    dlcache UbisoftConnectInstaller.exe https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe
    wine "${CACHE_DIR}"/UbisoftConnectInstaller.exe

    mklaunch launcher.sh 'C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe'
}

