# TODO make this less sucky
DIALOG="${DIALOG:-dialog}"
WP_INTERACTIVE="${WP_INTERACTIVE:--1}"

SETUP_INTERACTIVE_ONLY=0
SETUP_BANNER=0

EXPORT_FUNCTIONS setup

interactive-setup_setup() {
    if [[ "${SETUP_INTERACTIVE_ONLY}" -ne 0 ]]; then
        if [[ "${WP_INTERACTIVE}" -eq 0 ]]; then
            die 'This preset has an interactive-only setup. Please unset WP_INTERACTIVE or set it to 1.'
        fi

        if [[ "${SETUP_BANNER}" -ne 0 ]] && [[ "${SETUP_INTERACTIVE_ONLY}" -ne 0 ]]; then
            interactive-setup_warn_banner
        fi
    fi

    common_setup
}

interactive-setup_warn_banner() {
    ${DIALOG} --msgbox 'This game installer requires interacting with the setup wizard because it does not allow unattended installation.\nPlease keep the installation directory as the preset and close the game launcher after setup is completed or uncheck the checkbox to auto-run it, if applicable.' 0 0
}

