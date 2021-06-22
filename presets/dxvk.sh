export DXVK_HUD="compiler"
export DXVK_STATE_CACHE_PATH="${WP_DATA_PATH}/cache"
export STAGING_SHARED_MEMORY=1
export __GL_DXVK_OPTIMIZATIONS=1
export __GL_SHADER_DISK_CACHE=1
export __GL_SHADER_DISK_CACHE_PATH="${WP_DATA_PATH}/cache"

EXPORT_FUNCTIONS setup

dxvk_setup() {
    common_setup
    winetricks dxvk
}

