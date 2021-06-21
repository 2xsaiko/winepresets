inherit win64 interactive-setup

EXPORT_FUNCTIONS setup

SETUP_INTERACTIVE_ONLY=1
SETUP_BANNER=1

wizard101_setup() {
    interactive-setup_setup

    if ! [[ -f "${CACHE_DIR}/InstallWizard101.exe" ]]; then
        # for some reason this is gzipped
        dlcache InstallWizard101.exe.gz https://edgecast.wizard101.com/InstallWizard101.exe
        gzip -d "${CACHE_DIR}/InstallWizard101.exe.gz"
    fi

    # installshield _should_ have the /s parameter for a silent install but
    # for some reason it doesn't work on this setup...
    wine "${CACHE_DIR}/InstallWizard101.exe"

    mklaunch launcher.sh 'C:\ProgramData\KingsIsle Entertainment\Wizard101\Wizard101.exe'
}
