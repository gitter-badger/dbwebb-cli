#!/usr/bin/env bash
#
# Download and install dbwebb-cli.
#
# Execute as:
# curl https://raw.githubusercontent.com/canax/dbwebb-cli/master/src/install.bash | bash
# bash -c "$(cat install.bash)"
# bash -c "$(curl -s https://raw.githubusercontent.com/canax/dbwebb-cli/master/src/install.bash)"
# bash -c "$(wget -qO- https://raw.githubusercontent.com/canax/dbwebb-cli/master/src/install.bash)"
#



#
# Basic settings
#
TARGET="https://raw.githubusercontent.com/dbwebb-se/dbwebb-cli/master/release/latest/dbwebb"
PATH1="/usr/local/bin"
PATH2="/usr/bin"
WHERE="$PATH1/anax"
TMP="/tmp/$$"

ECHO="echo -e"
ECHON="echo -n"
MSG_DOING="\\033[1;37;40m[dbwebb-cli]\\033[0m"
#MSG_DONE="\033[0;30;42m[OK]\033[0m"
MSG_DONE=""
#MSG_OK="\\033[0;30;42m[SUCCESS]\\033[0m"
#MSG_WARNING="\\033[43mWARNING\\033[0m"
MSG_FAILED="\\033[0;37;41m[FAILED]\\033[0m"



#
# Check if all tools are available
#
function checkTool() {
    $ECHON "$1 "
    if ! hash "$1" 2> /dev/null; then
        $ECHO "\\n$MSG_FAILED Missing $1, install it $2"
        #exit -1
    fi
}

$ECHO "$MSG_DOING Checking precondition..."

checkTool "curl"      "using your packet manager."
checkTool "wget"      "using your packet manager."
checkTool "rsync"     "using your packet manager."
checkTool "git"       "https://dbwebb.se/labbmiljo/git"
checkTool "make"      "https://dbwebb.se/labbmiljo/make"

$ECHO "\\n$MSG_DONE"



#
# Download
#
$ECHO "$MSG_DOING Downloading dbwebb-cli..."

if ! wget -qO $TMP $TARGET; then
    rm -f $TMP
    $ECHO "$MSG_FAILED downloading dbwebb-cli."
    $ECHO "I could not download the script from GitHub."
    $ECHO "Failed to access: $TARGET"
    exit 1
fi

ls -l $TMP

$ECHO "$MSG_DONE"



#
# Installing into path
#
$ECHO "$MSG_DOING Installing dbwebb-cli..."

if [[ ! -d $PATH1 ]]; then
    WHERE="$PATH2/dbwebb"
fi

$ECHO "Installing into '$WHERE'."

if ! install -v -m 0755 $TMP $WHERE; then
    rm $TMP
    $ECHO "$MSG_FAILED installing into '$WHERE'."
    $ECHO "Try re-run the installation-command as root using 'sudo'."
    exit 1
fi

ls -l $WHERE

$ECHO "$MSG_DONE"



#
# Cleaning up
#
$ECHO "$MSG_DOING Cleaning up..."

rm $TMP

$ECHO "$MSG_DONE"



#
# Execute the command to check version
#
$ECHO "$MSG_DOING Check what version we have..."

if ! anax --version; then
    $ECHO "$MSG_FAILED checking the version of dbwebb-cli."
    $ECHO "Try re-running the installation script or post the output of the installation procedure to the forum and ask for help."
    exit 1
fi

$ECHO "$MSG_DONE"



#
# Done
#
$ECHO "$MSG_DOING Done with success!"
$ECHO "Execute 'anax --help' to get an overview of the command."
$ECHO "Read the manual: https://dbwebb.se/dbwebb-cli"
