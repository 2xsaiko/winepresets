inherit win64 esync dxvk

EXPORT_FUNCTIONS setup

the-elder-scrolls-online_setup() {
    dxvk_setup

    dlcache Install_ESO.exe http://elderscrolls-a.akamaihd.net/products/BNA_Launcher/Install_ESO.exe

    # Import certificate, wine has no certutil nor any other way (at least that
    # I found) to script importing certificates, so I imported the certificate
    # manually and diffed the registry; this is pretty shit but it works I
    # guess.
    # The certificate is necessary because newer versions of ca-certificates
    # don't come with this certificate anymore, but ESO's launcher requires that
    # root CA to be present, otherwise it won't start.
    wine reg IMPORT "${FILES_DIR}/the-elder-scrolls-online/thawte_Primary_Root_CA.reg"

    # The ESO installer autostarts the launcher with no apparent way to turn
    # that off, so let's just not run it in the first place.
    # This sequence of commands is adapted from the Lutris install script for
    # ESO.

    tmpdir="/tmp/eso_install_$RANDOM"
    mkdir "${tmpdir}" || die 'failed to create temp directory'
    
    unzip -d "${tmpdir}/installer" "${CACHE_DIR}"/Install_ESO.exe
    unzip -d "${tmpdir}/resource1" "${tmpdir}/installer/InstallerData/Disk1/InstData/Resource1.zip" || die 'failed to extract launcher files'
    mkdir -p "${WINEPREFIX}/drive_c/Program Files (x86)/Zenimax Online" || die 'failed to create install directory'
    cp -rv "${tmpdir}/resource1/\$IA_PROJECT_DIR$/src_path/Launcher" "${WINEPREFIX}/drive_c/Program Files (x86)/Zenimax Online/Launcher" || die 'failed to copy install files'
    
    rm -r "${tmpdir}"
    
    mklaunch 'launcher.sh' 'C:\Program Files (x86)\Zenimax Online\Launcher\Bethesda.net_Launcher.exe'
}
