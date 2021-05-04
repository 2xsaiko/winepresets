# winepresets

This is a command-line WINE prefix manager. Very WIP!

Concept: A *preset* is a small script that can set up environment variables,
provide a setup function that gets run when a new prefix is created. Most
importantly, presets can inherit other presets. This allows for sharing
common functionality (such as setting up dxvk or setting up a game launcher
that gets used by multiple games) between multiple presets.

## Usage

1. Clone this repo into some directory. The directory you clone into must stay
   constant because the generated prefixes reference it (you can move it if you
   then replace the *platform* symlink in each of the prefixes' directories).
2. Run `wp-newprefix` to create a new prefix. Example:
   `wp-newprefix -p the-elder-scrolls-online eso` to create a new prefix with
   the *the-elder-scrolls-online* preset in the *eso* directory. This will also
   automatically run the set-up script of that preset, which for game presets
   usually installs the game.
3. Setup scripts that install applications usually create launcher scripts in
   the prefix directory. In that case, you can directly start the application
   by executing that launcher script. To create custom launcher scripts, see
   the section *Entering a prefix context* below.

## Entering a prefix context

Each launcher script sources the *env* script in the prefix directory. However,
that script can also be sourced directly from an interactive shell to set
up the environment for that prefix (such as the *WINEPREFIX* environment
variable).  This will also provide the user with a couple useful commands:

 - `setup`, to re-run the setup script in case the user created the prefix
   with the option to suppress running the setup (`-S`)
 - `mklaunch`, which generates a launcher script in the prefix directory.
   Syntax: `mklaunch <name> <exe-path> [args...]` where exe-path is a
   **Windows** path inside the WINE prefix (e.g. `mklaunch launcher.sh
   'C:\Program Files (x86)\TmNationsForever\TmForeverLauncher.exe'`.

**NOTE:** The functions prefixed with *wp_* are **internal** and should not be
called directly!

This feature (sourcing the env script from an interactive shell) was tested
with the Bash and Zsh shells and might not work correctly with other shells.
